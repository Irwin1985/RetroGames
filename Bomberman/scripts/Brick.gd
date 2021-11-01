extends Area2D


func update_pos(new_pos:Vector2) -> void:
	position = new_pos


func explode() -> void:
	$Explosion.play()
	$AnimationPlayer.play("explode")
	yield($AnimationPlayer, "animation_finished")
	call_deferred("queue_free")
