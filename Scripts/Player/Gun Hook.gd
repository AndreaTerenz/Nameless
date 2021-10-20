extends Spatial

enum GUN_STATE {
	ACTIVE,
	SWITCHING,
	INACTIVE
}

export(NodePath) var anim_player_node
export(PoolStringArray) var weapons
export(int) var slots = 5

var hidden: bool = false setget set_hidden
var current_weapon := 0
var can_hide := true
var hud : Hud

var gun_stat setget set_gun_state
func switching():
	return (gun_stat == GUN_STATE.SWITCHING)

onready var anim_player := get_node(anim_player_node) as AnimationPlayer
onready var gun : BaseWeapon = null

func _ready() -> void:
	slots = min(len(weapons), slots)
	
func setup(h: Hud):
	hud = h
	load_gun()
	set_crosshair()
	set_gun_state(GUN_STATE.ACTIVE)
	
func set_crosshair():
	var cross : Texture = null
	if gun is BaseGun:
		cross = gun.crosshair_text
		
	hud.set_crosshair_text(cross)

func _input(event: InputEvent) -> void:
	if gun.aimable:
		var pressed = Input.is_action_just_pressed("aim")
		var released = Input.is_action_just_released("aim")
		if pressed or released:
			set_gun_state(GUN_STATE.INACTIVE)
			if pressed:
				can_hide = false
				anim_player.play("Aim")
			elif released:
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
			set_gun_state(GUN_STATE.INACTIVE)
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
		set_gun_state(GUN_STATE.INACTIVE)
		set_crosshair()
		
func switch_weapon(switch_to: int = slots):
	set_gun_state(GUN_STATE.SWITCHING)
	
	if not (switch_to in range(0, slots)):
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
		"Aim", "Aim Reverse", "Hide Reverse": 
			set_gun_state(GUN_STATE.ACTIVE)
		"Hide": 
			if switching() and len(weapons)>0:
				load_gun()
				anim_player.play("Hide Reverse")

func _on_animation_started(anim_name: String) -> void:
	pass
	
func set_gun_state(state):
	gun_stat = state
	
	match gun_stat:
		GUN_STATE.INACTIVE:
			gun.enabled = false
		GUN_STATE.SWITCHING:
			gun.enabled = false
			can_hide = false
		GUN_STATE.ACTIVE:
			can_hide = true
			gun.enabled = true






