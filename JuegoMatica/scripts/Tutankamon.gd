extends Node

const ECUACION = "Ecuacion"
const SOLUCION = "Solucion"
const INTERRUPTOR = "Interruptor"
const ESCALERA = "Escalera"

# índices para el array de current selection
const STATE = 0
const OBJECT_ID = 1
const OBJECT_TYPE = 2

# comandos para la momia
const CMD_MOVE_LEFT = "move left"
const CMD_MOVE_RIGHT = "move right"
const CMD_GO_UP = "go up"
const CMD_GO_DOWN = "go down"
const CMD_SLIDE_DOWN = "down idle"


onready var _level = Global.level_dictionary["levels"][Global.current_level]
var _used_childrens_id: Array = []
var _current_selection: Array = [false, 0, ""]
var _tolerance := 5
var _total_ecuaciones := 0
var _puntos_por_ecuacion := 10
var _time_out_salida_momia := 60.0 / Global.level_dificulty
var _expressions_list := []
var _effect_mode := "open"
onready var _is_playing := false


func _ready():
	randomize()
	_preparese()


func _input(event):
	if event.is_action_pressed("ui_cancel") and _is_playing:
		Global.exit_to_main_menu = true
		_set_stairs_hole_visibility(false)
		_start_visual_effect("close")


func _preparese()->void:
	_spawn_elements()
	_associate_expression_nodes()
	_total_ecuaciones = int($ContenedorEcuaciones.get_child_count() / 2.0)
	_set_stairs_hole_visibility(false)
	_start_visual_effect("open")


func _update_display()->void:
	# update screen display
	$HUD.update_level(Global.current_level+1)
	$HUD.update_score(Global.current_score)
	$HUD.update_lives(Global.player_lives)
	$HUD.visible = true

	# show statistic panel (preparese)
	$Preparese.update_player(1)
	$Preparese.update_vidas(Global.player_lives)
	$Preparese.update_nivel(Global.current_level+1)
	$Preparese.update_puntos(Global.current_score)
	$Preparese.visible = true


func _start_game()->void:
	_is_playing = true
	$Player.position = $PlayerPosition.position
	$Player.animate_idle()
	$Player.set_process(true)
	$Player.visible = true

	$Momia.position = $MomiaPosition.position
	$Momia.set_process(true)

	_set_stairs_hole_visibility(true)
	$TimerSalidaMomia.wait_time = _time_out_salida_momia
	$TimerSalidaMomia.start()
	$Player.visible = true


func _spawn_elements()->void:
	var _scene_type: String
	var _node_counter := -1	
	_split_ecuacion_and_solucion()

	for data in _level:
		_scene_type = data.scene

		if _scene_type != ECUACION:
			var _instance = Global.scenes[_scene_type].instance()
			var _pos:Vector2 = _get_position_from_array(data.position)
			_instance.global_position = _pos
			if _scene_type == INTERRUPTOR:
				_instance.connect("pressed", self, "_on_interruptor_pressed")
				_instance.set_parent_id(_node_counter)
				$ContenedorInterruptores.add_child(_instance)
			else:
				if _scene_type == ESCALERA:
					if _pos.y == Global.ESCALERA_Y_PISO_1:
						$ContenedorEscalerasPiso1.add_child(_instance)
					elif _pos.y == Global.ESCALERA_Y_PISO_2:
						$ContenedorEscalerasPiso2.add_child(_instance)
					elif _pos.y == Global.ESCALERA_Y_PISO_3:
						$ContenedorEscalerasPiso3.add_child(_instance)

				else:
					$ContenedorGlobal.add_child(_instance)
		else:
			_node_counter += 1


func _split_ecuacion_and_solucion()->void:
	var _total_ecuacion_nodes = _get_total_ecuacion_nodes()
	var _array_ecuaciones: Array = _get_ecuaciones(_total_ecuacion_nodes)
	var _array_soluciones: Array = []

	for i in _total_ecuacion_nodes:
		if !_array_ecuaciones.has(i):
			_array_soluciones.append(i)
			var _elem := $ContenedorEcuaciones.get_child(i)
			_elem.set_type(SOLUCION)


func _get_ecuaciones(total:int)->Array:
	var _ecuaciones:Array = []
	var _times := 0
	var _middle := int(total / 2.0)

	while _times < _middle:
		var _id := randi() % total
		if !_ecuaciones.has(_id):
			_times += 1
			_ecuaciones.append(_id)

	return _ecuaciones


func _associate_expression_nodes()->void:
	var _ecuacion_node:Node2D = null
	var _solucion_node:Node2D = null
	
	while true:
		_ecuacion_node = _get_unpaired_node(ECUACION)
		if _ecuacion_node == null:
			return

		_solucion_node = _get_unpaired_node(SOLUCION)
		if _solucion_node == null:
			return

		# emparejamos ambos nodos (ecuacion y solución)
		_ecuacion_node.set_child_id(_solucion_node.get_index())
		_solucion_node.set_parent_id(_ecuacion_node.get_index())
		
		# actualizar la propiedad  has_pair
		_ecuacion_node.has_pair = true
		_solucion_node.has_pair = true
		
		_solucion_node.draw_result(_ecuacion_node.get_result())


func _get_unpaired_node(type: String)->Node2D:
	var _total := $ContenedorEcuaciones.get_child_count()
	var _times := 0

	if _used_childrens_id.size() >= _total:
		return null

	while _times < _total:
		var _i := randi() % _total
		if _used_childrens_id.has(_i):
			continue
		var _elem:Node2D = $ContenedorEcuaciones.get_child(_i)
		if _elem.get_type() == type:
			_used_childrens_id.append(_i)
			return _elem
		else:
			_times += 1

	return null


func _get_total_ecuacion_nodes()->int:
	var _total := 0
	for i in _level:
		if i.scene == ECUACION:
			_total += 1
			var _pos := _get_position_from_array(i.position)
			_add_ecuacion_to_container(_pos)

	return _total


func _add_ecuacion_to_container(pos:Vector2)->void:
	var _instance = Global.scenes[ECUACION].instance()
	_instance.set_type(ECUACION)
	_instance.global_position = pos
	var _expression := Global.generate_expression(_expressions_list)
	_instance.draw_formula(_expression)
	$ContenedorEcuaciones.add_child(_instance)


func _get_position_from_array(array:Array)->Vector2:
	return Vector2(array[Global.X_POS], array[Global.Y_POS])


func _on_interruptor_pressed(interruptor_node:Node, parent_id:int)->void:
	var _obj = _get_ecuacion_from_container(parent_id)
	if _obj.is_resolved():
		return

	var _id = _obj.get_id()
	var _obj_type = _obj.get_type()

	if !_current_selection[STATE]:
		_current_selection[STATE] = true
		_current_selection[OBJECT_ID] = _id
		_current_selection[OBJECT_TYPE] = _obj_type
		_apply_selection(interruptor_node, _obj)
	else:
		if _obj_type == _current_selection[OBJECT_TYPE]:
			$Player.animate_say_no()
			return

		if _current_selection[OBJECT_ID] == parent_id:
			$Player.animate_switch()
			yield(get_tree().create_timer(0.15), "timeout")
			interruptor_node.switch_texture()
			yield(get_tree().create_timer(0.3), "timeout")
			_obj.change_texture("selected")
			
			yield(get_tree().create_timer(0.3), "timeout")
			var _parent_obj = _get_ecuacion_from_container(_id)
			_parent_obj.change_texture("matched")
			_obj.change_texture("matched")
			_update_total_ecuaciones()
			_reset_temporary_array()
		else:
			$Player.animate_say_no()


func _apply_selection(interruptor, ecuacion)->void:
	$Player.animate_switch()
	yield(get_tree().create_timer(0.15), "timeout")
	interruptor.switch_texture()
	yield(get_tree().create_timer(0.3), "timeout")
	ecuacion.change_texture("selected")


func _update_total_ecuaciones()->void:
	_total_ecuaciones -= 1
	Global.current_score += _puntos_por_ecuacion
	$HUD.update_score(Global.current_score)

	if _total_ecuaciones <= 0:
		_stop_momia()
		$Player.win()


func _stop_momia()->void:
	$Momia.visible = false
	$TimerSalidaMomia.stop()
	$TimerAlgoritmoMomia.stop()
	$Momia.drop_instructions()
	$Momia.position = $MomiaPosition.position
	$Momia.set_process(false)


func _stop_player()->void:
	$Player.visible = false
	$Player.animate_idle()
	$Player.set_process(false)


func _get_ecuacion_from_container(node_id:int)->Node:
	return $ContenedorEcuaciones.get_child(node_id)


func _reset_temporary_array()->void:
	_current_selection[STATE] = false
	_current_selection[OBJECT_ID] = 0
	_current_selection[OBJECT_TYPE] = ""


func _on_Character_wanted_climb(area:Area2D, direction:int)->void:
	var _player_pos = int(area.position.x)
	var _range:Array = _calculate_tolerance(_player_pos)
	var _x_pos := 0
	
	var _player_floor := Global.y_positions.find(int(area.position.y))

	_player_floor += 1
	if direction == Global.MOVE_UP:
		if _player_floor == 1:
			return
		var _node := _get_contenedor_escalera(_player_floor-1)
		# recorro las escaleras
		for i in _node.get_children():
			_x_pos = int(i.global_position.x)
			if _x_pos >= _range[0] and _x_pos <= _range[1]:
				area.up_stairs()

	elif direction == Global.MOVE_DOWN:
		if _player_floor == 4:
			return

		var _floor := _player_floor
		var _node := _get_contenedor_escalera(_floor)
		# recorro las escaleras
		for i in _node.get_children():
			_x_pos = int(i.global_position.x)
			if _x_pos >= _range[0] and _x_pos <= _range[1]:
				area.down_stairs()


func _get_contenedor_escalera(_floor:int)->Node2D:
	if _floor == 4:
		_floor = 3
	var _str_node = "ContenedorEscalerasPiso" + str(_floor)
	return get_node(_str_node) as Node2D


func _calculate_tolerance(player_pos:int)->Array:
	return [player_pos - _tolerance, player_pos + _tolerance]


func _on_TimerSalidaMomia_timeout():
	$Sarcofago/AnimationPlayer.play("Start")


func _on_Sarcofago_animation_finished(anim_name):
	if anim_name == "Start":
		$Momia.visible = true
		$Momia.add_instruction(CMD_MOVE_LEFT)
		$Momia.add_instruction(CMD_SLIDE_DOWN)
		$Momia.set_process(true)


func _on_TimerAlgoritmoMomia_timeout():
	# Solo generaremos instrucciones cuando
	# la momia esté en estado IDLE.
	if $Momia.is_idle():
		$TimerAlgoritmoMomia.stop()
		var _ins = _generate_instruction()
		$Momia.add_instruction(_ins)
		$TimerAlgoritmoMomia.start()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Algoritmo para perseguir al jugador.
1. Detectar el piso del jugador
2.	¿Está en el mismo piso que la Momia?
3.		Sí-> Moverse a la dirección del jugador
4.		No-> ¿Está arriba?
5.			Sí-> ¿Estoy en una escalera?
6.				Sí->Subir
7.				No->Detectar escalera más cercana
8.			No-> ¿Estoy en una escalera?
9.				Sí->Bajar
10.				No->Detectar escalera más cercana
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
func _generate_instruction()->String:
	var _player_floor = $Player.position.y
	var _momia_floor = $Momia.position.y
	var _player_x = $Player.position.x
	var _momia_x = $Momia.position.x

	# 1. Detectar el piso del jugador
	# 2. ¿Está en el mismo piso que la Momia?
	if _player_floor == _momia_floor:
		# 3. Sí-> Moverse a la dirección del jugador
		if _player_x > _momia_x:
			return CMD_MOVE_RIGHT
		else:
			return CMD_MOVE_LEFT
	else:
		var _direction := 0
		# 4. No-> ¿Está arriba?
		if _player_floor < _momia_floor:
			_direction = Global.MOVE_UP
			# 5. Sí-> ¿Estoy en una escalera?
			if _momia_is_in_stairs(Global.MOVE_UP):
				# 6. Sí->Subir
				return CMD_GO_UP
		elif _player_floor > _momia_floor:
			_direction = Global.MOVE_DOWN
			# 8. No-> ¿Estoy en una escalera?
			if _momia_is_in_stairs(Global.MOVE_DOWN):
				# 9. Sí->Bajar
				return CMD_GO_DOWN

		# (7,10). No->Detectar escalera más cercana
		return _where_is_the_nearest_ladder(_direction)


# detecta la escalera más cercana
# y devuelve la instrucción correspondiente.
func _where_is_the_nearest_ladder(_direction:int)->String:
	var _momia_pos = int($Momia.position.x)
	var _left_ladder = _get_nearest_ladder(Global.MOVE_LEFT, _direction)
	var _right_ladder = _get_nearest_ladder(Global.MOVE_RIGHT, _direction)

	if _left_ladder == -1:
		return CMD_MOVE_RIGHT

	if _right_ladder == -1:
		return CMD_MOVE_LEFT

	var _dif_left = _momia_pos - _left_ladder
	var _dif_right = _right_ladder - _momia_pos

	if _dif_left <= _dif_right:
		return CMD_MOVE_LEFT
	else:
		return CMD_MOVE_RIGHT


# retorna la posición de la escalera
# más cercana a la momia.
func _get_nearest_ladder(direction:int, y_pos:int)->int:
	var _momia_pos = int($Momia.position.x)
	var _momia_floor := Global.y_positions.find(int($Momia.position.y))
	_momia_floor += 1

	var _node: Node2D = null
	if y_pos == Global.MOVE_UP:
		_node = _get_contenedor_escalera(_momia_floor-1)
	elif y_pos == Global.MOVE_DOWN:
		_node = _get_contenedor_escalera(_momia_floor)

	if direction == Global.MOVE_LEFT:
		for i in range(_node.get_child_count()-1, -1, -1):
			var _location = _node.get_child(i).global_position.x
			if _location < _momia_pos:
				return _location
		return -1
	else: # moving RIGHT
		for i in _node.get_children():
			if i.global_position.x > _momia_pos:
				return i.global_position.x
		return -1


# verifica si la momia se encuentra
# en una escalera dada su posición
func _momia_is_in_stairs(direction:int)->bool:

	var _momia_pos = int($Momia.position.x)
	var _range:Array = _calculate_tolerance(_momia_pos)
	var _momia_floor := Global.y_positions.find(int($Momia.position.y))
	var _x_pos:= 0
	_momia_floor += 1

	if direction == Global.MOVE_UP:
		if _momia_floor == 1:
			return false
		var _node := _get_contenedor_escalera(_momia_floor-1)
		# recorro las escaleras
		for i in _node.get_children():
			_x_pos = int(i.global_position.x)
			if _x_pos >= _range[0] and _x_pos <= _range[1]:
				return true

	elif direction == Global.MOVE_DOWN:
		if _momia_floor == 4:
			return false

		var _floor := _momia_floor
		var _node := _get_contenedor_escalera(_floor)
		# recorro las escaleras
		for i in _node.get_children():
			_x_pos = int(i.global_position.x)
			if _x_pos >= _range[0] and _x_pos <= _range[1]:
				return true

	return false
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Fin del algoritmo para la momia
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


func _on_Player_dead():
	$TimerAlgoritmoMomia.stop()
	$Momia.win()
	$Player.animate_dead($Momia.facing())
	yield(get_tree().create_timer(1.5), "timeout")
	_set_stairs_hole_visibility(false)

	Global.player_lives -= 1
	if Global.player_lives <= 0:
		Global.change_scene("GameOver")

	_start_visual_effect("close")


func _game_over()->void:
	Global.player_lives -= 1
	_new_game()


func _new_game()->void:
	_stop_player()
	_stop_momia()
	$Sarcofago.restart()
	_free_elements()
	_preparese()


func _free_elements()->void:
	for i in $ContenedorEcuaciones.get_children():
		$ContenedorEcuaciones.remove_child(i)
		i.queue_free()
	
	for i in $ContenedorEscalerasPiso1.get_children():
		$ContenedorEscalerasPiso1.remove_child(i)
		i.queue_free()
	
	for i in $ContenedorEscalerasPiso2.get_children():
		$ContenedorEscalerasPiso2.remove_child(i)
		i.queue_free()
	
	for i in $ContenedorEscalerasPiso3.get_children():
		$ContenedorEscalerasPiso3.remove_child(i)
		i.queue_free()
	
	for i in $ContenedorGlobal.get_children():
		$ContenedorGlobal.remove_child(i)
		i.queue_free()
	
	for i in $ContenedorInterruptores.get_children():
		$ContenedorInterruptores.remove_child(i)
		i.queue_free()


# oculta momentaneamente los hoyuelos de las escaleras.
func _set_stairs_hole_visibility(visible:bool):
	for i in $ContenedorEscalerasPiso1.get_children():
		i.set_hole_visibility(visible)
	
	for i in $ContenedorEscalerasPiso2.get_children():
		i.set_hole_visibility(visible)
	
	for i in $ContenedorEscalerasPiso3.get_children():
		i.set_hole_visibility(visible)


func _start_visual_effect(mode:String)->void:
	_effect_mode = mode
	$Efecto.visible = true
	var _from := 0
	var _to := 0
	var _time := 1.5
	if mode == "open":
		$Efecto.color = Color(0, 0, 0, 255)
		_from = 255
		_to = 0
	else:
		_time = 0.5
		_from = 0
		_to = 255
	
	$Efecto/Tween.interpolate_property($Efecto, 'color', Color(0,0,0,_from), Color(0,0,0,_to), _time, Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	$Efecto/Tween.start()


func _on_Tween_tween_completed(_object, _key):
	if _effect_mode == "open":
		_update_display()
		$Efecto.visible = false
	else:
		Global.change_scene("Refresh")


func _on_Momia_ready_to_go():
	$TimerAlgoritmoMomia.wait_time = 1
	$TimerAlgoritmoMomia.start()


func _on_Player_dancing_done():
	Global.current_level += 1
	_set_stairs_hole_visibility(false)
	_start_visual_effect("close")
