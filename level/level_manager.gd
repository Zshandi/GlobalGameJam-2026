extends Node

const level_complete_sfx = preload("res://assets/sfx/success.wav")

@export
var levels: Array[LevelData]

var level_node: Level:
	set(value):
		if level_node != null:
			level_node.level_complete.disconnect(_on_level_complete)
		level_node = value
		if level_node != null:
			level_node.level_complete.connect(_on_level_complete)

var current_level: int = -1

func _ready() -> void:
	var current_scene_path := get_tree().current_scene.scene_file_path
	var current_scene_file := current_scene_path.get_file()
	# When we load, just load the first level
	if current_level == -1:
		if not (get_tree().current_scene is Level):
			if current_scene_file == "main.tscn":
				load_level(0)
		else:
			level_node = get_tree().current_scene
			var idx = 0
			for level_data in levels:
				if level_data.scene.resource_path == current_scene_path:
					current_level = idx
				idx += 1

func _unhandled_key_input(_event: InputEvent) -> void:
	if %EndScreenLayer.visible:
		%EndScreenLayer.hide()
		load_level(0)

func load_level_from_scene(scene_file: String) -> void:
	for idx in range(len(levels)):
		var level := levels[idx]
		if level.get_scene_filename() == scene_file:
			load_level(idx)

func load_level(idx: int) -> void:
	current_level = idx
	if current_level >= len(levels):
		# TODO: Go to end menu
		%EndScreenLayer.show()
		level_node = null
		SaveProgress.save_level(levels[0].get_scene_filename())
		return
	
	SaveProgress.save_level(levels[current_level].get_scene_filename())
	level_node = levels[current_level].scene.instantiate()
	get_tree().change_scene_to_node.call_deferred(level_node)

func reload_level() -> void:
	level_node = null
	get_tree().reload_current_scene()
	await get_tree().create_timer(0.1).timeout
	level_node = get_tree().current_scene

func _on_level_complete() -> void:
	# TODO: Show win screen with option to go to next level
	if current_level == -1:
		reload_level()
	else:
		SaveProgress.set_level_completed(levels[current_level].get_scene_filename())
		load_level(current_level + 1)

func load_main_menu():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")