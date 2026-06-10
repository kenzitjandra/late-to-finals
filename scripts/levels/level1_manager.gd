extends Node2D

const GROUP_NAME := "level1_manager"
const STAGE_STUDENT_ID := 0
const STAGE_STUDY_NOTE := 1
const STAGE_SECURITY_GUARD := 2
const STAGE_UNLOCK_DOOR := 3
const STAGE_CROSS_TRAFFIC := 4
const STAGE_REACH_BUS_STOP := 5
const OBJECTIVES := [
	"Get your Student ID",
	"Collect a Study Note",
	"Talk to the Security Guard",
	"Unlock the Door",
	"Cross the Traffic",
	"Reach the Bus Stop",
]
const TRAFFIC_CROSSED_X := 2720.0

var objective_stage := STAGE_STUDENT_ID


func _ready() -> void:
	add_to_group(GROUP_NAME)
	GameManager.set_objective(OBJECTIVES[objective_stage])


func _process(_delta: float) -> void:
	if objective_stage != STAGE_CROSS_TRAFFIC or not GameManager.is_level_active():
		return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	# Temporary pre-layout prototype check for the current ground testing lane only.
	if player.global_position.x >= TRAFFIC_CROSSED_X:
		_advance_to_stage(STAGE_REACH_BUS_STOP)


func on_student_id_collected() -> void:
	_advance_to_stage(STAGE_STUDY_NOTE)


func on_study_note_collected() -> void:
	_advance_to_stage(STAGE_SECURITY_GUARD)


func on_security_guard_passed() -> void:
	_advance_to_stage(STAGE_UNLOCK_DOOR)


func on_door_unlocked() -> void:
	_advance_to_stage(STAGE_CROSS_TRAFFIC)


func _advance_to_stage(next_stage: int) -> void:
	if next_stage <= objective_stage:
		return

	objective_stage = next_stage
	GameManager.set_objective(OBJECTIVES[objective_stage])
