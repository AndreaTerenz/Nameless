class_name BulletGun
extends BaseGun

signal out_of_ammo
signal reloaded
signal new_ammo(amnt)

export(PackedScene) var bullet_scn = preload("res://Scenes/Weapons/Bullet.tscn")
export(bool) var continuous = false
#shots per seconds
export(int, 1, 1500) var fire_rate = 10

export(int, 1, 75) var ammo_per_mag = 20
export(int, 1, 8) var start_mags = 2
export(int, 1, 8) var max_mags = 4

var timer := Timer.new()
var mags_left := 0
var ammo_count := 0
var cooldown : float

func _ready():
	cooldown = 1.0/fire_rate
	print(cooldown)
	
	timer.connect("timeout", self, "_on_cooldown_over")
	timer.wait_time = cooldown
	timer.one_shot = true
	add_child(timer)
	
	enabled = true
	mags_left = start_mags-1
	ammo_count = ammo_per_mag
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reload"):
		reload()
	
func _on_cooldown_over():
	pass
	
func _on_shot() -> void:
	pass

func _on_out_of_ammo() -> void:
	pass

func _on_reloaded() -> void:
	pass
	
func _on_extra_ammo() -> void:
	pass
	
func reload():
	ammo_count = 0
	if mags_left > 0:
		enabled = true
		ammo_count = ammo_per_mag
		mags_left -= 1
		_on_reloaded()
		emit_signal("reloaded")
	else:
		enabled = false
		_on_out_of_ammo()
		emit_signal("out_of_ammo")
		
func picked_up_ammo(bllt_scn: PackedScene, amount: int):
	if bullet_scn == bllt_scn:
		amount = min(amount, abs(max_mags-mags_left))
		mags_left += amount
		enabled = true
		
		if ammo_count == 0:
			reload()
		else:
			_on_extra_ammo()
			emit_signal("new_ammo", amount)

func _on_shoot():
	if timer.is_stopped():
		var bullet : Bullet = bullet_scn.instance()
		get_node("/root").add_child(bullet)
		bullet.setup(muzzle.global_transform)
		
		ammo_count -= 1
		if (ammo_count <= 0):
			reload()
		
		timer.start()
		
		_on_shot()

func _check_fire():
	if continuous:
		return Input.is_action_pressed("fire")
	else:
		return ._check_fire()
