extends Area2D

signal wanted_climb(this, dir)
signal ready_to_go

enum {
		IDLE, 
		DOWN_IDLE,
		WALK, 
		STAIR,
	}

var _direction := Vector2.ZERO
var _final_pos := Vector2.ZERO
var _speed := 30.0
var _gravity := 20.0
var _old_gravity = _gravity
var _can_move := true
var _state
var _anim
var _new_anim
var _instructions := []


func _ready():
	set_physics_process(false)
	_change_state(IDLE)


func _process(delta):
	if _new_anim != _anim:
		_anim = _new_anim
		$AnimationPlayer.play(_anim)

	if _can_move:
		_execute_instruction()

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
			_gravity = _old_gravity
			_reset_direction()

	elif _direction.y == Global.MOVE_UP:
		if int(position.y) > _final_pos.y:
			_update_y_position(delta)
		else:
			_reset_direction()

	else:
		_change_state(IDLE)


func _execute_instruction()->void:
	var _ins = get_next_instruction()
	if _ins == "":
		return

	if _ins == "move left":
		_update_x_movement(Global.MOVE_LEFT)

	elif _ins == "move right":
		_update_x_movement(Global.MOVE_RIGHT)

	elif _ins == "go up":
		emit_signal("wanted_climb", self, Global.MOVE_UP)

	elif _ins == "go down":
		emit_signal("wanted_climb", self, Global.MOVE_DOWN)

	elif _ins == "down idle":
		_go_down_to_first_floor()


func _change_state(new_state)->void:
	_state = new_state
	match _state:
		IDLE:
			_new_anim = "Idle"
			_can_move = true
		DOWN_IDLE:
			_new_anim = "DownIdle"
		WALK:
			_new_anim = "Walk"
		STAIR:
			_new_anim = "Stairs"


func _go_down_to_first_floor()->void:
	_final_pos.y = Global.y_positions[Global.PRIMER_PISO]
	_direction.y = Global.MOVE_DOWN
	_change_state(DOWN_IDLE)
	_gravity *= 2
	_can_move = false


func alter_grativi_by_percent(percent:int)->void:
	var _rate:float = 1.0 + round(percent/100)
	_gravity = _gravity + (_gravity * _rate)


func down_stairs()->void:
	_update_y_movement(Global.MOVE_DOWN)


func up_stairs()->void:
	_update_y_movement(Global.MOVE_UP)


func set_speed(new_speed:int)->void:
	_speed = new_speed


func _update_x_movement(dir:int)->void:
	_can_move = false
	if dir == 1:
		$Sprite.scale.x = -1
	else:
		$Sprite.scale.x = 1

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


"""
Funciones helper para las instrucciones
"""
func add_instruction(instruction:String)->void:
	_instructions.append(instruction)


func get_next_instruction()->String:
	var _ins = _instructions.pop_front()
	if _ins != null:
		return _ins
	return ""


func is_idle()->bool:
	return _state == IDLE


func is_walking()->bool:
	return _state == WALK


func facing()->int:
	return $Sprite.scale.x


func win()->void:
	_reset_direction()
	_can_move = false
	_final_pos.x = position.x
	_change_state(IDLE)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "DownIdle":
		emit_signal("ready_to_go")


func drop_instructions()->void:
	_reset_direction()
	_instructions.clear()
