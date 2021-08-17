extends Control

enum {
	JUGAR,
	OPCIONES,
	INFORMACION,
	PUNTUACIONES,
	CREDITOS,
	SALIR
}

var _current_opcion := 0
var _opciones:Array = [
	"res://assets/menu_base_opcion1.png",
	"res://assets/menu_base_opcion2.png",
	"res://assets/menu_base_opcion3.png",
	"res://assets/menu_base_opcion4.png",
	"res://assets/menu_base_opcion5.png",
	"res://assets/menu_base_opcion6.png",
]


func _ready():
	_set_opcion()


func _input(event):
	if event.is_action_pressed("ui_down"):
		_current_opcion += 1
		_set_opcion()
	if event.is_action_pressed("ui_up"):
		_current_opcion -= 1
		_set_opcion()
	if event.is_action_pressed("ui_accept"):
		_show_submenu()


func _set_opcion()->void:
	_current_opcion = int(clamp(_current_opcion, 0, 5))
	$Background.texture = load(_opciones[_current_opcion])


func _show_submenu()->void:
	var _scene_name := ""
	match _current_opcion:
		JUGAR:
			_scene_name = "Jugar"
		OPCIONES:
			_scene_name = "Opciones"
		INFORMACION:
			_scene_name = ""
		PUNTUACIONES:
			Global.show_scores_readonly = true
			_scene_name = "Posiciones"
		CREDITOS:
			_scene_name = "Creditos"
		SALIR:
			get_tree().quit()

	Global.change_scene(_scene_name)
