extends Area2D
export (int) var speed = 230
const PLAYER_NAME = "Player"
var move_alone := false setget set_move_alone

func _process(delta):
	if move_alone:
		position.x += speed * delta


func _on_Horse_body_entered(body):
	pass


func set_move_alone(new_val):
	move_alone = new_val
	$AnimatedSprite.speed_scale = 0.5

func _on_PlayerRideAnimation_body_entered(body):
	if body.name == PLAYER_NAME and body.motion.y > 0:
		body.get_node("Charlie").animation = "ride"
