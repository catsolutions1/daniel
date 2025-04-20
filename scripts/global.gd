extends Node

onready var player_camera = null
onready var player = null

var room_pause: bool = false
export var room_pause_time: float = 0.2

signal level_loaded

func change_room(room_position: Vector2, room_size: Vector2) -> void:
	player_camera.current_room_center = room_position
	player_camera.current_room_size = room_size
	
	room_pause = true
	yield(get_tree().create_timer(room_pause_time), "timeout")
	room_pause = false

func _on_global_level_loaded():
	player_camera = get_tree().current_scene.get_node("2d_scene/level_1/player_camera")
	player = get_tree().current_scene.get_node("2d_scene/level_1/player")
