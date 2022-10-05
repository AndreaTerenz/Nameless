extends Spatial

enum GUN_STATE {
	ACTIVE,
	SWITCHING,
	INACTIVE
}

signal weapon_switched(i)
signal hook_ready(h)

export(NodePath) var anim_player_node
export(PoolStringArray) var weapons_scenes
export(int) var slots = 6
export(bool) var switching_enabled = true

var weapons: Array = []
var hidden: bool = false setget set_hidden
var keep_hidden_state := false
var current_weapon := 0
var can_hide := true

var player_hud : Control
var gun_stat setget set_gun_state

onready var anim_player := get_node(anim_player_node) as AnimationPlayer
onready var gun : BaseWeapon = null

func _ready() -> void:
	slots = min(len(weapons_scenes), slots)
	
	for i in range(slots):
		var num = i+1
		var act_name = "weapon slot %d" % num
		if not InputMap.has_action(act_name):
			InputMap.add_action(act_name)
			
			var ev = InputEventKey.new()
			ev.scancode = KEY_0 + num
			InputMap.action_add_event(act_name, ev)
	
	yield(Globals, "player_set")
	
	for s in range(0, slots):
		var g : BaseWeapon = load(weapons_scenes[s]).instance()
		g.player_inventory = Globals.player.inventory
		weapons.append(g)
		
	load_gun()
	set_crosshair()
	set_gun_state(GUN_STATE.ACTIVE)
	
	emit_signal("hook_ready", self)
	
func set_crosshair():
	var cross : Texture = null
	if gun is BaseGun:
		cross = gun.crosshair_text
		
	Globals.player.hud.set_crosshair_text(cross)

func switching():
	return (gun_stat == GUN_STATE.SWITCHING)

func _input(_event: InputEvent) -> void:
	if not keep_hidden_state and switching_enabled:
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
	if hidden != value and not keep_hidden_state:
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
		
		gun = weapons[current_weapon]
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
	
	emit_signal("weapon_switched", current_weapon)
	
	anim_player.play("Hide")

func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"Aim", "Aim Reverse", "Hide Reverse": 
			set_gun_state(GUN_STATE.ACTIVE)
		"Hide": 
			#Console.write_line("Finished hide anim")
			if switching() and len(weapons)>0:
				load_gun()
				anim_player.play("Hide Reverse")
		"Hide Reverse": 
			pass#Console.write_line("Finished hide reverse anim")

func _on_animation_started(anim_name: String) -> void:
	match anim_name:
		"Hide": 
			pass #Console.write_line("Started hide anim")
		"Hide Reverse": 
			pass #Console.write_line("Started hide reverse anim")

func set_gun_state(state):
	gun_stat = state
	
	match gun_stat:
		GUN_STATE.INACTIVE:
			toggle_gun_enabled(false)
		GUN_STATE.SWITCHING:
			toggle_gun_enabled(false)
			can_hide = false
		GUN_STATE.ACTIVE:
			can_hide = true
			toggle_gun_enabled(true)
				
func toggle_gun_enabled(e : bool):
	if gun:
		gun.enabled = e

func _on_interact_data(d) -> void:
	pass

func _on_prop_picked_up(obj) -> void:
	#Console.write_line("grabbd pickup so gun hid")
	set_hidden(true)
	keep_hidden_state = true


func _on_prop_released(obj, was_launched) -> void:
	#Console.write_line("droppd pickup so gun show")
	keep_hidden_state = false
	set_hidden(false)
