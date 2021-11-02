extends Area2D

signal show_secret

var _type:int = -1
var _value:int


func update_pos(new_pos:Vector2) -> void:
	position = new_pos


func explode() -> void:
	$Explosion.play()
	$AnimationPlayer.play("explode")
	yield($AnimationPlayer, "animation_finished")
	call_deferred("queue_free")


func set_secret_type(type:int) -> void:
	_type = type


func set_secret_value(value:int) -> void:
	_value = value


func get_secret_type() -> int:
	return _type


func get_secret_value() -> int:
	return _value


func interrogate() -> void:
	if _type >= 0:
		emit_signal("show_secret", _type, _value)
