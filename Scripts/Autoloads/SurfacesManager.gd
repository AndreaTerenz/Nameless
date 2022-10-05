extends Node

const SFX_FOLDER = "res://Assets/Audio/SFX/footsteps"

class FootstepsProperties:
	var format_str = ""
	var count = 0
	
	func _init(fs: String, c: int) -> void:
		self.format_str = fs
		self.count = c

var bindings := {
	"concrete" : FootstepsProperties.new(SFX_FOLDER + "/concrete/concrete_%d.ogg", 4),
	"dirt" : FootstepsProperties.new(SFX_FOLDER + "/dirt/dirt_%d.ogg", 4),
}
