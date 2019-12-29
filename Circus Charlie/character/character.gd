extends KinematicBody2D
class_name Player

signal win
signal lose
signal hit
signal moved
signal stopped
signal hurt_proceed

export (int) var speed
export (bool) var can_jump
export (int) var jump_power
export (int) var gravity
export (bool) var use_charlie = false
export (bool) var slow_backward = false
export (bool) var process_hurt = false

onready var fall_timer : Timer = Timer.new()
var motion = Vector2()

var hanging : bool = false
var jumping : bool = false
var hit : bool = false
var lost : bool = false
var won : bool = false
var last_swing : Swing = null
var sound_played = true
var current_enemy_name = ""
var is_hurt = false
var is_floor_detected = false
var there_is_sound


func _ready():
	there_is_sound = get_node("Sounds") != null
	set_sfx_volume()
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
      #######
func _physics_process(delta):
	motion.y += gravity
	if !jumping and !is_hurt:
		if Input.is_action_pressed("ui_right"):
			motion.x = speed
			animate("run")
		elif Input.is_action_pressed("ui_left"):
			if slow_backward:
				motion.x = (speed * 0.40) - speed
			else:
				motion.x = -speed
			animate("run_back")
		else:
			motion.x = 0
			if !is_hurt:
				animate("idle")
	if is_hurt:
		motion.x = 0
		
	if is_on_floor():
		sound_played = false
		jumping = false
		if Input.is_action_pressed("ui_up") and !is_hurt:
			motion.y = -jump_power
			jumping = true
			if Input.is_action_pressed("ui_right"):
     ######
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
		if !sound_played and !is_hurt:
			if there_is_sound:
				$Sounds/JumpSound.play()
			sound_played = true
		if !is_hurt:
			animate("jump")
	
	if motion.x > 0:
		emit_signal("moved")
	elif motion.x == 0:
		emit_signal("stopped")
	motion = move_and_slide(motion, Vector2.UP)
	
	for idx in get_slide_count():
		var collision = get_slide_collision(idx)
		match collision.collider.name:
			"Podium":
				win()
			"UnderFloor":
				if !is_floor_detected:
					is_floor_detected = true
					if there_is_sound:
						$Sounds/HurtSound.play()
					animate("hurt")
					if there_is_sound:
						yield($Sounds/HurtSound, "finished")
					yield(get_tree().create_timer(0.4), "timeout")
					continue_hurt()
#######

func set_sfx_volume():
	if there_is_sound:
		for audio in $Sounds.get_children():
			audio.volume_db = global.STANDARD_VOLUME

func animate(state):
	$AnimatedSprite.animation = state

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
		animate("spin jump")
		$AnimationPlayer.seek(0)
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
    #########
	if !use_charlie:
		is_hurt = true
		motion.y = 0
		gravity = gravity - ((35 * gravity) / 100)
		$AnimatedSprite.play("idle")
	else:
		$AnimatedSprite.animation = "hurt"
		$Charlie.animation = "hurt"
	set_physics_process(false)

func lose():
	if not won and not lost:
		lost = true
		emit_signal("lose")
		$HurtSound.play()
		stop()

func continue_hurt():
	if there_is_sound:
		$Sounds/LoseSound.play()
		yield($Sounds/LoseSound, "finished")
	emit_signal("hurt_proceed")

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