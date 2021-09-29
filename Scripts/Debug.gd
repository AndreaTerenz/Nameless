extends Control

export(NodePath) var player_path

var player
var player_stat

onready var sprintLbl = $"MarginContainer/VBoxContainer/Sprint Lbl"
onready var crouchLbl = $"MarginContainer/VBoxContainer/Crouch Lbl"
onready var stairsLbl = $"MarginContainer/VBoxContainer/Stairs Lbl"
onready var floorLbl = $"MarginContainer/VBoxContainer/Floor Lbl"
onready var velocityLbl = $"MarginContainer/VBoxContainer2/Velocity Lbl"
onready var dirLbl = $"MarginContainer/VBoxContainer2/Direction Lbl"
onready var fpsLbl = $"MarginContainer/VBoxContainer2/FPS Lbl"
onready var fovLbl = $"MarginContainer/VBoxContainer2/FOV Lbl"
onready var healthLbl = $"MarginContainer/VBoxContainer2/Health Lbl"

func _ready() -> void:
	player = get_node(player_path)
	player_stat = player.get_node("Status")

func _process(delta: float) -> void:
	sprintLbl.text = "Sprinting: %s" % str(player.sprinting)
	crouchLbl.text = "Crouching: %s" % str(player.crouching)
	stairsLbl.text = "On stairs: %s" % str(player.on_stairs)
	floorLbl.text = "On floor: %s" % str(player.is_on_floor())
	
	printVector3(velocityLbl, "Velocity", player.velocity)
	printVector3(dirLbl, "Direction", player.direction)
	
	var vsync_stat = "on" if OS.vsync_enabled else "off"
	
	fpsLbl.text = "FPS: %s [vsync %s]" % [str(Engine.get_frames_per_second()), vsync_stat]
	fovLbl.text = "FOV: %.3f" % player.camera.fov
	#healthLbl.text = "Health: %.3f" % player_stat.health

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("show debug"):
		$MarginContainer.visible = not($MarginContainer.visible)
	if Input.is_action_just_pressed("toggle_vsync"):
		OS.vsync_enabled = not(OS.vsync_enabled)
	
func printVector3(label: Label, header: String, vector: Vector3):
	var a = vector.x
	var b = vector.y
	var c = vector.z
	label.text = "%s: (%.3f, %.3f, %.3f)" % [header,a,b,c]
