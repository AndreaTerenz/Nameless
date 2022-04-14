class_name MapFile
extends ConfigFile

const NO_ERROR = -100
const MF_INVALID_INCOMPLETE = 100
const MF_SCENE_FILE_NOT_FOUND = 101

var scene_file : String setget ,get_scene_file
var display_name : String setget ,get_display_name
var description : String setget ,get_description
var scene_file_found := true

var load_error = NO_ERROR

func _init(path: String):
	var err = self.load(path)
	
	if err != OK:
		load_error = err
	else:
		var f : String = get_raw_scene_file()
		
		if f == "":
			load_error = MF_INVALID_INCOMPLETE
		else:
			if f.begins_with("@/"):
				f = f.replace("@/", "")
				f = path.get_base_dir() + "/" + f
				set_value("Generic", "scene_file", f)
				#save(path) MMMEH
				
			if not File.new().file_exists(f):
				load_error = MF_SCENE_FILE_NOT_FOUND
	
	scene_file_found = (load_error == OK)

func get_raw_scene_file() -> String:
	return get_value("Generic", "scene_file")

func get_scene_file() -> String:
	return get_value("Generic", "scene_file", "")
	
func get_display_name() -> String:
	return get_value("Generic", "display_name", "")
	
func get_description() -> String:
	return get_value("Generic", "description", "")
