class_name BaseCharacter
extends CollisionObject

export(Globals.GROUPS) var npc_type = Globals.GROUPS.NEUTRAL
export(NodePath) var hitbox_path = ""

var hitbox : Hitbox = null

func _ready() -> void:
	if hitbox_path == "":
		for kid in get_children():
			if kid is Hitbox:
				hitbox = kid
				break
	else:
		hitbox = get_node(hitbox_path) as Hitbox
		
	hitbox.connect("hit", self, "_on_hitbox_hit")
	hitbox.connect("killed", self, "_on_hitbox_failed")
	
	hitbox.collision_layer = 0
	collision_layer = 0
	
	var layer : int = Globals.get_layer_bit(Globals.group_layers[npc_type])
	hitbox.set_collision_layer_bit(layer, true)
	set_collision_layer_bit(layer, true)
	

func _on_hitbox_hit(damage):
	pass
	
func _on_hitbox_failed():
	queue_free()
