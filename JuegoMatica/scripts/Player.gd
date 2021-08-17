extends Area2D

signal wanted_climb(this, dir)
signal dead
signal dancing_done

enum {
		IDLE, 
		WALK, 
		PUSH_SWITCH, 
		SAY_NO,
		DANCING, 
		STAIR, 
		DEAD,
	}


var _direction := Vector2.ZERO
var _final_pos := Vector2.ZERO
var _speed := 90.0
var _gravity := 40.0
var _can_move := true
var _can_switch := false
var _interruptor_obj = null
var _state
var _anim
var _new_anim


func _ready():
	position = Vector2(Global.x_positions[0], Global.y_positions[0])
	_change_state(IDLE)


func _unhandled_input(event):
	if !_can_move:
		return

	if event is InputEventKey:
		var _just_pressed = event.is_pressed() and !event.is_echo()

		if event.pressed and event.scancode == KEY_LEFT:
			_update_x_movement(Global.MOVE_LEFT)

		if event.pressed and event.scancode == KEY_RIGHT:
			_update_x_movement(Global.MOVE_RIGHT)
		
		if _can_switch and event.scancode == KEY_SPACE and _just_pressed:
			push_switch()

		if event.scancode == KEY_DOWN:
			emit_signal("wanted_climb", self, Global.MOVE_DOWN)

		if event.scancode == KEY_UP:
			emit_signal("wanted_climb", self, Global.MOVE_UP)


func _process(delta):
	if _new_anim != _anim:
		_anim = _new_anim
		$AnimationPlayer.play(_anim)

	if _direction.x == Global.MOVE_RIGHT:
		if int(position.x) < _final_pos.x:
			_update_x_position(delta)
		else:
			_reset_direction()

	elif _direction.x == Global.MOVE_LEFT:
		if int(position.x) > _final_pos.x:
			_update_x_position(delta)
		else:
			_reset_direction()

	elif _direction.y == Global.MOVE_DOWN:
		if int(position.y) < _final_pos.y:
			_update_y_position(delta)
		else:
			_reset_direction()

	elif _direction.y == Global.MOVE_UP:
		if int(position.y) > _final_pos.y:
			_update_y_position(delta)
		else:
			_reset_direction()

	else:
		if !_state in [PUSH_SWITCH, SAY_NO, DANCING, DEAD]:
			_change_state(IDLE)


func _reset_direction()->void:
	if _direction.x != 0:
		position.x = _final_pos.x
		_direction.x = 0
	elif _direction.y != 0:
		position.y = _final_pos.y
		_direction.y = 0
		
	_change_state(IDLE)	


func _update_x_position(delta:float)->void:
	position.x += _speed * _direction.x * delta


func _update_y_position(delta:float)->void:
	position.y += _gravity * _direction.y * delta


func _update_x_movement(dir:int)->void:
	_can_move = false
	scale.x = dir
	_direction.x = dir
	_final_pos.x = Global.get_final_x_position(position.x, _direction.x)

	if _final_pos.x != int(position.x):
		_change_state(WALK)


func _update_y_movement(dir:int)->void:
	_can_move = false
	_direction.y = dir
	_final_pos.y = Global.get_final_y_position(position.y, _direction.y)

	if _final_pos.y != int(position.y):
		_change_state(STAIR)


func _change_state(new_state)->void:
	_state = new_state
	match _state:
		IDLE:
			_new_anim = "Idle"
			_can_move = true
		WALK:
			_new_anim = "Walk"
		PUSH_SWITCH:
			_new_anim = "PushSwitch"
		STAIR:
			_new_anim = "Stairs"
		DANCING:
			_new_anim = "Dancing"
		SAY_NO:
			_new_anim = "SayNo"
		DEAD:
			_new_anim = "Dead"


func set_speed(new_speed:int)->void:
	_speed = new_speed


func push_switch()->void:
	if _interruptor_obj != null:
		if !_interruptor_obj.is_resolved():
			scale.x = 1
			_interruptor_obj.compare_result()
		else:
			_change_state(SAY_NO)


func down_stairs()->void:
	_update_y_movement(Global.MOVE_DOWN)


func up_stairs()->void:
	_update_y_movement(Global.MOVE_UP)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "PushSwitch" or anim_name == "SayNo":
		_change_state(IDLE)
	elif anim_name == "Dancing":
		emit_signal("dancing_done")


func _on_Player_area_entered(area):
	if area.is_in_group("interruptor"):
		_can_switch = true
		_interruptor_obj = area
	elif area.is_in_group("enemy"):
		emit_signal("dead")


func _on_Player_area_exited(area):
	if area.is_in_group("interruptor"):
		_can_switch = false
		_interruptor_obj = null


func animate_switch()->void:
	_can_move = false
	_change_state(PUSH_SWITCH)


func animate_say_no()->void:
	_can_move = false
	_change_state(SAY_NO)


func animate_dead(direction:int)->void:
	_reset_direction()
	_can_move = false
	_final_pos.x = position.x
	if direction == Global.MOVE_RIGHT:
		scale.x = -1
	_change_state(DEAD)


func animate_idle()->void:
	scale.x = 1
	$Sprite.flip_h = false
	_change_state(IDLE)


func win()->void:
	_can_move = false
	_change_state(DANCING)
