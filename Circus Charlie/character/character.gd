extends KinematicBody2D

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
			jumping = true
			$JumpSound.play()
			animate("jump")
			if Input.is_action_pressed("ui_right"):
				motion.x = speed
			elif Input.is_action_pressed("ui_left"):
				motion.x = -speed
			else:
				motion.x = 0
		
	motion = move_and_slide(motion, Vector2.UP)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "Podium":
			win()


func animate(state):
	$AnimatedSprite.animation = state
	if use_charlie:
		$Charlie.animation = state


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