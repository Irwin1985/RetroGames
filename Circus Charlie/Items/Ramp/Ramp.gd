extends StaticBody2D

const PLAYER_NAME = "Player"


func _on_Area2D_body_entered(body):
	if body.name == PLAYER_NAME:
		$RampSound.play()
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("bounce")
		body.show_BonusLabel(100)
		body.get_node("Charlie").animation = "bounce"
		body.motion.y = -290


func _on_Area2D_body_exited(body):
	if body.name == PLAYER_NAME:
		body.get_node("Charlie").animation = "jump"
