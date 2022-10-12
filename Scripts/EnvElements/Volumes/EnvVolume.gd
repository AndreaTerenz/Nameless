class_name EnvVolume
extends Area3D

@export var env_type = Player.ENVIRONMENT.WATER  # (Player.ENVIRONMENT)

func _ready() -> void:
	set_meta("ENV_TYPE", env_type)
