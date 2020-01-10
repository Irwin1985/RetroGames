extends Area2D
export (int) var speed = 200
const PLAYER_NAME = "Player"

func _process(delta):
	pass
#	position.x += speed * delta


func _on_Horse_body_entered(body):
	pass
#	if body.name == PLAYER_NAME:
#		body.animate("ride")
