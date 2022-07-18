class_name EnvVolume
extends Area

export(Player.ENVIRONMENT) var env_type = Player.ENVIRONMENT.WATER 

func _ready() -> void:
	set_meta("ENV_TYPE", env_type)
