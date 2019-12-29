extends Node2D

signal cyan_monkey_activated


func _on_CyanMonkeySentinel_body_entered(body):
	if body.name == "Player":
		emit_signal("cyan_monkey_activated")
