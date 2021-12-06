class_name Settings

static func load_settings():
	return SettingsState.new().load_file()
