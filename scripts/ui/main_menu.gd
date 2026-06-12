adadaadadextends Control

const LEVEL_1_PATH := "res://scenes/levels/Level1_ApartmentPanic.tscn"


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_build_menu()


func _build_menu() -> void:
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.06, 0.08, 0.13, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "THE FINAL EXAM RUN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 110
	title.offset_bottom = 180
	add_child(title)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.size = Vector2(320, 150)
	box.position = Vector2(-160, -20)
	box.add_theme_constant_override("separation", 16)
	add_child(box)

	var start_button := Button.new()
	start_button.text = "START GAME"
	start_button.custom_minimum_size = Vector2(320, 56)
	start_button.pressed.connect(_on_start_pressed)
	box.add_child(start_button)

	var quit_button := Button.new()
	quit_button.text = "QUIT"
	quit_button.custom_minimum_size = Vector2(320, 56)
	quit_button.pressed.connect(_on_quit_pressed)
	box.add_child(quit_button)


func _on_start_pressed() -> void:
	if GameManager.has_method("go_to_level_1"):
		GameManager.go_to_level_1()
	else:
		get_tree().change_scene_to_file(LEVEL_1_PATH)


func _on_quit_pressed() -> void:
	get_tree().quit()
