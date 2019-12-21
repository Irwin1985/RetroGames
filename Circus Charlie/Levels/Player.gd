extends KinematicBody2D

var last_swing : Swing = null
var hanging : bool = false
var motion : Vector2 = Vector2.ZERO
var gravity = 10

func _physics_process(delta: float)->void:
	if hanging:
		var pos_offset : Vector2 = Vector2(-18, 8)
		position = last_swing.get_grab_bar_position() + pos_offset
		if Input.is_action_pressed("game_jump"):
			hanging = false
			$AnimatedSprite.set_animation("jump")
			motion = last_swing.get_tangential_speed()
	else:
		motion.y += gravity
		motion = move_and_slide(motion, Vector2.UP)

func take_swing(swing : Swing)->void:
	if last_swing != null and last_swing != swing:
		last_swing.enable_bar()
	hanging = true
	$AnimatedSprite.set_animation("swinging")
	$AnimatedSprite.set_speed_scale(swing.get_speed())
	$AnimatedSprite.set_frame( \
		$AnimatedSprite.get_sprite_frames().get_frame_count("swinging") * \
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
		
func hurt()->void:
	motion = Vector2.ZERO
	$HurtSound.play()
	$AnimatedSprite.set_animation("hurt")
	
	
	