class_name PlayerTracker
extends Node

signal saved
signal loaded

export(bool) var save_on_ready = true
export(bool) var debug_enabled = true

var data := {}
var player = null
var last_save_time := -1
var health := -1.0
var hud_features := -1
var transf_data := {
	glob_pos = Vector3.ZERO,
	glob_rot = Vector3.ZERO,
	look_rot = Vector2.ZERO,
}

"""
MISSING:
	Inventory items
	Selected weapon
	Camera settings
	Mover data (which one)
	Mode data (which one)
"""

func _ready() -> void:
	yield(Globals, "player_set")
	player = Globals.player

	if player and save_on_ready:
		save_data()

func save_data():
	last_save_time = Time.get_unix_time_from_system()
	
	health = player.health
	
	hud_features = player.hud.features
	
	transf_data.glob_pos = player.global_translation
	
	transf_data.glob_rot = player.global_rotation
	transf_data.look_rot = Vector2(player.head.rotation_degrees.x, player.rotation_degrees.y)
	
	emit_signal("saved")
	
func _process(delta: float) -> void:
	if debug_enabled:
		DebugDraw.draw_sphere(transf_data.glob_pos)
	
func load_data(keep_movement := true):
	player.health = health
	
	player.hud.features = hud_features
	
	player.reset_transform(transf_data.glob_pos, transf_data.look_rot.x, transf_data.look_rot.y)
	
	if not keep_movement:
		player.mover.stop()
	
	emit_signal("loaded")
