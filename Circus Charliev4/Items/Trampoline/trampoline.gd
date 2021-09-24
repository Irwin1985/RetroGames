extends Area2D
class_name Trampoline

var bounce_enabled: bool = true

func _ready():
	$BounceSound.volume_db = global.STANDARD_VOLUME


func _on_trampoline_body_entered(body: PhysicsBody2D) -> void:
	if body.name == global.PLAYER_NAME and bounce_enabled:
		bounce_enabled = false
		call_deferred("bounce_player", body)


func bounce_player(body: PhysicsBody2D) -> void:
	if body.name == global.PLAYER_NAME:
		if body.can_bounce():
			body.bounce_trampoline()
			$BounceSound.play()
			yield(get_tree().create_timer(0.5), "timeout")
	bounce_enabled = true


func get_bounce_center() -> Vector2:
	return $BounceMat.global_position


func stop() -> void:
	# Called when stopping level objects
	pass
