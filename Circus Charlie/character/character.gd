extends KinematicBody2D
class_name Player

signal win
signal lose
signal hit
signal moved
signal stopped
signal jumped
signal hurt_proceed
signal bonus

export (int) var speed
export (bool) var can_jump
export (int) var jump_power
export (int) var gravity
export (bool) var use_charlie = false
export (bool) var slow_backward = false
export (bool) var process_hurt = false
export (String, "none", "Stage 1:Lion", "Stage 2:Monkey", "Stage 3:Balls", "Stage 4:Horse", "Stage 5:Swinging") var character_behaviour
export (PackedScene) var Horse
onready var fall_timer : Timer = Timer.new()
onready var hide_bonus_timer : Timer = Timer.new()
onready var bounce_life_timer : Timer = Timer.new()
var bounced_total = 0
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
var there_is_sound := false
var bonus_earned := false
var BallScene: PackedScene = preload("res://Items/Ball.tscn")
var BallReference: Area2D = null
onready var BonusLabel: Label = get_node("GUI/BonusLabel")

func _ready():
	if BonusLabel != null:
		BonusLabel.visible = false
	there_is_sound = get_node("Sounds") != null
	set_sfx_volume()
	set_timers()

	if !can_jump:
		set_physics_process(false)


func _physics_process(delta):
	if hanging:
		var pos_offset : Vector2 = Vector2(-18, 8)
		position = last_swing.get_grab_bar_position() + pos_offset
		if Input.is_action_just_pressed("game_jump"):
			hanging = false
			motion = last_swing.get_tangential_speed()
			jump()
	else:
		motion.y += gravity * delta * 60
		if !jumping and character_behaviour != "Stage 4:Horse":
			if Input.is_action_pressed("game_right"):
				motion.x = speed
				animate("run")
			elif Input.is_action_pressed("game_left"):
				if slow_backward:
					motion.x = (speed * 0.40) - speed
				else:
					motion.x = -speed
				animate("run back")
			else:
				motion.x = 0
				animate("idle")
		elif character_behaviour == "Stage 4:Horse":
			motion.x = speed
			if Horse != null:
				Horse.get_node("AnimatedSprite").speed_scale = 1
			if Input.is_action_pressed("game_left"):
				motion.x = speed - (40 * speed) / 100
				if Horse != null:
					Horse.get_node("AnimatedSprite").speed_scale = 0.5
			elif Input.is_action_pressed("game_right"):
				motion.x = speed + (30 * speed) / 100
				if Horse != null:
					Horse.get_node("AnimatedSprite").speed_scale = 1.5

		if is_on_floor():
			jumping = false
			if Input.is_action_just_pressed("game_jump"):
				motion.y = -jump_power
				jump()
				if character_behaviour != "Stage 4:Horse":
					if Input.is_action_pressed("game_right"):
						motion.x = speed
					elif Input.is_action_pressed("game_left"):
						motion.x = -speed
					else:
						motion.x = 0
				else:
					motion.x = speed
				emit_signal("jumped", motion.x)
			if character_behaviour == "Stage 4:Horse":
				$Charlie.animation = "ride"
			if bonus_earned:
				bonus_earned = false
				BonusLabel.visible = true
				if not $Sounds/BonusSound.playing:
					$Sounds/BonusSound.play()

		if motion.x != 0:
			emit_signal("moved", motion.x)
		else:
			emit_signal("stopped")

		motion = move_and_slide(motion, Vector2.UP)

func set_sfx_volume():
	if there_is_sound:
		for audio in $Sounds.get_children():
			audio.volume_db = global.STANDARD_VOLUME


func set_timers():
	if fall_timer.connect("timeout", self, "fall_down") != OK:
		print("Error connecting timeout of fall_timer")
	fall_timer.wait_time = 0.02
	add_child(fall_timer)
	
	# Bonus Timer (stage 4)
	hide_bonus_timer.connect("timeout", self, "_on_hide_bonus_timer_timeout")
	hide_bonus_timer.wait_time = 0.65
	add_child(hide_bonus_timer)

	# Bonus lifetime (stage 4)
	bounce_life_timer.connect("timeout", self, "_on_bounce_life_timer_timeout")
	bounce_life_timer.wait_time = 1
	add_child(bounce_life_timer)


func jump()->void:
	jumping = true
	$Sounds/JumpSound.play()
	animate("jump")


func animate(state : String)->void:
	$AnimationPlayer.play(state)


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
		animate("spin jump")
		$AnimationPlayer.seek(0)
	else:
		motion = Vector2(0, -bounciness)
		animate("jump")
	if bounce_in_center:
		var center_vector : Vector2 = Vector2(trampoline.get_bounce_center().x - position.x, 0) 
		move_local_x(center_vector.x)


func stop()->void:
	set_physics_process(false)
	$Charlie.stop()
	$AnimationPlayer.stop()


func hit_and_fall()->void:
	if not hit:
		hit = true
		emit_signal("hit")
		if character_behaviour != "Stage 3:Balls" and character_behaviour != "Stage 4:Horse":
			$Sounds/HurtSound.play()
		if character_behaviour != "Stage 2:Monkey" and character_behaviour != "Stage 3:Balls":
			$Charlie.set_animation("jump")
		$Charlie.set_rotation(0)
		stop()
		if character_behaviour != "Stage 3:Balls" and character_behaviour != "Stage 4:Horse":
			yield(get_tree().create_timer(0.8),"timeout")
			$Sounds/FallSound.play()
			fall_timer.start()
		else:
			if character_behaviour == "Stage 4:Horse":
				Horse.move_alone = true
				$Sounds/FallSound.play()
			fall_timer.start()


func fall_down()->void:
	if not lost:
		position.y += 4


func show_BonusLabel(new_val):
	if bounce_life_timer.time_left > 0.00:
		bounce_life_timer.wait_time = 1
		if bounced_total > 0:
			bounced_total += bounced_total
		else:
			bounced_total = new_val
	else:
		bounced_total = new_val
	emit_signal("bonus", bounced_total)
	BonusLabel.text = str(bounced_total)
	BonusLabel.rect_position.y = 25
	BonusLabel.show()
	hide_bonus_timer.start()
	bounce_life_timer.start()


func _on_hide_bonus_timer_timeout():
	BonusLabel.hide()


func _on_bounce_life_timer_timeout():
	bounced_total = 0


func hurt()->void:
	if not won and not lost:
		call_deferred("animate","hurt")
		lose()


func lose():
	if not won and not lost:
		lost = true
		emit_signal("lose")
		if character_behaviour != "Stage 3:Balls":
			$Sounds/HurtSound.play()
		stop()


func continue_hurt():
	emit_signal("hurt_proceed")


func win():
	if not lost:
		won = true
		emit_signal("win")
		animate("win")
		set_physics_process(false)


func _on_BonusSound_finished():
	BonusLabel.visible = false


func bonus_earned_for_jumping_cyan_monkey():
	bonus_earned = true


func create_ball_scene(ball_position):
	BallReference = BallScene.instance()
	add_child(BallReference)