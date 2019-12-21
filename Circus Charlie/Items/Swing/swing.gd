extends Node2D

var grab_enabled : bool = true

func set_speed(speed : float)->void:
	$AnimationPlayer.playback_speed = speed

func _on_Area2D_body_entered(body : PhysicsBody2D)->void:
	if body.name == "Player" and grab_enabled:
		grab_enabled = false
		call_deferred("take_player", body)
		
func take_player(body : PhysicsBody2D)->void:
	if body.name == "Player":
		body.take_swing(self)
	else:
		grab_enabled = true
	
func get_grab_bar_position()->Vector2:
	return $SwingRope/GrabBar.global_position
	
func enable_bar()->void:
	grab_enabled = true
	
func get_tangential_speed()->Vector2:
	if $AnimationPlayer.current_animation_position < 1.8:
		return Vector2(200, 0)
	elif $AnimationPlayer.current_animation_position <= 2:
		return Vector2(0, -100)
	elif $AnimationPlayer.current_animation_position < 3:
		return Vector2(-50, 50)
	elif $AnimationPlayer.current_animation_position < 3.8:
		return Vector2(-200, 0)
	else:
		return Vector2(0, -100)