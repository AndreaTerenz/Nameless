class_name SceneManager
extends Spatial

var world_env : WorldEnvironment = null
var sun_light : DirectionalLight = null
var gi_probes := []
var ref_probes := []
var global_audio_srcs : Dictionary = {}

func _ready() -> void:	
	for child in get_children():
		if child is WorldEnvironment:
			Console.write_line("Detected world environment")
			world_env = child
		if child is DirectionalLight:
			Console.write_line("Detected directional sun light")
			sun_light = child
		if child is GIProbe:
			Console.write_line("Detected GIProbe #%d" % [len(gi_probes)])
			gi_probes.append(child)
		if child is ReflectionProbe:
			Console.write_line("Detected ReflectionProbe #%d" % [len(ref_probes)])
			ref_probes.append(child)
		if child is AudioStreamPlayer:
			Console.write_line("Detected global audio player #%d" % [len(global_audio_srcs)])
			global_audio_srcs[child] = child.volume_db
			
	if not world_env:
		Console.Log.warn("NO WORLD ENVIRONMENT DETECTED")
			
	if not sun_light:
		Console.Log.warn("NO DIRECTIONAL SUN DETECTED")
	
	Console.add_command("toggle_sun", self, "toggle_sun")\
	.set_description("toggles scene directional light")\
	.add_argument("show", TYPE_BOOL)\
	.register()
	
	Console.add_command("toggle_gi_probes", self, "toggle_gi_probes")\
	.set_description("toggles GIProbes")\
	.add_argument("show", TYPE_BOOL)\
	.register()
		
	Console.add_command("toggle_ref_probes", self, "toggle_ref_probes")\
	.set_description("toggles GIProbes")\
	.add_argument("show", TYPE_BOOL)\
	.register()
		
	Console.add_command("env_set_tonemapper", self, "env_set_tonemapper")\
	.set_description("sets environment ToneMapper")\
	.add_argument("type", TYPE_INT)\
	.register()
		
	Console.add_command("env_toggle_bloom", self, "env_toggle_bloom")\
	.set_description("toggle environment bloom")\
	.add_argument("show", TYPE_BOOL)\
	.register()
		
	Console.add_command("env_toggle_auto_exp", self, "env_toggle_auto_exp")\
	.set_description("toggle environment automatic exposure")\
	.add_argument("show", TYPE_BOOL)\
	.register()
		
	Console.add_command("env_set_property", self, "env_set_property")\
	.set_description("set value for world env property")\
	.add_argument("prop", TYPE_STRING)\
	.add_argument("value", TYPE_OBJECT)\
	.register()
	
	Globals.set_scene_manager(self)

func toggle_sun(show):
	if sun_light:
		sun_light.visible = (show)

func toggle_gi_probes(show):
	for gip in gi_probes:
		gip.visible = show

func toggle_ref_probes(show):
	for rp in ref_probes:
		rp.visible = show

func env_set_tonemapper(type):
	if world_env:
		world_env.environment.tonemap_mode = type

func env_toggle_bloom(show):
	if world_env:
		world_env.environment.glow_enabled = show

func env_toggle_auto_exp(show):
	if world_env:
		world_env.environment.auto_exposure_enabled = show

func env_set_property(prop, value):
	if world_env:
		world_env.set(prop, value)
