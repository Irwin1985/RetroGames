extends Control

enum {
	TUTANKAMON,
	PIRAMIDES,
	SALIR
}

var _current_opcion := 0
var _opciones:Array = [
	"res://assets/menu_jugar_opcion1.png",
	"res://assets/menu_jugar_opcion2.png",
	"res://assets/menu_jugar_opcion3.png"
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
	var _scene_name := "Dificultad"
	match _current_opcion:
		TUTANKAMON:
			Global.selected_game = "Tutankamon"
		PIRAMIDES:
			Global.selected_game = "Piramide"
		SALIR:
			_scene_name = "MainMenu"

	Global.change_scene(_scene_name)


