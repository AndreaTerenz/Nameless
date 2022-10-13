extends Node

signal settings_loaded(defaults)
signal failed_to_load(error)
signal settings_saved
signal failed_to_save(error)
signal changed_setting(sett_name, newVal)
signal deleted_setting(sett_name)

enum SECTIONS {
	CONTROLS,
	GRAPHICS,
	AUDIO
}

class SettingsEdit extends TempEdit:
	var section : String
	var key : String
	
	func _init(s: String,k: String):
		super(load("res://Scripts/Autoloads/Settings.gd").get_value(s, k))
		section = s
		key = k
		
	func _on_apply():
		load("res://Scripts/Autoloads/Settings.gd").set_value(section, key, current_value)

var config := ConfigFile.new()
var target_file := ""
var data_loaded := false

######################################
const CONTROLS := "Controls"
const INVERT_Y := "invert_y_axis"
const MOUSE_SENS := "mouse_sensitivity"

######################################
const GRAPHICS := "Graphics"
const USE_VSYNC := "use_vsync"
const RESOLUTION := "resolution"

const NATIVE_RES := "native"
const STD_RESS := [
	"800 x 600",
	"1024 x 600",
	"1024 x 768",
	"1280 x 720",
	"1280 x 960",
	"1366 x 768",
	"1400 x 1050",
	"1600 x 900",
	"1920 x 1080",
	"2560 x 1440",
]

const WIN_MODE := "window_mode"
const WIN_MODE_FULL := "fullscreen"
const WIN_MODE_WINDW := "windowed"
const WIN_MODE_BRDRLESS := "borderless"

######################################
const AUDIO := "Audio"

const MASTER_VOL := "master_volume"
const MASTER_VOL_MUTED := "master_volume_mute"

######################################
const CUSTOM_KEYS := "CustKeys"

const defaults : Dictionary = {
	CONTROLS : {
		MOUSE_SENS: 1.0,
		INVERT_Y: false
	},
	GRAPHICS : {
		USE_VSYNC: true,
		RESOLUTION: NATIVE_RES,
		WIN_MODE: WIN_MODE_FULL
	},
	AUDIO : {
		MASTER_VOL: 1.0,
		MASTER_VOL_MUTED: false,
	},
}

func _ready():
	target_file = "user://"
	if Utils.is_debug():
		target_file = "res://"
	target_file = target_file + "settings.cfg"
	
	if not data_loaded:
		var err = config.load(target_file)
		data_loaded = true
		
		var default_opt = Args.get_option(Args.DEFAULT_SETTINGS, [Args.DEFAULT_SETTS_RESET, Args.DEFAULT_SETTS_SOFT])
		
		if err == ERR_FILE_NOT_FOUND or default_opt:
			load_defaults()
			if err == ERR_FILE_NOT_FOUND or (default_opt == Args.DEFAULT_SETTS_RESET):
				save_data()
		elif err == OK:
			emit_signal("settings_loaded", false)
		else:
			emit_signal("failed_to_load", err)
			data_loaded = false
			
		if data_loaded:
			apply_all()
		
func save_data():
	var err = config.save(target_file)
	
	if err == OK:
		emit_signal("settings_saved")
	else:
		emit_signal("failed_to_save", err)

func load_defaults():
	for section in defaults.keys():
		for key in defaults[section].keys():
			set_value(section, key, defaults[section][key], false, false)
			
	emit_signal("settings_loaded", true)
	
func get_value(section: String, key: String, default = null):
	return config.get_value(section, key, default)
	
func has_value(section: String, key: String):
	return config.get_value(section, key) != null
	
func set_value(section: String, key: String, value, apply := true, emit_change := true):
	config.set_value(section, key, value)
	
	if apply:
		apply_setting(section, key, value)
	
	if emit_change:
		emit_signal("changed_setting", get_section_key_str(section, key), value)
	
func delete_value(section: String, key: String, apply := true, emit_change := true):
	config.set_value(section, key, null)
	
	if emit_change:
		emit_signal("deleted_setting", get_section_key_str(section, key))
		
func apply_setting(section: String, key: String, value):
	if section == CONTROLS:
		pass
	elif section == GRAPHICS:
		match key:
			USE_VSYNC:
				OS.vsync_enabled = bool(value)
			RESOLUTION: 
				#OBVIOUSLY MAKE SURE TO BRIEFLY RESET TO THE NATIVE RESOLUTION EVERY TIME
				#Globals.set_resolution()
				
				var str_v := str(value)
				
				if str_v != NATIVE_RES:
					var tmp = split_resolution_str(str_v)
					var w = int(tmp[0])
					var h = int(tmp[1])
					
					Globals.set_resolution()
					
					var scrn_size = DisplayServer.screen_get_size()
					if w != scrn_size.x and h != scrn_size.y:
						Globals.set_resolution(w, h)
						"""
						var window_size := OS.get_screen_size()
						var ratio = window_size.x / window_size.y
						var minsize = Vector2(w * ratio, h)
						get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_WIDTH, minsize)
						"""
				else:
					Globals.set_resolution()
			WIN_MODE:
				match str(value).to_lower():
					WIN_MODE_FULL:
						Globals.set_fullscreen(true)
					WIN_MODE_WINDW: 
						Globals.set_fullscreen(false)
	elif section == AUDIO:
		match key:
			MASTER_VOL:
				var idx = AudioServer.get_bus_index("Master")
				var db = linear_to_db(clamp(value, 0.0, 1.0))
				AudioServer.set_bus_volume_db(idx, db)
			MASTER_VOL_MUTED:
				# value == true --> audio MUTED
				# value == false --> audio ENABLED
				value = bool(value)
				var idx = AudioServer.get_bus_index("Master")
				var db = linear_to_db(0.0)
				
				if not value:
					var volume = get_value(AUDIO, MASTER_VOL)
					db = linear_to_db(clamp(volume, 0.0, 1.0))
				
				AudioServer.set_bus_volume_db(idx, db)
		
func apply_all():
	for section in config.get_sections():
		for key in config.get_section_keys(section):
			var value = config.get_value(section, key)
			apply_setting(section, key, value)
		
func get_section_key_str(section: String, key: String):
	return "%s.%s" % [section, key]
	
func section_key_from_str(string: String):
	return string.split(".", true, 1)
	
func split_resolution_str(res: String):
	return res.replace(" ", "").split("x")
	
	
	
	
	
