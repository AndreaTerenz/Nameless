class_name BulletGun
extends BaseGun

signal out_of_ammo

export(PackedScene) var bullet_scn
export(bool) var continuous = false

func _on_shoot():
	var bullet : Bullet = bullet_scn.instance()
	get_node("/root").add_child(bullet)
	bullet.setup(muzzle.global_transform)

func _check_fire():
	if continuous:
		return Input.is_action_pressed("fire")
	else:
		return ._check_fire()
