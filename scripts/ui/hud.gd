extends CanvasLayer

# Runtime HUD using the blue UI assets.
# This version uses manual positioning instead of VBoxContainer,
# so the small HUD boxes stay small while the objective bar stays wider.

const PANEL_BLUE_TEXTURE := "res://assets/ui/hud_panel_blue.png"
const PANEL_RED_TEXTURE := "res://assets/ui/hud_panel_red.png"
const ICON_COFFEE_TEXTURE := "res://assets/ui/hud_coffee.png"
const ICON_STUDENT_ID_TEXTURE := "res://assets/ui/hud_student_id.png"
const ICON_STUDY_NOTE_TEXTURE := "res://assets/ui/hud_study_note.png"

const SMALL_ROW_SIZE := Vector2(190, 30)
const OBJECTIVE_ROW_SIZE := Vector2(390, 34)

const HUD_X := 10
const HUD_Y := 10
const HUD_GAP := 5

var runtime_root: Control

var time_label: Label
var focus_label: Label
var notes_label: Label
var coffee_label: Label
var student_id_label: Label
var objective_label: Label

var main_menu_button: Button

var low_focus_panel: NinePatchRect
var low_focus_label: Label

var focus_feedback_panel: NinePatchRect
var focus_feedback_label: Label
var focus_feedback_time_remaining := 0.0

var result_panel: NinePatchRect
var result_label: Label


func _ready() -> void:
	_hide_old_hud_children()
	_build_runtime_hud()

	if not GameManager.focus_changed.is_connected(_on_focus_changed):
		GameManager.focus_changed.connect(_on_focus_changed)

	if not GameManager.level_finished.is_connected(_on_level_finished):
		GameManager.level_finished.connect(_on_level_finished)

	result_panel.visible = false


func _process(delta: float) -> void:
	time_label.text = "Time: %d" % ceili(GameManager.time_remaining)
	focus_label.text = "Focus: %d" % GameManager.focus
	notes_label.text = "Notes: %d" % GameManager.notes_collected
	coffee_label.text = "Coffee: %d" % GameManager.coffee_collected
	student_id_label.text = "Student ID: %s" % ("Yes" if GameManager.has_student_id else "No")
	objective_label.text = "Objective: %s" % GameManager.current_objective

	low_focus_panel.visible = GameManager.focus <= 40

	if focus_feedback_time_remaining > 0.0:
		focus_feedback_time_remaining = maxf(focus_feedback_time_remaining - delta, 0.0)
		focus_feedback_panel.visible = focus_feedback_time_remaining > 0.0
	else:
		focus_feedback_panel.visible = false


func _hide_old_hud_children() -> void:
	for child in get_children():
		if child is CanvasItem:
			child.visible = false


func _build_runtime_hud() -> void:
	runtime_root = Control.new()
	runtime_root.name = "RuntimeHUDRoot"
	runtime_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	runtime_root.visible = true
	add_child(runtime_root)

	var current_y := HUD_Y

	time_label = _create_hud_row(
		Vector2(HUD_X, current_y),
		SMALL_ROW_SIZE,
		"Time: 180",
		""
	)

	current_y += SMALL_ROW_SIZE.y + HUD_GAP

	focus_label = _create_hud_row(
		Vector2(HUD_X, current_y),
		SMALL_ROW_SIZE,
		"Focus: 100",
		"star"
	)

	current_y += SMALL_ROW_SIZE.y + HUD_GAP

	notes_label = _create_hud_row(
		Vector2(HUD_X, current_y),
		SMALL_ROW_SIZE,
		"Notes: 0",
		ICON_STUDY_NOTE_TEXTURE
	)

	current_y += SMALL_ROW_SIZE.y + HUD_GAP

	coffee_label = _create_hud_row(
		Vector2(HUD_X, current_y),
		SMALL_ROW_SIZE,
		"Coffee: 0",
		ICON_COFFEE_TEXTURE
	)

	current_y += SMALL_ROW_SIZE.y + HUD_GAP

	student_id_label = _create_hud_row(
		Vector2(HUD_X, current_y),
		SMALL_ROW_SIZE,
		"Student ID: No",
		ICON_STUDENT_ID_TEXTURE
	)

	current_y += SMALL_ROW_SIZE.y + HUD_GAP

	objective_label = _create_hud_row(
		Vector2(HUD_X, current_y),
		OBJECTIVE_ROW_SIZE,
		"Objective: Enter the Exam Hall",
		""
	)

	_create_low_focus_panel(current_y + OBJECTIVE_ROW_SIZE.y + 10)
	_create_focus_feedback_panel(current_y + OBJECTIVE_ROW_SIZE.y + 47)
	_create_result_panel()


func _create_hud_row(row_position: Vector2, row_size: Vector2, text_value: String, icon_path: String) -> Label:
	var panel := NinePatchRect.new()
	panel.name = text_value.get_slice(":", 0).replace(" ", "") + "Panel"
	panel.texture = load(PANEL_BLUE_TEXTURE)
	panel.position = row_position
	panel.size = row_size
	panel.custom_minimum_size = row_size
	panel.patch_margin_left = 8
	panel.patch_margin_top = 8
	panel.patch_margin_right = 8
	panel.patch_margin_bottom = 8
	runtime_root.add_child(panel)

	var label_x := 10

	if icon_path != "":
		if icon_path == "star":
			var star_label := Label.new()
			star_label.name = "FocusStarIcon"
			star_label.text = "★"
			star_label.position = Vector2(12, 5)
			star_label.size = Vector2(18, 20)
			star_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			star_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			star_label.add_theme_font_size_override("font_size", 14)
			panel.add_child(star_label)
		else:
			var icon := TextureRect.new()
			icon.name = "Icon"
			icon.texture = load(icon_path)
			icon.position = Vector2(13, 8)
			icon.size = Vector2(13, 13)
			icon.custom_minimum_size = Vector2(13, 13)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			panel.add_child(icon)

		label_x = 36

	var label := Label.new()
	label.name = "Label"
	label.text = text_value
	label.position = Vector2(label_x, 3)
	label.size = Vector2(row_size.x - label_x - 8, row_size.y - 6)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	panel.add_child(label)

	return label


func _create_low_focus_panel(y_position: float) -> void:
	low_focus_panel = NinePatchRect.new()
	low_focus_panel.name = "LowFocusPanel"
	low_focus_panel.texture = load(PANEL_RED_TEXTURE) if ResourceLoader.exists(PANEL_RED_TEXTURE) else load(PANEL_BLUE_TEXTURE)
	low_focus_panel.position = Vector2(HUD_X, y_position)
	low_focus_panel.size = SMALL_ROW_SIZE
	low_focus_panel.patch_margin_left = 8
	low_focus_panel.patch_margin_top = 8
	low_focus_panel.patch_margin_right = 8
	low_focus_panel.patch_margin_bottom = 8
	low_focus_panel.visible = false
	runtime_root.add_child(low_focus_panel)

	low_focus_label = Label.new()
	low_focus_label.name = "LowFocusLabel"
	low_focus_label.text = "LOW FOCUS!"
	low_focus_label.position = Vector2(8, 3)
	low_focus_label.size = Vector2(SMALL_ROW_SIZE.x - 16, SMALL_ROW_SIZE.y - 6)
	low_focus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	low_focus_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	low_focus_label.add_theme_font_size_override("font_size", 14)
	low_focus_panel.add_child(low_focus_label)


func _create_focus_feedback_panel(y_position: float) -> void:
	focus_feedback_panel = NinePatchRect.new()
	focus_feedback_panel.name = "FocusFeedbackPanel"
	focus_feedback_panel.texture = load(PANEL_BLUE_TEXTURE)
	focus_feedback_panel.position = Vector2(HUD_X, y_position)
	focus_feedback_panel.size = SMALL_ROW_SIZE
	focus_feedback_panel.patch_margin_left = 8
	focus_feedback_panel.patch_margin_top = 8
	focus_feedback_panel.patch_margin_right = 8
	focus_feedback_panel.patch_margin_bottom = 8
	focus_feedback_panel.visible = false
	runtime_root.add_child(focus_feedback_panel)

	focus_feedback_label = Label.new()
	focus_feedback_label.name = "FocusFeedbackLabel"
	focus_feedback_label.text = "Focus -10"
	focus_feedback_label.position = Vector2(8, 3)
	focus_feedback_label.size = Vector2(SMALL_ROW_SIZE.x - 16, SMALL_ROW_SIZE.y - 6)
	focus_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	focus_feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	focus_feedback_label.add_theme_font_size_override("font_size", 14)
	focus_feedback_panel.add_child(focus_feedback_label)


func _create_result_panel() -> void:
	result_panel = NinePatchRect.new()
	result_panel.name = "ResultPanel"
	result_panel.texture = load(PANEL_BLUE_TEXTURE)
	result_panel.patch_margin_left = 12
	result_panel.patch_margin_top = 12
	result_panel.patch_margin_right = 12
	result_panel.patch_margin_bottom = 12
	result_panel.size = Vector2(700, 430)
	result_panel.visible = false
	runtime_root.add_child(result_panel)

	call_deferred("_center_result_panel")

	result_label = Label.new()
	result_label.name = "ResultLabel"
	result_label.text = ""
	result_label.position = Vector2(35, 28)
	result_label.size = Vector2(630, 380)
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 17)
	result_panel.add_child(result_label)

	main_menu_button = Button.new()
	main_menu_button.name = "MainMenuButton"
	main_menu_button.text = "Main Menu"
	main_menu_button.position = Vector2(250, 375)
	main_menu_button.size = Vector2(200, 42)
	main_menu_button.visible = false
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	result_panel.add_child(main_menu_button)


func _center_result_panel() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	result_panel.position = (viewport_size - result_panel.size) * 0.5


func _on_focus_changed(amount: int, _new_focus: int) -> void:
	if amount > 0:
		focus_feedback_label.text = "Focus +%d" % amount
	else:
		focus_feedback_label.text = "Focus %d" % amount

	focus_feedback_panel.visible = true
	focus_feedback_time_remaining = 1.0


func _on_level_finished(state: String) -> void:
	show_result_panel(state)


func show_result_panel(state: String) -> void:
	var student_id_text := "Yes" if GameManager.has_student_id else "No"
	var rank := GameManager.get_current_level_rank()
	var level_name := GameManager.current_level_display_name

	var ending_section := ""

	if "final_ending_title" in GameManager and GameManager.final_ending_title != "":
		ending_section = "\nEnding: %s\n%s\n" % [
			GameManager.final_ending_title,
			GameManager.final_ending_description
		]

	if state == GameManager.LEVEL_STATE_FAILED:
		result_label.text = "Time's Up!\nMissed Exam\n%s\nTime Remaining: 0\nFocus: %d\nNotes Collected: %d\nCoffee Collected: %d\nStudent ID: %s\nRank: %s\n\nPress R to Restart" % [
			ending_section,
			GameManager.focus,
			GameManager.notes_collected,
			GameManager.coffee_collected,
			student_id_text,
			rank
		]
	else:
		result_label.text = "%s Complete\n%s\nTime Remaining: %d\nFocus: %d\nNotes Collected: %d\nCoffee Collected: %d\nStudent ID: %s\nRank: %s\n\nPress R to Restart" % [
			level_name,
			ending_section,
			ceili(GameManager.time_remaining),
			GameManager.focus,
			GameManager.notes_collected,
			GameManager.coffee_collected,
			student_id_text,
			rank
		]

	_center_result_panel()
	if main_menu_button != null:
		main_menu_button.visible = GameManager.current_level_display_name == "Level 3"
	result_panel.visible = true

func _on_main_menu_pressed() -> void:
	if GameManager.has_method("go_to_main_menu"):
		GameManager.go_to_main_menu()
	else:
		get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
