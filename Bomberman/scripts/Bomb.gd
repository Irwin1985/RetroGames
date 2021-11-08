extends StaticBody2D

signal exploded


func _ready() ->void:
	if Global.player_has_detonator:
		$BombTimer.stop()


func _on_LeftSensor_body_entered(body: Node) -> void:
	_activate_hitbox()


func _on_RightSensor_body_entered(body: Node) -> void:
	_activate_hitbox()


func _activate_hitbox() -> void:
	$CollisionShape2D.disabled = false


func _on_BombTimer_timeout() -> void:
	_activate_explosion()


func _activate_explosion() -> void:
	emit_signal("exploded", position)
	queue_free()
