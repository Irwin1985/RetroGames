extends Node2D

func _on_PlatformTop_body_entered(body : PhysicsBody2D)->void:
	if body.name == global.PLAYER_NAME or body.name == global.LION_NAME:
		if body.motion.y >= 0:
			$PlatformTable/CollisionShape2D.disabled = false
			body.win()
