extends Node2D
class_name Swing

signal first_grab

var grab_enabled: bool = true
var already_grabbed: bool = false
var checkpoint: int = 0
var min_angle : float = 18.5
var max_angle : float = 71.5
var min_animation_speed : float = 1.3333333333333333333333333
var med_animation_speed : float = 0.87
var max_animation_speed : float = 1.27
var med_speed : float = 0.85

var swing_speed : float = med_speed
var swing_angle : float = 63
var swing_max_angle : float = 63
var swing_direction : int = 1
var swing_wait : float = 0

func _process(delta) ->void:
	if swing_wait <= 0:
		var animation_speed : float
		if swing_speed >= 0.85:
			animation_speed = med_animation_speed + (max_animation_speed - med_animation_speed) * \
					(swing_speed - med_speed) / (1 - med_speed)
		else:
			animation_speed = min_animation_speed + (med_animation_speed - min_animation_speed) * \
					(swing_speed / med_speed)
		swing_angle -= swing_direction * (swing_max_angle * 2 * animation_speed / 1.8) * delta
		if abs(swing_angle) > swing_max_angle:
			swing_angle = swing_max_angle * sign(swing_angle)
			swing_wait = 0.2
		$SwingRope.set_rotation(swing_angle * PI / 180)
	else:
		swing_wait -= delta
		if swing_wait <= 0:
			swing_direction *= -1


func get_speed() -> float:
#	return $AnimationPlayer.playback_speed	
	var animation_speed : float
	if swing_speed >= 0.85:
		animation_speed = med_animation_speed + (max_animation_speed - med_animation_speed) * \
				(swing_speed - med_speed) / (1 - med_speed)
	else:
		animation_speed = min_animation_speed + (med_animation_speed - min_animation_speed) * \
				(swing_speed / med_speed)
	return animation_speed


func set_speed(speed: float) -> void:
	swing_speed = speed
	if swing_speed > 1:
		swing_speed = 1
	elif swing_speed < 0:
		swing_speed = 0
	swing_max_angle = min_angle + (max_angle - min_angle) * speed
	if abs(swing_angle) > swing_max_angle:
		swing_angle = swing_max_angle * sign(swing_angle)


func accelerate(acc_direction : float = 1):
	if sign(acc_direction) == swing_direction:
		set_speed(swing_speed + abs(acc_direction))
	else:
		set_speed(swing_speed - abs(acc_direction))


func put_checkpoint(distance: int) -> void:
	checkpoint = distance


func _on_Area2D_body_entered(body: PhysicsBody2D) -> void:
	if body.name == global.PLAYER_NAME and grab_enabled:
		grab_enabled = false
		call_deferred("take_player", body)


func take_player(body: PhysicsBody2D) -> void:
	if body.name == global.PLAYER_NAME:
		if not already_grabbed:
			already_grabbed = true
			emit_signal("first_grab")
		if checkpoint != 0:
			global.set_checkpoint(checkpoint)
		# Change swing direction
		swing_direction = 1
		body.take_swing(self)
	else:
		grab_enabled = true


func get_grab_bar_position() -> Vector2:
	return $SwingRope/GrabBar.global_position


func enable_bar() -> void:
	grab_enabled = true


func get_tangential_speed() -> Vector2:
	var vert_speed : float = -abs(sin($SwingRope.rotation) * 175)
	var horz_speed : float
	if swing_speed <= 0.5:
		horz_speed = 50
	else:
		horz_speed = 200
	if abs(swing_angle) == swing_max_angle:
		return Vector2(0, -100)
	elif sign(swing_angle) != sign(swing_direction):
		return Vector2(horz_speed * swing_direction, vert_speed)
	elif swing_angle < 0:
		return Vector2(-50, -vert_speed)
	return Vector2(horz_speed * swing_direction, -vert_speed)

func get_swing_position() -> float: # 0.0-4.0
	var anim_pos : float
	if swing_direction == 1:
		if swing_angle == -swing_max_angle:
			anim_pos = 1.9
		else:
			anim_pos = (1 - ((swing_angle + swing_max_angle) / 2) / swing_max_angle) * 1.8
	else:
		if swing_angle == swing_max_angle:
			anim_pos = 3.9
		else:
			anim_pos = 2 + ((swing_angle + swing_max_angle) / 2) / swing_max_angle * 1.8
		
	return anim_pos


func reset_swing_position(new_angle : float = 0) -> void:
	swing_angle = new_angle
	$SwingRope.rotate(swing_angle * PI / 180)


func stop() -> void:
	set_process(false)