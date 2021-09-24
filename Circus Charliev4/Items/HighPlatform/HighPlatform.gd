extends Node2D

func _on_PlatformTop_body_entered(body : PhysicsBody2D)->void:
	if body.name == global.PLAYER_NAME or body.name == global.LION_NAME:
		if body.motion.y >= 0:
			$PlatformTable/CollisionShape2D.call_deferred("set_disabled", false)
			body.win()


func extend_tower(count : int = 2):
	$PlatformTable/Tower.set_visible(true)
	if count > 1:
		for i in range (count - 1):
			var new_tower = $PlatformTable/Tower.duplicate()
			new_tower.position.y += (i + 1) * 16
			$PlatformTable.add_child(new_tower)


func remove_win_area():
	$PlatformTop.call_deferred("queue_free")
