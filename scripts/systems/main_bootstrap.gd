extends Node

const LEVEL_1_SCENE := "res://scenes/levels/Level1_ApartmentPanic.tscn"


func _ready() -> void:
	GameManager.reset_level_1_state()
	get_tree().change_scene_to_file.call_deferred(LEVEL_1_SCENE)
