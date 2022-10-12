extends Light3D

@export var enabled := true
@export var max_char: int = 3
@export var length: int = 12
@export var frequency = .8 # (float, 0.0, 0.99, 0.01)
@export var sequence_str: String = ""

var base_energy = 0.0
var offset = 0.0
var cursor = 0

func _ready() -> void:
	base_energy = light_energy
	randomize()
	
	if (sequence_str == ""):
		for i in range(length):
			var val = randi() % max_char+1
			sequence_str += str(val)

func _physics_process(delta: float) -> void:
	if enabled:
		offset += delta
		
		if (offset >= 1 - frequency):
			offset = 0.0
			var _char = sequence_str[cursor]
			cursor += 1
			
			light_energy = base_energy*(float(_char)/float(max_char))
			
			if cursor >= len(sequence_str):
				cursor = randi()%len(sequence_str)
