extends Control

onready var _titulo := $VBoxContainer/JuegoTerminado


func _ready() -> void:
	var _caller = Global.get_param("caller")
	if _caller != null:
		if _caller == "Piramide":
			$VBoxContainer/Jugador1.visible = false


func _input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		if Global.selected_game == "Tutankamon":
			if Global.current_score > Global.config.scores[0].score:
				Global.show_scores_readonly = false
				Global.change_scene("Posiciones")
			else:
				Global.change_scene("MainMenu")
		else:
			if _titulo.text == "JUEGO TERMINADO" and Global.current_score > Global.config.piramide_record:
				Global.config.piramide_record = Global.current_score
				Global.save_data_to_file()
				_titulo.text = "NUEVO RECORD"
			else:
				Global.change_scene("MainMenu")
