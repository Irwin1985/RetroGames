extends KinematicBody2D

signal bomb_planted
signal died

const LEFT_UP_FRAME = 6 #frame 6 Atras, Arriba
const RIGHT_UP_FRAME = 8 #frame 8 Alante, Arriba
const LEFT_DOWN_FRAME = 0 #frame 0 Atras, Abajo
const RIGHT_DOWN_FRAME = 2 #frame 2 Alante, Abajo

const LEFT_DIR = -1
const RIGHT_DIR = 1
const UP_DIR = -1
const DOWN_DIR = 1

enum {
	START,
	IDLE,
	LEFT,
	RIGHT,
	UP,
	DOWN,
	DIE,
}

var _cur_anim:String
var _new_anim:String
var _state:int
var _speed:float = 50.0
var _direction:Vector2
var _facing:int
var _sliding:bool


func _physics_process(_delta: float) -> void:
	_direction = Vector2()
	if _cur_anim != _new_anim:
		_cur_anim = _new_anim
		$AnimationPlayer.play(_cur_anim)
	_get_input()
	move_and_slide(_direction * _speed)


func _get_input() -> void:
	var _left = Input.is_action_pressed("ui_left") or Input.is_action_pressed("left")
	var _right = Input.is_action_pressed("ui_right") or Input.is_action_pressed("right")
	var _up = Input.is_action_pressed("ui_up") or Input.is_action_pressed("up")
	var _down = Input.is_action_pressed("ui_down") or Input.is_action_pressed("down")
	var _bomb_planted = Input.is_action_just_pressed("button_a")
	var _count:int = 0

	if _left:
		_count += 1
		_direction.x = -1
		_facing = LEFT_DIR
		_transition(LEFT)

	if _right:
		_count += 1
		_direction.x = 1
		_facing = RIGHT_DIR
		_transition(RIGHT)

	if _up:
		_count += 1
		_direction.y = -1
		_transition(UP)

	if _down:
		_count += 1
		_direction.y = 1
		_transition(DOWN)
	
	if _direction.length() == 0:
		_transition(IDLE)
	
	_sliding = _count == 2
	
	if _bomb_planted:
		emit_signal("bomb_planted")
		$BombPlantSound.play()


func _transition(new_state:int) -> void:
	_state = new_state
	$AnimationPlayer.play(_cur_anim)
	$Sprite.flip_h = _facing == RIGHT_DIR
	match _state:
		START:
			_new_anim = 'start'
			scale = Vector2(-1, 1)
		IDLE:
			_stop_sounds()
		LEFT, RIGHT:
			_new_anim = 'walk'
			_play_sound()
		UP:
			_new_anim = 'up'
			_play_sound()
		DOWN:
			_new_anim = 'down'
			_play_sound()
		DIE:
			_new_anim = 'die'
		_:
			_new_anim = 'idle'


func _play_sound() -> void:
	if _sliding:
		$WalkingSound.stop()
		$UpDownSound.stop()
		if !$SlideSound.playing:
			$SlideSound.play()
		$Sprite.frame = _get_frame()
		$AnimationPlayer.stop()
	else:
		$SlideSound.stop()
		match _new_anim:
			'up', 'down':
				$WalkingSound.stop()
				if !$UpDownSound.playing:
					$UpDownSound.play()
			'walk':
				$UpDownSound.stop()
				if !$WalkingSound.playing:
					$WalkingSound.play()


func _stop_sounds() -> void:
	$AnimationPlayer.stop()
	$WalkingSound.stop()
	$UpDownSound.stop()
	$SlideSound.stop()


func start(new_position:Vector2) -> void:
	position = new_position
	_transition(START)


func die() -> void:
	$AnimationPlayer.playback_speed = 0.6
	_transition(DIE)
	$DeadSound.play()
	emit_signal("died")


func _get_frame() -> int:
	var x_coord := _direction.x
	var y_coord := _direction.y
	if x_coord == LEFT_DIR:
		if y_coord == UP_DIR:
			return LEFT_UP_FRAME
		elif y_coord == DOWN_DIR:
			return LEFT_DOWN_FRAME
	if x_coord == RIGHT_DIR:
		if y_coord == UP_DIR:
			return RIGHT_UP_FRAME
		elif y_coord == DOWN_DIR:
			return RIGHT_DOWN_FRAME
	return 0
