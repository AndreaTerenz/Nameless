extends Spatial

export(NodePath) var anim_player_node
export(PoolStringArray) var weapons
export(int) var slots = 5

var hidden: bool = false setget set_hidden

var current_weapon := 0
var can_hide := true
var switching := false

onready var anim_player := get_node(anim_player_node) as AnimationPlayer
onready var gun : MeshInstance = null

func _ready() -> void:
	slots = min(len(weapons), slots)
	
	load_gun()

func _input(event: InputEvent) -> void:
	if gun.aimable:
		if Input.is_action_just_pressed("aim"):
			can_hide = false
			anim_player.play("Aim")
		elif Input.is_action_just_released("aim"):
			anim_player.play("Aim Reverse")
		
	if can_hide:
		if Input.is_action_just_pressed("next weapon"):
			switch_weapon(slots+1)
		elif Input.is_action_just_pressed("prev weapon"):
			switch_weapon(-1)
			
		for i in range(0, slots):
			var action := "weapon slot %d" % (i+1)
			if i != current_weapon and Input.is_action_just_pressed(action):
				switch_weapon(i)

func set_hidden(value):
	if (hidden != value):
		hidden = value
		if (hidden):
			anim_player.play("Hide")
		else:
			anim_player.play("Hide Reverse")

func load_gun():
	if len(weapons)>0:
		if gun:
			remove_child(gun)
			gun = null
		
		var gunScn : PackedScene = load(weapons[current_weapon])
		gun = gunScn.instance()
		add_child(gun)
		
func switch_weapon(switch_to: int = slots):
	can_hide = false
	switching = true
	
	if not switch_to in range(0, slots):
		current_weapon += sign(switch_to)
		if current_weapon >= slots:
			current_weapon = 0
		elif current_weapon < 0:
			current_weapon = slots-1
	else:
		current_weapon = switch_to
	
	anim_player.play("Hide")

func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"Aim Reverse", "Hide Reverse": 
			can_hide = true
		"Hide": 
			if switching and len(weapons)>0:
				load_gun()
				switching = false
				anim_player.play("Hide Reverse")


func _on_animation_started(anim_name: String) -> void:
	pass
