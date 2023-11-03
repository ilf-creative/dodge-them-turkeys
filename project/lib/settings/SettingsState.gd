class_name SettingsState

const _settings_file = "user://settings.save"
var most_gifts = 0
var longest_survival = 0
var bonus_hats = 0

func load_file():
	if FileAccess.file_exists(_settings_file):
		var f = FileAccess.open(_settings_file, FileAccess.READ)
		most_gifts = Utils.or_default(f.get_var(), 0)
		longest_survival = Utils.or_default(f.get_var(), 0)
		bonus_hats = Utils.or_default(f.get_var(), 0)
		# self.enable_ads = f.get_var()
		f.close()
	return self
		
func save_file():
	var f = FileAccess.open(_settings_file, FileAccess.WRITE)
	f.store_var(most_gifts)
	f.store_var(longest_survival)
	f.store_var(bonus_hats)
	# f.store_var(enable_ads)
	f.close()

