extends StaticBody2D

signal LionOnTop

func _ready():
	pass


func _on_Top_body_entered(body):
	if body.name == "Lion":
		emit_signal("LionOnTop")
#		var player_position : Vector2 = lion.position + Vector2.UP * 35
#		var static_lion = lion_pickup_scene.instance()
#		static_lion.remove_ride()
#		static_lion.position = player_position + Vector2.DOWN * 35
#		$Player.call_deferred("remove_child", lion)
#		$Player.call_deferred("add_child", player)
#		$Environment.call_deferred("add_child", static_lion)
#		player.set_position(player_position)
	elif body.name == global.PLAYER_NAME:
		body.gravity = 15
