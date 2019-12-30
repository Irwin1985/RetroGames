extends Node2D

func _on_PlatformTop_body_entered(body : PhysicsBody2D)->void:
	if body.name == "Player" or body.name == "Lion":
		body.win()
