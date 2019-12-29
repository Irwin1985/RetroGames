extends KinematicBody2D

signal win
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

var motion = Vector2()
var jumping = false
var sound_played = true
var current_enemy_name = ""
var is_hurt = false
var is_floor_detected = false
var there_is_sound

func _ready():
	there_is_sound = get_node("Sounds") != null
	set_sfx_volume()
	if !can_jump:
		set_physics_process(false)


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
				motion.x = speed
			elif Input.is_action_pressed("ui_left"):
				motion.x = -speed
			else:
				motion.x = 0
	else:
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

func set_sfx_volume():
	if there_is_sound:
		for audio in $Sounds.get_children():
			audio.volume_db = global.STANDARD_VOLUME

func animate(state):
	$AnimatedSprite.animation = state
	if use_charlie:
		$Charlie.animation = state


func hurt():
	if !use_charlie:
		is_hurt = true
		motion.y = 0
		gravity = gravity - ((35 * gravity) / 100)
		$AnimatedSprite.play("idle")
	else:
		$AnimatedSprite.animation = "hurt"
		$Charlie.animation = "hurt"
	set_physics_process(false)


func continue_hurt():
	if there_is_sound:
		$Sounds/LoseSound.play()
		yield($Sounds/LoseSound, "finished")
	emit_signal("hurt_proceed")

func win():
	emit_signal("win")
	if use_charlie:
		$Charlie.animation = "win"
	$AnimatedSprite.animation = "idle"
	set_physics_process(false)