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

func get_speed() -> float:
	return $AnimationPlayer.playback_speed


func set_speed(speed: float) -> void:
	swing_speed = speed
	print(speed)
	var animation_speed : float
	if speed >= 0.85:
		animation_speed = med_animation_speed + (max_animation_speed - med_animation_speed) * \
				(speed - med_speed) / (1 - med_speed)
	else:
		animation_speed = min_animation_speed + (med_animation_speed - min_animation_speed) * \
				(speed / med_speed)
	$AnimationPlayer.playback_speed = animation_speed
	var swing_animation : Animation = $AnimationPlayer.get_animation("swing")
	for i in swing_animation.track_get_key_count(0):
		if swing_animation.track_get_key_value(0, i) < 0:
			swing_animation.track_set_key_value(0, i, -min_angle - speed * (max_angle - min_angle))
		elif swing_animation.track_get_key_value(0, i) > 0:
			swing_animation.track_set_key_value(0, i, min_angle + speed * (max_angle - min_angle))

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
		if $AnimationPlayer.current_animation_position > 2 and \
			$AnimationPlayer.current_animation_position < 3.8:
			# Change swing direction
			reset_swing_position(3.8 - $AnimationPlayer.current_animation_position)
		body.take_swing(self)
	else:
		grab_enabled = true


func get_grab_bar_position() -> Vector2:
	return $SwingRope/GrabBar.global_position


func enable_bar() -> void:
	grab_enabled = true


func get_tangential_speed() -> Vector2:
	var vert_speed = -abs(sin($SwingRope.rotation) * 175)
	if $AnimationPlayer.current_animation_position < 0.9:
		return Vector2(200, -vert_speed)
	elif $AnimationPlayer.current_animation_position < 1.8:
		return Vector2(200, vert_speed)
	elif $AnimationPlayer.current_animation_position <= 2:
		return Vector2(0, -100)
	elif $AnimationPlayer.current_animation_position < 2.7:
		return Vector2(-50, -vert_speed)
	elif $AnimationPlayer.current_animation_position < 3.8:
		return Vector2(-200, vert_speed)
	else:
		return Vector2(0, -100)


func get_swing_position() -> float: # 0.0-4.0
	return $AnimationPlayer.current_animation_position


func reset_swing_position(animation_position : float = 3) -> void:
	$AnimationPlayer.play("swing")
	$AnimationPlayer.seek(animation_position)


func stop() -> void:
	$AnimationPlayer.stop()