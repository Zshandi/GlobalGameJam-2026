extends CenterContainer

signal closed

func _ready() -> void:
	update_levels()

func update_levels() -> void:
	for child in %LevelSelectButtonsContainer.get_children():
		%LevelSelectButtonsContainer.remove_child(child)
		child.queue_free()
	
	var current_level_scene = SaveProgress.get_saved_level()
	var idx = 1
	for level in LevelManager.levels:
		var level_select_button: LevelSelectButton = preload("res://menus/level_select_button.tscn").instantiate()
		level_select_button.level_number = idx
		level_select_button.is_level_complete = SaveProgress.is_level_completed(level.get_scene_filename())

		%LevelSelectButtonsContainer.add_child(level_select_button)

		if (current_level_scene == "" and idx == 1) or current_level_scene == level.get_scene_filename():
			level_select_button.grab_focus()

		idx += 1

func _on_back_button_pressed() -> void:
	self.visible = false

func _on_visibility_changed() -> void:
	if not visible:
		closed.emit()
	else:
		update_levels()
