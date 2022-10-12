class_name Inventory
extends Node

signal updated
signal updated_entry(entry)
signal new_entry(entry)
signal overweight

class InventoryEntry:
	enum ENTRY_T {
		AMMO,
		HEALTH
	}
	
	var name : String = ""
	var type = ENTRY_T.AMMO
	var quantity : int = 0
	var weight : float = 0.0
	var unique: bool = false
	var item_scene: PackedScene = null
	var id: int = -1
	
	var total_weight: float :
	get:
		return total_weight # TODOConverter40 Copy here content of get_tot_weight 
	set(mod_value):
		mod_value  # TODOConverter40  Non existent set function
	func get_tot_weight():
		return weight * quantity
	
	func _init(n: String,t,q: int,w: float,u: bool = false,s: PackedScene = null,i: int = -1):
		name = n
		type = t
		quantity = q
		weight = w
		unique = u
		id = i
		item_scene = s
		
	func merge_with(other: InventoryEntry) -> void:
		if self.name == other.name and not (self.unique or other.unique):
			quantity += other.quantity
			
	func _to_string() -> String:
		return "%s (%d)" % [name, quantity]
		
@export var max_weight := 200.0 # (float, 150.0, 300, .5)
@export var allow_overweight: bool = false

var entries: Array = []
var entry_listeners: Dictionary = {}
var current_weight: float = 0.0

func is_overweight():
	return current_weight > max_weight

func _ready() -> void:
	pass
	
func first_entry_by_name(name: String) -> InventoryEntry:
	for entry in entries:
		if entry.name == name:
			return entry
	
	return null
	
func first_entry_by_type(type) -> InventoryEntry:
	for entry in entries:
		if entry.type == type:
			return entry
	
	return null
	
func filter_entries(type) -> Array:
	var output := []
	
	for entry in entries:
		if entry.type == type:
			output.append(entry)
	
	return output
	
func add_entry_listener(entry_name: String, listener: Object):
	# Juan please add interfaces to this god forsaken language ffs
	if listener.has_method("write_to_inventory") and not entry_listeners.has(entry_name):
		entry_listeners[entry_name] = listener
	
func add_from_dict(data: Dictionary) -> bool:
	var entry : InventoryEntry = InventoryEntry.new(
		data["name"],
		data["type"],
		data.get("quantity", 1.0),
		data.get("weight", 0.0),
		data.get("unique", false),
		data.get("scene", null)
	)
	
	return add_entry(entry)
	
func could_carry(extra_weight: float) -> bool:
	return (current_weight + extra_weight <= max_weight) or allow_overweight

func add_entry(entry: InventoryEntry) -> bool:
	if entry and could_carry(entry.total_weight):
		var existing = first_entry_by_name(entry.name)
		
		if entry.unique or not existing:
			entry.id = len(entries)
			entries.append(entry)
			Utils.log_line(self, "Added inventory entry [%s]" % entry)
			current_weight += entry.total_weight
			emit_signal("new_entry", entry)
		else:
			if (entry_listeners.has(existing.name)):
				Utils.log_line(self, "Requesting writeback for inventory entry [%s]" % existing.name)
				entry_listeners[existing.name].write_to_inventory()
			
			Utils.log_line(self, "Updated inventory entry [%s] with [%s]" % [existing, entry])
			existing.merge_with(entry)
			current_weight += entry.total_weight
			emit_signal("updated_entry", entry)
		
		if is_overweight():
			Console.Log.warn("Inventory overweight")
			emit_signal("overweight")
		
		return true
	
	return false
	
func update_entry(id: int, new_quant: int, send_update := false):
	if id in range(0, len(entries)):
		var deltaQ = entries[id].quantity - new_quant
		entries[id].quantity = new_quant
		current_weight -= deltaQ * entries[id].weight
		if send_update:
			emit_signal("updated_entry", entries[id])
			
func request_total_wb():
	for e in entries:
		Utils.log_line(self, "Requesting writeback for inventory entry [%s]" % e.name)
		entry_listeners[e.name].write_to_inventory()
	
func entries_as_strings(type_filter = -1) -> PackedStringArray:
	var output : PackedStringArray = []
	
	for e in entries:
		var entry := e as InventoryEntry
		if (type_filter != -1 and entry.type == type_filter) or (type_filter == -1):
			output.append(entry.to_string())
	
	return output
	
func remove_entry():
	pass

func _on_interact_data(data) -> void:
	if add_entry(data):
		emit_signal("updated")
	
