extends KinematicBody2D
class_name Player

signal win
signal lose
signal hit

export (int) var speed
export (bool) var can_jump
export (int) var jump_power
export (int) var gravity
export (bool) var use_charlie = false

onready var fall_timer : Timer = Timer.new()
var motion = Vector2()
var hanging : bool = false
var jumping : bool = false
var hit : bool = false
var lost : bool = false
var won : bool = false
var last_swing : Swing = null


func _ready():
	if fall_timer.connect("timeout", self, "fall_down") != OK:
		print("Error connecting timeout of fall_timer")
	fall_timer.wait_time = 0.02
	add_child(fall_timer)
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
		motion.y += gravity * delta * 60
		if !jumping:
			if Input.is_action_pressed("game_right"):
				motion.x = speed
				animate("run")
			elif Input.is_action_pressed("game_left"):
				motion.x = -speed
				animate("run back")
			else:
				motion.x = 0
				animate("idle")
		if is_on_floor():
			jumping = false
			if Input.is_action_pressed("game_jump"):
				motion.y = -jump_power
				jump()
				if Input.is_action_pressed("game_right"):
					motion.x = speed
				elif Input.is_action_pressed("game_left"):
					motion.x = -speed
				else:
					motion.x = 0
		motion = move_and_slide(motion, Vector2.UP)

func jump()->void:
	jumping = true
	$JumpSound.play()
	animate("jump")

func animate(state : String)->void:
#	if $AnimationPlayer.get_current_animation() != state:
#		print($AnimationPlayer.get_current_animation() + "-" + state)
		$AnimationPlayer.play(state)
#		$AnimationPlayer.call_deferred("play",state)
#	$AnimatedSprite.animation = state
#	if use_charlie:
#		$Charlie.animation = state

func take_swing(swing : Swing)->void:
	if last_swing != null and last_swing != swing:
		last_swing.enable_bar()
	hanging = true
	jumping = false
	$Charlie.animation = "swing"
	$AnimationPlayer.set_speed_scale(swing.get_speed())
	$AnimationPlayer.play("swing")
	$AnimationPlayer.seek(swing.get_swing_position())
	last_swing = swing
	
func bounce_trampoline(bounciness : float = 620)->void:
	if last_swing != null:
		last_swing.enable_bar()
		last_swing = null
	if Input.is_action_pressed("game_left"):
		motion = Vector2(-100, -bounciness)
	elif Input.is_action_pressed("game_right"):
		motion = Vector2(100, -bounciness)
	else:
		motion = Vector2(0, -bounciness)
		
func bounce_big_trampoline(trampoline : BigTrampoline, bounciness: float, bounce_in_center : bool = true)->void:
	jumping = true
	if Input.is_action_pressed("game_left"):
		motion = Vector2(-200, -500)
		trampoline.reset_bounces()
		$AnimationPlayer.seek(1)
		$AnimationPlayer.play_backwards("spin jump")
	elif Input.is_action_pressed("game_right"):
		motion = Vector2(200, -500)
		trampoline.reset_bounces()
#		$AnimationPlayer.seek(0)
#		$AnimationPlayer.play("spin jump")
		$AnimationPlayer.seek(0)
		animate("spin jump")
	else:
		motion = Vector2(0, -bounciness)
#		$AnimationPlayer.play("jump")
		animate("jump")
	if bounce_in_center:
		var center_vector : Vector2 = Vector2(trampoline.get_bounce_center().x - position.x, 0) 
		move_local_x(center_vector.x)
		
func stop()->void:
	set_physics_process(false)
	$Charlie.stop()
	$AnimationPlayer.stop()
	if use_charlie:
		$Charlie.stop()

func hit_and_fall()->void:
	if not hit:
		hit = true
		emit_signal("hit")
		$HurtSound.play()
		$Charlie.set_animation("jump")
		$Charlie.set_rotation(0)
		stop()
		yield(get_tree().create_timer(0.8),"timeout")
		$FallSound.play()
		fall_timer.start()
		
func fall_down()->void:
	if not lost:
		position.y += 4

func hurt()->void:
	if not won and not lost:
		call_deferred("animate","hurt")
		# Wait for the animation to be updated before stopping the player
#		yield(get_tree().create_timer(0.1),"timeout")
		lose()

func lose():
	if not won and not lost:
		lost = true
		emit_signal("lose")
		$HurtSound.play()
		stop()

func win():
	if not lost:
		won = true
		emit_signal("win")
		animate("win")
#		if use_charlie:
#			$Charlie.animation = "win"
#			$AnimatedSprite.animation = "idle"
#		else:
#			$AnimatedSprite.animation = "win"
		set_physics_process(false)