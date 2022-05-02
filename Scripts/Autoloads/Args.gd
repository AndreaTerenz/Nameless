extends Node

const SKIP_SPLASH = "skip_splash"
const USE_CONSOLE = "console"

const DEFAULT_SETTINGS = "defaults"
const DEFAULT_SETTS_SOFT = "soft"
const DEFAULT_SETTS_RESET = "reset"

var options : Dictionary = ArgParse.get_options()

func find_option(opt: String) -> bool:
	return  options.has(opt)

func get_option(opt: String, allowed := []):
	var value = options.get(opt, null)
	
	if allowed.empty() or value in allowed:
		return value

	return null
