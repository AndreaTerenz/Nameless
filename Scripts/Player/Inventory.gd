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
	var weight: float = 0.0
	var unique: bool = false
	var id: int = -1
	
	var total_weight setget , get_tot_w
	func get_tot_w():
		return weight * quantity
	
	func _init(n: String, t, q: int, w: float, u: bool = false, i: int = -1) -> void:
		name = n
		type = t
		quantity = q
		weight = w
		unique = u
		id = i
		
	func merge_with(other: InventoryEntry) -> void:
		if self.name == other.name and not (self.unique or other.unique):
			quantity += other.quantity
			
	func _to_string() -> String:
		return "%s (%d)" % [name, quantity]

export var max_weight: float = 100.0
export(bool) var allow_overweight = false
var current_weight: float = 0.0

var entries: Array = []

func _ready() -> void:
	pass
	
func find_entry(name: String) -> InventoryEntry:
	for entry in entries:
		if entry.name == name:
			return entry
	
	return null
	
func first_entry(type) -> InventoryEntry:
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
	
func add_from_dict(data: Dictionary) -> bool:
	var entry : InventoryEntry = InventoryEntry.new(
		data["name"],
		data["type"],
		data.get("quantity", 1.0),
		data.get("weight", 1.0),
		data.get("unique", false)
	)
	
	return add_entry(entry)
	
func could_carry(extra_weight: float) -> bool:
	return current_weight + extra_weight <= max_weight

func add_entry(entry: InventoryEntry) -> bool:
	if could_carry(entry.total_weight) or allow_overweight:
		var existing = find_entry(entry.name)
		
		if entry.unique or not existing:
			entry.id = len(entries)
			entries.append(entry)
			emit_signal("new_entry", entry)
		else:
			existing.merge_with(entry)
			emit_signal("updated_entry", entry)
			
		return true
		
	if current_weight >= max_weight:
		emit_signal("overweight")
	
	return false
	
func entries_as_strings(type_filter = -1) -> PoolStringArray:
	var output : PoolStringArray = []
	
	for e in entries:
		var entry := e as InventoryEntry
		print("AP")
		print(type_filter, ' ', entry.type)
		if (type_filter != -1 and entry.type == type_filter) or (type_filter == -1):
			output.append(entry.to_string())
	
	return output
	

	
func remove_entry():
	pass

func _on_interact_data(data) -> void:
	if add_from_dict(data):
		emit_signal("updated")
	
