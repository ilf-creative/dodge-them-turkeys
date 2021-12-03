class_name SettingsState

const _settings_file = "user://settings.save"
var most_gifts = 0
var longest_survival = 0	

func load_file():
	var f = File.new()
	if f.file_exists(_settings_file):
		f.open(_settings_file, File.READ)
		most_gifts = f.get_var()
		longest_survival = f.get_var()
		# self.enable_ads = f.get_var()
		f.close()
	return self
		
func save_file():
	var f = File.new()
	f.open(_settings_file, File.WRITE)
	f.store_var(most_gifts)
	f.store_var(longest_survival)
	# f.store_var(enable_ads)
	f.close()
