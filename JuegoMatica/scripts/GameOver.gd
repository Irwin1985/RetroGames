extends Control


func _input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		if Global.current_score > Global.config.scores[0].score:
			Global.show_scores_readonly = false
			Global.change_scene("Posiciones")
		else:
			Global.change_scene("MainMenu")
