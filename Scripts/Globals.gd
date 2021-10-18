extends Node

enum GROUPS  {
	ENEMIES,
	PLAYER,
	FRIENDLY
}

func toggle_pause(val := 0):
	if val != 0:
		get_tree().paused = bool(val + 1)
	else:
		get_tree().paused = not(get_tree().paused)
	VisualServer.set_shader_time_scale(0.0 if get_tree().paused else 1.0)
