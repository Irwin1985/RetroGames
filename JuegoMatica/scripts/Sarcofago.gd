extends Node2D

signal animation_finished


func _on_AnimationPlayer_animation_finished(anim_name):
	$SpriteMomia.visible = false
	emit_signal("animation_finished", anim_name)


func restart()->void:
	$AnimationPlayer.play("Default")
