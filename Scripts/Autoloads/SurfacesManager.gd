extends Node

const SFX_FOLDER = "res://Assets/Audio/SFX/footsteps"

class FootstepsProperties:
	var format_str = ""
	var count = 0
	
	func _init(fs: String,c: int):
		self.format_str = fs
		self.count = c

var bindings := {
	"default" : FootstepsProperties.new(SFX_FOLDER + "/default/default_step_%d.ogg", 4),
	"concrete" : FootstepsProperties.new(SFX_FOLDER + "/concrete/concrete_%d.ogg", 4),
	"dirt" : FootstepsProperties.new(SFX_FOLDER + "/dirt/dirt_%d.ogg", 4),
}
