extends Control


func _input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		Global.change_scene("MainMenu")

