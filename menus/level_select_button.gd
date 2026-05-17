@tool
extends Button
class_name LevelSelectButton

@export
var level_number: int:
	set(value):
		level_number = value
		text = str(value)

@export
var is_level_complete: bool:
	set(value):
		is_level_complete = value
		%LevelCompletedIndicator.visible = value

func _on_pressed() -> void:
	# The levels are 0 indexed, but the "level_number" value is 1 indexed
	LevelManager.load_level(level_number - 1)
