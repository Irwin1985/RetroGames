extends Area2D

signal player_detected

export (int) var speed = 20 setget set_speed

const PLAYER_NAME = "Player"
var velocity = Vector2.ZERO
var can_move_itself := true setget set_can_move_itself
var is_player_detected := false

func _process(delta):
	if can_move_itself:
		velocity.x = -speed * delta
	position.x += velocity.x


func set_speed(new_speed):
	speed = new_speed


func set_can_move_itself(new_val):
	can_move_itself = new_val
	if not can_move_itself:
		velocity.x = 0
		$AnimatedSprite.stop()
	else:
		$AnimatedSprite.play()


func _on_Ball_body_entered(body):
	if body.name == PLAYER_NAME:
		is_player_detected = false
		emit_signal("player_detected", self)
		self.can_move_itself = false


func _on_Ball_body_exited(body):
	if body.name == PLAYER_NAME and not is_player_detected:
		is_player_detected = true
		self.can_move_itself = true
