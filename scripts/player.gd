extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var platform_color: Array = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1), Color(1, 1, 0), Color(0, 1, 1), Color(1, 0, 1)]
var platform_color_index: int = 0
var hop_location_set: bool = false
var hop_location: Vector2
var hop_available: bool = true
var hops_remaining: int = 3
var coyote_timer: float = 0
export var coyote_time: float = 0.1

const walk_acceleration: int = 500
const walk_speed_cap: int = 250
const jump_acceleration: int = 200
const hop_acceleration: int = 125
const friction: int = 1300
const gravity: int = 200
const hop_cooldown: float = 1.25

const platform_scene = preload("res://scenes/entities/platform.tscn")

enum states {grounded, jump, fall, hop, left_wall_jump, right_wall_jump}
var state: int = states.grounded

func _physics_process(delta: float) -> void:
	if !Global.room_pause:
		coyote_timer += delta
		handle_state_change()
		handle_current_state(delta)
		handle_basic_movement(delta)

func handle_state_change() -> void:
	if is_on_floor():
		if state != states.grounded:
			change_state(states.grounded)
		if Input.is_action_just_pressed("jump"):
			change_state(states.jump)
	if !is_on_floor():
		if state != states.fall and velocity.y > 0:
			change_state(states.fall)
		if Input.is_action_just_pressed("jump"):
			if coyote_timer < coyote_time:
				change_state(states.jump)
			else:
				if $left_ray1.is_colliding() or $left_ray2.is_colliding() or $left_ray3.is_colliding():
					change_state(states.left_wall_jump)
				elif $right_ray1.is_colliding() or $right_ray2.is_colliding() or $right_ray3.is_colliding():
					change_state(states.right_wall_jump)
	if Input.is_action_just_pressed("hop") and hop_available and hops_remaining > 0:
		change_state(states.hop)

func change_state(new_state: int) -> void:
	state = new_state
	match state:
		states.grounded:
			for child in get_parent().get_children():
				if child.is_in_group("platform"):
					child.queue_free()
			hop_location_set = false
			hops_remaining = 3
			platform_color_index = 0
		states.jump:
			velocity.y = -jump_acceleration
		states.fall:
			pass
		states.hop:
			if !hop_location_set:
				hop_location = Vector2(global_position.x, global_position.y)
				spawn_platform()
				hop_location_set = true
			else:
				yield(get_tree().create_timer(0.1), "timeout")
				position = hop_location
				velocity = Vector2.ZERO
				for child in get_parent().get_children():
					if child.is_in_group("platform"):
						child.queue_free()
				hop_location_set = false
				hops_remaining -= 1
			velocity.y = -hop_acceleration
			hop_available = false
			yield(get_tree().create_timer(hop_cooldown), "timeout")
			hop_available = true
			
		states.left_wall_jump:
			velocity.y = -hop_acceleration
			velocity.x = hop_acceleration
		states.right_wall_jump:
			velocity.y = -hop_acceleration
			velocity.x = -hop_acceleration

func handle_current_state(delta: float) -> void:
	match state:
		states.grounded:
			coyote_timer = 0
			velocity.x = clamp(velocity.x, -walk_speed_cap, walk_speed_cap)
		states.jump:
			velocity.x = clamp(velocity.x, -walk_speed_cap, walk_speed_cap)
		states.fall:
			velocity.x = clamp(velocity.x, -walk_speed_cap, walk_speed_cap)
		states.hop:
			velocity.x = clamp(velocity.x, -walk_speed_cap, walk_speed_cap)
		
		#velocity decays more slowly, prevents climbing a single wall
		states.left_wall_jump:
			velocity.x = move_toward(velocity.x, walk_speed_cap, friction * delta)
		states.right_wall_jump:
			velocity.x = move_toward(velocity.x, -walk_speed_cap, friction * delta)

func handle_basic_movement(delta: float) -> void:
	var walk := walk_acceleration * (Input.get_axis("move_left", "move_right"))
	if abs(walk_acceleration * (Input.get_axis("move_left", "move_right"))) < 0.2:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:	
		velocity.x += walk * delta
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func spawn_platform() -> void:
	var platform = platform_scene.instance()
	platform.position = Vector2(global_position.x, global_position.y + 36)
	platform.modulate = platform_color[platform_color_index]
	if platform_color_index == 5:
		platform_color_index = 0
	else:
		platform_color_index += 1
	get_parent().add_child(platform)

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("bouncy"):
		velocity.y = -body.bounce_acceleration
		hops_remaining = 3
		if body.invulnerable == false:
			body.queue_free()

func _on_room_detector_area_entered(area: Area2D) -> void:
	var collision_shape: CollisionShape2D = area.get_node("CollisionShape2D")
	var size: Vector2 = collision_shape.shape.extents * 2
	
#	LevelManager.change_room(collision_shape.global_position, size)
