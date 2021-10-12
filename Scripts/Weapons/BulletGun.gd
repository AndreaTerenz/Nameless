class_name BulletGun
extends BaseGun

signal out_of_ammo

export(PackedScene) var bullet_scn
export(bool) var continuous = false
export(float, .01, .2, .005) var cooldown = .1

var timer : Timer

func _ready():
	timer = Timer.new()
	timer.connect("timeout", self, "_on_cooldown_over")
	timer.wait_time = cooldown
	timer.one_shot = true
	add_child(timer)
	
func _on_cooldown_over():
	pass

func _on_shoot():
	if timer.is_stopped():
		var bullet : Bullet = bullet_scn.instance()
		get_node("/root").add_child(bullet)
		bullet.setup(muzzle.global_transform)
		
		timer.start()

func _check_fire():
	if continuous:
		return Input.is_action_pressed("fire")
	else:
		return ._check_fire()
