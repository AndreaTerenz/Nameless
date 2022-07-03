class_name Ladder
extends Area

var snap_orig : Vector3

func _ready() -> void:
	Utils.set_layer_bit_in_object(self, "Player", false)
	Utils.set_layer_bit_in_object(self, "Stairs")
	
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	
	for kid in get_children():
		if kid is CollisionShape:
			snap_orig = kid.transform.origin
			#debug_sphere(snap_orig)
			break
			
func get_snap_for_obj(s: Spatial):
	var s_local : Vector3 = Utils.spatial_to_local(s, self)
	var output = snap_orig
	output.y = s_local.y
	
	#debug_sphere(output)
	
	return to_global(output)

func _on_body_entered(body: Node) -> void:
	if body == Globals.player:
		Globals.player.entered_ladder(self)

func _on_body_exited(body: Node) -> void:
	if body == Globals.player:
		Globals.player.left_ladder(self)

func debug_sphere(at: Vector3):
	var sphere = MeshInstance.new()
	sphere.mesh = SphereMesh.new()
	sphere.mesh.radius = 0.2
	sphere.mesh.height = 0.2 * 2.0
	sphere.material_override = preload("res://Materials/Grids/grid_purple.tres")
	add_child(sphere)
	sphere.translate(at)
