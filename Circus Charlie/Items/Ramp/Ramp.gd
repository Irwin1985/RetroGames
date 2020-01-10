extends StaticBody2D
const PLAYER_NAME = "Player"
export (String, "Big", "Small") var ramp_type = "Big"

func _ready():
	$AnimatedSprite.play("big_idle" if ramp_type == "Big" else "small_idle")


func _on_Area2D_body_entered(body):
	if body.name == PLAYER_NAME:
		$RampSound.play()
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("big_bounce" if ramp_type == "Big" else "small_bounce")
		body.animate("bounce")
		body.motion.y = -280


func _on_Area2D_body_exited(body):
	if body.name == PLAYER_NAME:
		body.animate("jump")
