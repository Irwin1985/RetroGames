extends StaticBody2D


func _on_PodiumTop_body_entered(body : PhysicsBody2D)->void:
	if body.name == "Player" or body.name == "Lion":
		body.win()
