extends Control

signal start_game

onready var _jugador_label := $VBoxDatos/Estadisticas/VBoxContainer/Jugador
onready var _vidas_label := $VBoxDatos/Estadisticas/VBoxContainer/Vidas
onready var _nivel_label := $VBoxDatos/Estadisticas/VBoxContainer/Nivel
onready var _puntos_label := $VBoxDatos/Estadisticas/VBoxContainer/Puntos


func _input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept") and visible:
		visible = false
		emit_signal("start_game")


func update_player(new_player:int)->void:
	_jugador_label.text = "Jugador " + str(new_player)


func update_vidas(new_vidas:int)->void:
	_vidas_label.text = "Vidas " + str(new_vidas)


func update_nivel(new_nivel:int)->void:
	_nivel_label.text = "Nivel " + str(new_nivel)


func update_puntos(new_puntos:int)->void:
	_puntos_label.text = "Puntos " + str(new_puntos)
