extends Label

onready var player = LevelManager.player

func _process(_delta: float) -> void:
	self.text = "current state: " + str(player.state) + "\nhop set: " + str(player.hop_location_set) + "\nhop available: " + str(player.hop_available) + "\nhops remaining: " + str(player.hops_remaining) + "\ncoyote timer: " + str(player.coyote_timer)
