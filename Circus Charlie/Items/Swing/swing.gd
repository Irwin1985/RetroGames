extends Node2D
class_name Swing

var grab_enabled : bool = true

func get_speed()->float:
	return $AnimationPlayer.playback_speed

func set_speed(speed : float)->void:
	$AnimationPlayer.playback_speed = speed

func _on_Area2D_body_entered(body : PhysicsBody2D)->void:
	if body.name == "Player" and grab_enabled:
		grab_enabled = false
		call_deferred("take_player", body)
		
func take_player(body : PhysicsBody2D)->void:
	if body.name == "Player":
		if $AnimationPlayer.current_animation_position > 2 and \
			$AnimationPlayer.current_animation_position < 3.8:
			# Change swing direction
			reset_swing_position(3.8 - $AnimationPlayer.current_animation_position)
		body.take_swing(self)
	else:
		grab_enabled = true
	
func get_grab_bar_position()->Vector2:
	return $SwingRope/GrabBar.global_position
	
func enable_bar()->void:
	grab_enabled = true
	
func get_tangential_speed()->Vector2:
	var vert_speed = -abs(sin($SwingRope.rotation) * 150)
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
		
func get_swing_position()->float: # 0.0-4.0
	return $AnimationPlayer.current_animation_position

func reset_swing_position(animation_position : float = 3)->void:
	$AnimationPlayer.play("swing")
	$AnimationPlayer.seek(animation_position)