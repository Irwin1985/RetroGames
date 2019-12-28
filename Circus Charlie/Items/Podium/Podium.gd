extends StaticBody2D

var player : PhysicsBody2D = null
var player_center_timer = Timer.new()


func _on_PodiumTop_body_entered(body : PhysicsBody2D)->void:
	if body.name == "Player" or body.name == "Lion":
		body.win()


func player_center(body : PhysicsBody2D)->void:
	player = body
	var podium_level : Vector2 = position + Vector2.UP * 38
	podium_level.x = player.get_position().x
	player.set_position(podium_level)
	
	player_center_timer.connect("timeout", self, "_on_player_center_timeout")	
	player_center_timer.wait_time = 0.02
	add_child(player_center_timer)
	player_center_timer.start()


func _on_player_center_timeout()->void:
	var xdelta : float = (get_position() - player.get_position() ).x
	if abs(xdelta) > 1:
		var direction : Vector2 = Vector2(xdelta, 0).normalized()
		player.set_position(player.get_position() + direction)
	else:
		player_center_timer.stop()