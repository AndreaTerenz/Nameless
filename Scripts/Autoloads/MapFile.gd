class_name MapFile
extends ConfigFile

var scene_file : String setget ,get_scene_file
var display_name : String setget ,get_display_name
var scene_file_found := true

var load_error = OK

func _init(path):
	self.load(path)
	
	if get_scene_file() == "":
		load_error = ERR_INVALID_DATA
	elif not File.new().file_exists(get_scene_file()):
		load_error = ERR_FILE_NOT_FOUND
	
	if load_error != OK:
		scene_file_found = false
	
func get_scene_file() -> String:
	return get_value("Generic", "scene_file", "")
	
func get_display_name() -> String:
	return get_value("Generic", "display_name", "")
