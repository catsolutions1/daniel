extends Node

var levels: Array

var main_scene: Node2D = null
var loaded_level: Level = null

signal level_loaded

func unload_level() -> void:
	if is_instance_valid(loaded_level):
		loaded_level.queue_free()
	loaded_level = null
	
func load_level(level_id: int) -> void:
	print("loading level %s" % level_id)
	unload_level()
	
	var level_data = get_level_data_by_id(level_id)
	
	if !level_data:
		return
	
	var level_path = "res://scenes/%s.tscn" % level_data.level_path
	var level_resource := load(level_path)
	
	if level_resource:
#		print("loading level resource")
		loaded_level = level_resource.instance()
		main_scene.add_child(loaded_level)
		print("level loaded")
		emit_signal("level_loaded")
	else:
		print("level does not exist")

func get_level_data_by_id(id: int) -> LevelData:
	var level_to_return: LevelData = null
	
	for level in levels:
		if level.level_id == id:
			level_to_return = level
	
#	print("got level data: ", level_to_return)
	return level_to_return
