extends KinematicBody2D

export (int) var speed
export (bool) var can_jump
export (int) var jump_power
export (int) var gravity
export (AudioStreamSample) var jump_sound
export (bool) var use_charlie = false

signal win

var motion = Vector2()
var keep_moving_right = false
var keep_moving_left = false
var sound_played = true

func _ready():
	if !can_jump:
		set_physics_process(false)
		
func _physics_process(delta):	
	motion.y += gravity
	if Input.is_action_pressed("ui_right") or keep_moving_right:
		motion.x = speed
		_animate("run")
	elif Input.is_action_pressed("ui_left") or keep_moving_left:
		motion.x = -speed
		_animate("run_back")
	else:
		motion.x = 0
		_animate("idle")

	if is_on_floor():
		sound_played = false
		keep_moving_right = false
		keep_moving_left = false		
		if Input.is_action_pressed("ui_up"):
			motion.y = -jump_power
			_animate("jump")
	else:
		if !sound_played:
			$JumpSound.play()
			sound_played = true
		_animate("jump")
		if motion.x > 0:
			keep_moving_right = true
		elif motion.x < 0:
			keep_moving_left = true
		
	motion = move_and_slide(motion, Vector2.UP)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "Podium":
			win()

func _animate(state):
	$AnimatedSprite.animation = state
	if use_charlie:
		$Charlie.animation = state
	
func hurt():
	set_physics_process(false)
	_animate("hurt")

func win():
	emit_signal("win")
	if use_charlie:
		$Charlie.animation = "win"
	$AnimatedSprite.animation = "idle"
	set_physics_process(false)