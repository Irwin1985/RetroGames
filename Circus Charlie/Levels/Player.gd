extends KinematicBody2D

var last_swing : Node2D = null
var hanging : bool = false
var speed : Vector2 = Vector2.ZERO
var gravity = 10

func _ready()->void:
	pass # Replace with function body.

func _physics_process(delta: float)->void:
	if Input.is_action_pressed("game_jump"):
		if hanging:
			hanging = false
			$AnimatedSprite.set_animation("jump")
			speed = last_swing.get_tangential_speed()
			
	if hanging:
		var pos_offset : Vector2 = Vector2(-18, 8)
		position = last_swing.get_grab_bar_position() + pos_offset
	else:
		speed.y += gravity
		speed = move_and_slide(speed, Vector2.UP)

func take_swing(swing : Node2D)->void:
	if last_swing != null and last_swing != swing:
		last_swing.enable_bar()
	hanging = true
	$AnimatedSprite.set_animation("swinging")
	last_swing = swing
	
func bounce_trampoline()->void:
	if last_swing != null:
		last_swing.enable_bar()
		last_swing = null
	if Input.is_action_pressed("game_left"):
		speed = Vector2(-100, -500)
	elif Input.is_action_pressed("game_right"):
		speed = Vector2(100, -500)
	else:
		speed = Vector2(0, -500)
		
func hurt()->void:
	speed = Vector2.ZERO
	$HurtSound.play()
	$AnimatedSprite.set_animation("hurt")
	
	
	