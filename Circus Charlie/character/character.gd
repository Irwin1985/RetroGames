extends KinematicBody2D
class_name Player

signal win

export (int) var speed
export (bool) var can_jump
export (int) var jump_power
export (int) var gravity
export (bool) var use_charlie = false

var motion = Vector2()
var hanging : bool = false
var jumping = false
var last_swing : Swing = null


func _ready():
	$JumpSound.volume_db = global.STANDARD_VOLUME
	if !can_jump:
		set_physics_process(false)


func _physics_process(delta):	
	if hanging:
		var pos_offset : Vector2 = Vector2(-18, 8)
		position = last_swing.get_grab_bar_position() + pos_offset
		if Input.is_action_pressed("game_jump"):
			hanging = false
			motion = last_swing.get_tangential_speed()
			jump()
	else:
		motion.y += gravity
		if !jumping:
			if Input.is_action_pressed("ui_right"):
				motion.x = speed
				animate("run")
			elif Input.is_action_pressed("ui_left"):
				motion.x = -speed
				animate("run_back")
			else:
				motion.x = 0
				animate("idle")
		if is_on_floor():
			jumping = false
			if Input.is_action_pressed("ui_up"):
				motion.y = -jump_power
				jump()
				if Input.is_action_pressed("ui_right"):
					motion.x = speed
				elif Input.is_action_pressed("ui_left"):
					motion.x = -speed
				else:
					motion.x = 0
		motion = move_and_slide(motion, Vector2.UP)

func jump()->void:
	jumping = true
	$JumpSound.play()
	animate("jump")

func animate(state):
	$AnimatedSprite.animation = state
	if use_charlie:
		$Charlie.animation = state

func take_swing(swing : Swing)->void:
	if last_swing != null and last_swing != swing:
		last_swing.enable_bar()
	hanging = true
	jumping = false
	animate("swing")
	$AnimatedSprite.set_speed_scale(swing.get_speed())
	$AnimatedSprite.set_frame( \
		$AnimatedSprite.get_sprite_frames().get_frame_count("swing") * \
		swing.get_swing_position() / 4)
	last_swing = swing
	
func bounce_trampoline()->void:
	if last_swing != null:
		last_swing.enable_bar()
		last_swing = null
	if Input.is_action_pressed("game_left"):
		motion = Vector2(-100, -500)
	elif Input.is_action_pressed("game_right"):
		motion = Vector2(100, -500)
	else:
		motion = Vector2(0, -500)
		
func hurt():
	stop()
	animate("hurt")

func stop():
	set_physics_process(false)

func win():
	emit_signal("win")
	if use_charlie:
		$Charlie.animation = "win"
	$AnimatedSprite.animation = "idle"
	set_physics_process(false)