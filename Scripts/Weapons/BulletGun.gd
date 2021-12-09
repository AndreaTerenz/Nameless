class_name BulletGun
extends BaseGun

signal out_of_ammo
signal ammo_updated
signal new_ammo(amnt)

export(PackedScene) var bullet_scn = preload("res://Scenes/Weapons/Bullet.tscn")
export(bool) var continuous = false
#shots per seconds
export(int, 1, 1500) var fire_rate = 10

export(int, 1, 75) var ammo_per_mag = 20
export(int, 1, 8) var max_mags = 4

var timer := Timer.new()
var ammo_count := 0
var reserve_ammo := 0
var cooldown : float
var inv_entry_type = Inventory.InventoryEntry.ENTRY_T.AMMO

var read_inv := true

func _ready():
	cooldown = 1.0/fire_rate
	print(cooldown)
	
	timer.connect("timeout", self, "_on_cooldown_over")
	timer.wait_time = cooldown
	timer.one_shot = true
	add_child(timer)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reload"):
		reload()
	
func get_ammo_from_inventory(e : Inventory.InventoryEntry = null):
	var ammo_entry : Inventory.InventoryEntry = e if e else player_inventory.first_entry(inv_entry_type)
		
	if ammo_entry:
		print(int(ammo_entry.quantity))
		print(max_mags * ammo_per_mag)
		var new_tot = min(int(ammo_entry.quantity), max_mags * ammo_per_mag)
		print(new_tot)
		print("----------------------")
		
		if reserve_ammo != new_tot:
			reserve_ammo = new_tot
			reload(false)
	else:
		out_of_ammo()
	
func write_ammo_to_inventory():
	var ammo_entry : Inventory.InventoryEntry = player_inventory.first_entry(inv_entry_type)
	
	ammo_entry.quantity = reserve_ammo + ammo_count
	
func reload(reset_count := true):
	if reset_count:
		ammo_count = 0
		
	if reserve_ammo > 0:
		var quant = min(ammo_per_mag, reserve_ammo)
		ammo_count = quant
		reserve_ammo -= quant
		ammo_updated()
	else:
		out_of_ammo()
		
func ammo_updated():
	enabled = true
	_on_ammo_updated()
	emit_signal("ammo_updated")

func out_of_ammo() -> void:
	enabled = false
	_on_out_of_ammo()
	emit_signal("out_of_ammo")
	
func _on_enabled():
	get_ammo_from_inventory()
	
func _on_disabled():
	write_ammo_to_inventory()
	
func _on_new_entry(entry: Inventory.InventoryEntry):
	if entry.type == inv_entry_type:
		get_ammo_from_inventory()

func _on_updated_entry(entry: Inventory.InventoryEntry):
	if entry.type == inv_entry_type:
		get_ammo_from_inventory()

func _on_cooldown_over():
	pass
	
func _on_out_of_ammo() -> void:
	pass

func _on_ammo_updated() -> void:
	pass
	
func _on_new_ammo() -> void:
	pass

func _on_shoot():
	if timer.is_stopped() and ammo_count > 0:
		var bullet : Bullet = bullet_scn.instance()
		get_node("/root").add_child(bullet)
		bullet.setup(muzzle.global_transform)
		
		ammo_count -= 1
		
		_on_shot()
		
		if (ammo_count <= 0):
			reload()
			
		timer.start()
		
func _on_shot() -> void:
	pass

func _check_fire():
	if continuous:
		return Input.is_action_pressed("fire")
	else:
		return ._check_fire()
