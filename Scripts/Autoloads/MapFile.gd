class_name MapFile
extends ConfigFile

var scene_file : String setget ,get_scene_file
var display_name : String setget ,get_display_name

func _init(path):
	self.load(path)
	
func get_scene_file() -> String:
	return get_value("Generic", "scene_file", "")
	
func get_display_name() -> String:
	return get_value("Generic", "display_name", "")
