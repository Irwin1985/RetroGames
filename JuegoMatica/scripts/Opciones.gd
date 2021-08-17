extends Control

enum {
	SUMA_RESTA,
	MULTIPLICACION,
	DIVISION,
	FRACCION,
	NEGATIVOS,
	SALIR
}

var _current_opcion := 0
var _opciones:Array = [
	"res://assets/menu_opciones_opcion1.png",
	"res://assets/menu_opciones_opcion2.png",
	"res://assets/menu_opciones_opcion3.png",
	"res://assets/menu_opciones_opcion4.png",
	"res://assets/menu_opciones_opcion5.png",
	"res://assets/menu_opciones_opcion6.png",
]


func _ready():
	_set_opcion()
	_load_options_from_data()


func _load_options_from_data()->void:
	var _state := 0
	_state = Global.suma_resta == 0
	$Background/OpcionNegada1.visible = _state

	_state = Global.multiplica == 0
	$Background/OpcionNegada2.visible = _state
	
	_state = Global.division == 0
	$Background/OpcionNegada3.visible = _state
	$Background/OpcionNegada4.visible = !Global.fracciones
	$Background/OpcionNegada5.visible = !Global.negativos


func _input(event):
	if event.is_action_pressed("ui_down"):
		_current_opcion += 1
		_set_opcion()

	if event.is_action_pressed("ui_up"):
		_current_opcion -= 1
		_set_opcion()

	if event.is_action_pressed("ui_accept"):
		_show_submenu()

	if event.is_action_pressed("ui_cancel"):
		Global.change_scene("MainMenu")


func _set_opcion()->void:
	_current_opcion = int(clamp(_current_opcion, 0, 5))
	$Background.texture = load(_opciones[_current_opcion])


func _show_submenu()->void:
	match _current_opcion:
		SUMA_RESTA:
			_perform_action(SUMA_RESTA)
		MULTIPLICACION:
			_perform_action(MULTIPLICACION)
		DIVISION:
			_perform_action(DIVISION)
		FRACCION:
			_perform_action(FRACCION)
		NEGATIVOS:
			_perform_action(NEGATIVOS)
		SALIR:
			Global.change_scene("MainMenu")


func _perform_action(opt:int)->void:
	opt += 1
	if _is_active_option(opt) and _can_negate_option():
		_change_value(opt, false)
	else:
		_change_value(opt, true)

	_update_configuration()
	Global.save_data_to_file(null)


func _can_negate_option()->bool:
	var _cuantos := 0
	for i in $Background.get_children():
		if !i.visible:
			_cuantos += 1

	return _cuantos > 1


func _change_value(opt:int, value:bool)->void:
	var _node_str = "Background/OpcionNegada" + str(opt)
	var _node = get_node(_node_str)
	_node.visible = !value


func _is_active_option(opt:int)->bool:
	var _node_str = "Background/OpcionNegada" + str(opt)
	var _node = get_node(_node_str)
	return _node.visible == false


func _update_configuration()->void:
	var _state := 0
	if !$Background/OpcionNegada1.visible:
		_state = 1
	else:
		_state = 0

	Global.suma_resta = _state
	Global.config.suma_resta = _state

	if !$Background/OpcionNegada2.visible:
		_state = 1
	else:
		_state = 0

	Global.multiplica = _state
	Global.config.multiplicacion = _state

	if !$Background/OpcionNegada3.visible:
		_state = 1
	else:
		_state = 0
	
	Global.division = _state
	Global.config.division = _state

	if !$Background/OpcionNegada4.visible:
		_state = 1
	else:
		_state = 0

	Global.fracciones = _state
	Global.config.fracciones = _state

	if !$Background/OpcionNegada5.visible:
		_state = 1
	else:
		_state = 0

	Global.negativos = _state
	Global.config.negativos = _state
