extends Area2D

@export var prompt_text := "Press E to interact"
@export var unlocked_message := "Door Unlocked!"
@export var locked_door_path: NodePath

@onready var prompt_label: Label = $PromptLabel
@onready var message_label: Label = $MessageLabel

var player_nearby := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.text = prompt_text
	prompt_label.visible = false
	message_label.visible = false


func _process(_delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("interact"):
		interact()


func interact() -> void:
	message_label.text = unlocked_message
	message_label.visible = true

	var locked_door := get_node_or_null(locked_door_path)
	if locked_door:
		locked_door.open()

	var level1_manager := get_tree().get_first_node_in_group("level1_manager")
	if level1_manager:
		level1_manager.on_door_unlocked()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_nearby = true
	prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_nearby = false
	prompt_label.visible = false
	message_label.visible = false
