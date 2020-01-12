extends Area2D

signal player_detected
signal screen_exited
signal bonus
signal bonus_earned

export (int) var speed = 10

var velocity = Vector2.ZERO
var can_move_itself := true setget set_can_move_itself
var is_player_entered := false
var is_player_exited := false
var orientation = -1
var raycast_reached := false
var player_touches := 0


func _process(delta):
	if can_move_itself:
		velocity.x = (speed * orientation) * delta
	position.x += velocity.x

	if $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		if collider != null and collider.name == global.PLAYER_NAME and !raycast_reached:
			raycast_reached = true
			emit_signal("bonus")


func set_can_move_itself(new_val):
	can_move_itself = new_val
	if not can_move_itself:
		velocity.x = 0
		$AnimatedSprite.stop()
	else:
		$AnimatedSprite.play()


func _on_Ball_body_entered(body):
	if body.name == global.PLAYER_NAME and !is_player_entered:
		is_player_entered = true
		emit_signal("player_detected", self)
		self.can_move_itself = false


func _on_Ball_body_exited(body):
	if body.name == global.PLAYER_NAME and not is_player_exited:
		is_player_exited = true
		self.can_move_itself = true


func _on_VisibilityNotifier2D_screen_exited():
	emit_signal("screen_exited", self)


func _on_PlayerBonusSensor_body_entered(body):
	if body.name == global.PLAYER_NAME:
		player_touches += 1
		if player_touches == 1 and body.motion.y > 0:
			emit_signal("bonus_earned", 100)