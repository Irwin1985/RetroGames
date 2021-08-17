extends Control

enum {
	FACIL,
	MEDIO,
	DIFICIL,
	SALIR
}

var _current_opcion := 0
var _opciones:Array = [
	"res://assets/menu_dificultad_opcion1.png",
	"res://assets/menu_dificultad_opcion2.png",
	"res://assets/menu_dificultad_opcion3.png",
	"res://assets/menu_dificultad_opcion4.png",
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
	
	if event.is_action_pressed("ui_cancel"):
		Global.change_scene("MainMenu")


func _set_opcion()->void:
	_current_opcion = int(clamp(_current_opcion, 0, 5))
	$Background.texture = load(_opciones[_current_opcion])


func _show_submenu()->void:
	Global.current_level = Global.LEVEL_1
	var _scene_name := Global.selected_game
	match _current_opcion:
		FACIL:
			Global.level_dificulty = Global.FACIL
		MEDIO:
			Global.level_dificulty = Global.MEDIO
		DIFICIL:
			Global.level_dificulty = Global.DIFICIL
		SALIR:
			_scene_name = "MainMenu"

	Global.change_scene(_scene_name)
