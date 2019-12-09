extends Area2D
signal entered

func _on_Sentinel_body_entered(body):
	emit_signal("entered")
