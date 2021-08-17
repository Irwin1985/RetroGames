extends Node2D

signal pressed(this, parent_id)

var _parent_id := -1
var _resolved := false


func set_parent_id(parent_id: int)->void:
	_parent_id = parent_id


func compare_result():
	emit_signal("pressed", self, _parent_id)


func switch_texture()->void:
	$Sprite.flip_h = false
	_resolved = true


func is_resolved()->bool:
	return _resolved
