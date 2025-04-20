extends Node

export (Array, Resource) var available_levels

onready var _2d_scene = $"2d_scene"

func _ready() -> void:
	LevelManager.main_scene = _2d_scene
	LevelManager.levels = available_levels
