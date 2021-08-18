extends Node2D

signal option_selected(selected_option)

const SPEED = 150
const Y_POS = 122
const FACING_RIGHT = 1
const FACING_LEFT = -1

# animation states
enum {
	IDLE,
	MOVE_LEFT,
	MOVE_RIGHT,
	HIT,
}

# locations
enum {
	LEFT,
	MIDDLE,
	RIGHT
}

var _direction := Vector2.ZERO
var _state := 0
var _new_anim := ""
var _cur_anim := ""
var _locations := [93, 285, 477]
var _final_position := 0
var _can_move := true
var _paused := false


func _ready():
	position = Vector2(_locations[LEFT], Y_POS)
	_final_position = _locations[LEFT]
	set_process(false)


func _process(delta):
	if _new_anim != _cur_anim:
		_cur_anim = _new_anim
		$AnimationPlayer.play(_cur_anim)

	_process_input()
	if _state == MOVE_RIGHT and position.x < _final_position:
		_update_position(delta)
	elif _state == MOVE_LEFT and position.x > _final_position:
		_update_position(delta)
	else:
		if _state != HIT:
			_transition_to(IDLE)


func _update_position(delta)->void:
	position.x += SPEED * _direction.x * delta


func _process_input():
	if !_can_move:
		return
	if _paused:
		return

	_direction = Vector2.ZERO
	var _hitted = Input.is_action_just_pressed("hit")

	var _left = Input.is_action_just_pressed("ui_left")
	var _right = Input.is_action_just_pressed("ui_right")

	if _state == IDLE and _hitted:
		_transition_to(HIT)

	if _left:
		$Sprite.scale.x = FACING_LEFT
		_direction.x = FACING_LEFT
		_calculate_final_position()
		_transition_to(MOVE_LEFT)

	if _right:
		$Sprite.scale.x = FACING_RIGHT
		_direction.x = FACING_RIGHT
		_calculate_final_position()
		_transition_to(MOVE_RIGHT)


func _calculate_final_position()->void:
	if _direction.x == FACING_RIGHT:
		if _locations[MIDDLE] > _final_position:
			_final_position = _locations[MIDDLE]
		elif _locations[RIGHT] > _final_position:
			_final_position = _locations[RIGHT]
		else:
			_can_move = true
	elif _direction.x == FACING_LEFT:
		if _locations[MIDDLE] < _final_position:
			_final_position = _locations[MIDDLE]
		elif _locations[LEFT] < _final_position:
			_final_position = _locations[LEFT]
		else:
			_can_move = false


func _transition_to(state:int)->void:
	_state = state
	_can_move = false
	match _state:
		IDLE:
			_new_anim = "Idle"
			_can_move = true
		MOVE_LEFT, MOVE_RIGHT:
			_new_anim = "Moving"
		HIT:
			_new_anim = "Hit"


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Hit":
		emit_signal("option_selected", _selected_option())
		_transition_to(IDLE)


func _selected_option()->int:
	if _final_position == _locations[LEFT]:
		return LEFT
	elif _final_position == _locations[MIDDLE]:
		return MIDDLE
	else:
		return RIGHT


func pause()->void:
	_paused = true
	set_process(false)


func resume()->void:
	_paused = false
	set_process(true)
