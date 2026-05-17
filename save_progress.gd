extends Node

var current_level: String = ""
var completed_levels: Dictionary[String, bool] = {}

func erase_save_data() -> void:
	current_level = ""
	completed_levels = {}
	write_progress()

func set_level_completed(level_id: String) -> void:
	if not level_id in completed_levels:
		completed_levels[level_id] = true
	write_progress()

func is_level_completed(level_id: String) -> bool:
	read_progress()
	if level_id in completed_levels:
		return completed_levels[level_id]
	else:
		return false

func save_level(level_id: String) -> void:
	current_level = level_id
	write_progress()

func get_saved_level() -> String:
	read_progress()
	return current_level

func read_progress() -> void:
	if FileAccess.file_exists("user://save_data"):
		var save_file := FileAccess.open("user://save_data", FileAccess.READ)
		var save_data = save_file.get_var()
		current_level = save_data["level"]
		completed_levels = save_data["completed_levels"]

func write_progress() -> void:
	var save_file := FileAccess.open("user://save_data", FileAccess.WRITE)
	save_file.store_var(
		{
			"level": current_level,
			"completed_levels": completed_levels,
		}
	)
