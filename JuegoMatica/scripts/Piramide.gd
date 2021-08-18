extends Node2D

enum {
	OPCION_1,
	OPCION_2,
	OPCION_3,
}

var _results := [0,0,0]
var _correct_index := 0
var _time_left := 0

var _puntos := 0
var _errores := 10
var _record = Global.config.piramide_record


func _ready():
	randomize()
	$HUD/Cronometro/Timer.stop()
	$PlayerPiramide.pause()

	if Global.level_dificulty == Global.FACIL:
		_time_left = 60
	elif Global.level_dificulty == Global.MEDIO:
		_time_left = 30
	elif Global.level_dificulty == Global.DIFICIL:
		_time_left = 10

	yield(get_tree().create_timer(1), "timeout")
	_generate_expression()


func _set_timer()->void:
	$HUD/Cronometro.count_down(_time_left)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Global.change_scene("MainMenu")


func _generate_expression()->void:

	var _expr := Global.generate_expression([])
	_update_ecuacion(_expr[Global.FORMULA])
	var _result = _expr[Global.RESULT]
	_correct_index = randi() % 3
	_results[_correct_index] = _result

	if _correct_index == 0:
		_generate_fake_result(1, 2, _result)
	elif _correct_index == 1:
		_generate_fake_result(0, 2, _result)
	else:
		_generate_fake_result(0, 1, _result)
	
	_update_display()
	_set_timer()
	$PlayerPiramide.resume()
	set_process(true)


func _generate_fake_result(idx_1: int, idx_2: int, resp:float)->void:
	
	_results[idx_1] = resp + int(1+rand_range(resp-5, resp+5))
	_results[idx_2] = resp + int(1+rand_range(resp-10, resp+10))


func _update_ecuacion(new_expr:String)->void:
	$HUD/LabelEcuacion.text = new_expr


func _update_display()->void:
	# estadísticas
	$HUD/LabelPuntos.text = str(_puntos)
	$HUD/LabelErrores.text = str(_errores)
	$HUD/LabelRecord.text = str(Global.piramide_record)
	# resultados
	$HUD/LabelOpcion1.text = str(_results[OPCION_1])
	$HUD/LabelOpcion2.text = str(_results[OPCION_2])
	$HUD/LabelOpcion3.text = str(_results[OPCION_3])


func _on_Cronometro_times_up() -> void:
	$HUD/Cronometro.pause()
	$PlayerPiramide.pause()
	set_process(false)
	$HUD/TiempoTerminado.set_respuesta(_results[_correct_index])


func _on_PlayerPiramide_option_selected(selected_option:int) -> void:
	if _results[selected_option] == _results[_correct_index]:
		_puntos += 10
		Global.current_score = _puntos
		_generate_expression()
	else:
		_errores -= 1
		$HUD/Cronometro.pause()
		$PlayerPiramide.pause()
		set_process(false)
		$HUD/RespuestaIncorrecta.set_respuesta(_results[_correct_index])


func _game_over()->void:
	Global.change_scene("GameOver", {"caller": "Piramide"})


func _on_RespuestaIncorrecta_resume_game() -> void:
	_new_game()


func _new_game()->void:
	$PlayerPiramide.resume()
	_generate_expression()
	if _errores <= 0:
		_game_over()


func _on_TiempoTerminado_resume_game() -> void:
	_new_game()
