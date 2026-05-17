extends CanvasLayer

func _ready() -> void:
	%StartButton.grab_focus()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_start_button_pressed() -> void:
	var current_level = SaveProgress.get_saved_level()
	if current_level != "":
		LevelManager.load_level_from_scene(current_level)
	else:
		LevelManager.load_level(0)

func _on_options_button_pressed() -> void:
	%MainMenu.hide()
	%OptionsMenu.show()

func _on_level_select_button_pressed() -> void:
	%MainMenu.hide()
	%LevelSelectMenu.show()

func _on_options_menu_closed() -> void:
	%OptionsMenu.hide()
	%MainMenu.show()
	%OptionsButton.grab_focus()

func _on_level_select_menu_closed() -> void:
	%LevelSelectMenu.hide()
	%MainMenu.show()
	%LevelSelectButton.grab_focus()
