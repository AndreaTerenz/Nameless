class_name BulletGun
extends BaseGun

signal out_of_ammo
signal ammo_updated
signal new_ammo(amnt)

export(bool) var continuous = false
#shots per seconds
export(int, 1, 1500) var fire_rate = 10
export(int, 1, 75) var ammo_per_mag = 20
export(int, 1, 8) var max_mags = 4

var timer := Timer.new()
var ammo_count := 0
var reserve_ammo := 0
var tot_ammo : int setget ,get_tot
func get_tot():
	return ammo_count + reserve_ammo
var cooldown : float
var inv_entry_type = Inventory.InventoryEntry.ENTRY_T.AMMO

var read_inv := true

func _ready():
	cooldown = 1.0/fire_rate
	
	timer.connect("timeout", self, "_on_cooldown_over")
	timer.wait_time = cooldown
	timer.one_shot = true
	add_child(timer)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reload"):
		reload()
	
func get_ammo_from_inventory(e : Inventory.InventoryEntry = null):
	var ammo_entry : Inventory.InventoryEntry = e if e else _get_entry()
		
	if ammo_entry:
		var new_tot = min(ammo_entry.quantity, max_mags * ammo_per_mag)
		Utils.log_line(self, "New tot ammo: %d" % [new_tot])
		
		reserve_ammo = new_tot
		reload(false)
	else:
		out_of_ammo()
	
func write_ammo_to_inventory():
	write_to_inventory()
	
func write_to_inventory():
	var entry : Inventory.InventoryEntry = _get_entry()
	
	#ugly, should work for now
	player_inventory.update_entry(entry.id, get_tot())
	
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

func _on_cooldown_over():
	pass
	
func _on_out_of_ammo() -> void:
	update_ui()

func _on_ammo_updated() -> void:
	update_ui()
	
func _on_new_ammo() -> void:
	update_ui()

func _on_shoot():
	if timer.is_stopped() and ammo_count > 0:
		var bullet : Bullet = _get_entry().item_scene.instance()
		get_node("/root").add_child(bullet)
		bullet.setup(muzzle.global_transform)
		
		ammo_count -= 1
		
		_on_shot()
		
		if (ammo_count <= 0):
			reload()
			
		timer.start()
		
func _on_shot() -> void:
	update_ui()

func _check_fire():
	if continuous:
		return Input.is_action_pressed("fire")
	else:
		return ._check_fire()
	
func _on_new_entry(entry: Inventory.InventoryEntry) -> void:
	if entry.name == entry_name:
		get_ammo_from_inventory()

func _on_updated_entry(entry: Inventory.InventoryEntry) -> void:
	if entry.name == entry_name:
		get_ammo_from_inventory()
