
extends Reference


# @var  Console
var _console


# @param  Console  console
func _init(console):
	self._console = console

	self._console.add_command('echo', self._console, 'write')\
		.set_description('Prints a string.')\
		.add_argument('text', TYPE_STRING)\
		.register()

	self._console.add_command('history', self._console.History, 'print_all')\
		.set_description('Print all previous commands used during the session.')\
		.register()

	self._console.add_command('commands', self, '_list_commands')\
		.set_description('Lists all available commands.')\
		.register()

	self._console.add_command('help', self, '_help')\
		.set_description('Outputs usage instructions.')\
		.add_argument('command', TYPE_STRING)\
		.register()

	self._console.add_command('quit', self, '_quit')\
		.set_description('Exit application.')\
		.register()

	self._console.add_command('clear', self._console)\
		.set_description('Clear the terminal.')\
		.register()

	self._console.add_command('version', self, '_version')\
		.set_description('Shows engine version.')\
		.register()

	self._console.add_command('fps_max', Engine, 'set_target_fps')\
		.set_description('The maximal framerate at which the application can run.')\
		.add_argument('fps', self._console.IntRangeType.new(10, 1000))\
		.register()

	self._console.add_command('bind', self, '_bind')\
		.set_description('Bind command to keyboard key')\
		.add_argument('key', TYPE_STRING)\
		.add_argument('cmd', TYPE_STRING)\
		.register()

	self._console.add_command('unbind', self, '_unbind')\
		.set_description('Remove currently bound command from keyboard key')\
		.add_argument('key', TYPE_STRING)\
		.register()

	self._console.add_command('binding', self, '_binding')\
		.set_description('Prints the command that is currently bound to a key')\
		.add_argument('key', TYPE_STRING)\
		.register()

	self._console.add_command('bindings', self, '_bindings')\
		.set_description('List key-command binding pairs')\
		.register()


# Display help message or display description for the command.
# @param    String|null  command_name
# @returns  void
func _help(command_name = null):
	if command_name:
		var command = self._console.get_command(command_name)

		if command:
			command.describe()
		else:
			self._console.Log.warn('No help for `' + command_name + '` command were found.')

	else:
		self._console.write_line(\
			"Type [color=#ffff66][url=help]help[/url] <command-name>[/color] show information about command.\n" + \
			"Type [color=#ffff66][url=commands]commands[/url][/color] to get a list of all commands.\n" + \
			"Type [color=#ffff66][url=quit]quit[/url][/color] to exit the application.")


# Prints out engine version.
# @returns  void
func _version():
	self._console.write_line(Engine.get_version_info())


# @returns  void
func _list_commands():
	for command in self._console._command_service.values():
		var name = command.get_name()
		self._console.write_line('[color=#ffff66][url=%s]%s[/url][/color]' % [ name, name ])
		
func _bind(key, cmd):
	var scancode = OS.find_scancode_from_string(key)
	if scancode != 0:
		self._console.bind_key_command(scancode, cmd)
	else:
		self._console.Log.error("Invalid key '%s' (no scancode found)" % key)
		
func _unbind(key):
	var scancode = OS.find_scancode_from_string(key)
	if scancode != 0:
		self._console.unbind_key(scancode)
	else:
		self._console.Log.error("Invalid key '%s' (no scancode found)" % key)
		
func _binding(key):
	var binds : Dictionary = self._console.bindings
	var key_code = OS.find_scancode_from_string(key)
	
	if binds.empty():
		self._console.Log.warn("No key-command bindings are currently set")
	elif key_code == 0:
		self._console.Log.error("Invalid key '%s' (no scancode found)" % key)
	else:
		var cmd = self._console.find_bound_command(key)
		
		if cmd:
			self._console.write_line("%s (%d) -> '%s'" % [key, key_code, cmd])
		else:
			self._console.write_line("No binding found for key %s (%d)" % [key, key_code])
		
func _bindings():
	var binds : Dictionary = self._console.bindings
	
	if binds.empty():
		self._console.Log.warn("No key-command bindings are currently set")
	else:
		self._console.write_line("%d bindings found:" % [len(binds)])
		for key_code in binds.keys():
			var key = OS.get_scancode_string(key_code)
			var cmd = binds[key_code]
			self._console.write_line("%s (%d) -> '%s'" % [ key, key_code, cmd ])

# Quitting application.
# @returns  void
func _quit():
	self._console.Log.warn('Quitting application...')
	self._console.get_tree().quit()
