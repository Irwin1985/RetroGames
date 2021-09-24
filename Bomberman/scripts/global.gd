extends Node

# Array de números
var num_gris := [
	load("res://assets/fonts/gris/0.png"),
	load("res://assets/fonts/gris/1.png"),
	load("res://assets/fonts/gris/2.png"),
	load("res://assets/fonts/gris/3.png"),
	load("res://assets/fonts/gris/4.png"),
	load("res://assets/fonts/gris/5.png"),
	load("res://assets/fonts/gris/6.png"),
	load("res://assets/fonts/gris/7.png"),
	load("res://assets/fonts/gris/8.png"),
	load("res://assets/fonts/gris/9.png"),
]

var num_negra := [
	load("res://assets/fonts/negra/0.png"),
	load("res://assets/fonts/negra/1.png"),
	load("res://assets/fonts/negra/2.png"),
	load("res://assets/fonts/negra/3.png"),
	load("res://assets/fonts/negra/4.png"),
	load("res://assets/fonts/negra/5.png"),
	load("res://assets/fonts/negra/6.png"),
	load("res://assets/fonts/negra/7.png"),
	load("res://assets/fonts/negra/8.png"),
	load("res://assets/fonts/negra/9.png"),
]

# nivel del juego
var current_level := 1


func _ready() -> void:
	# TODO: quitar para producción
	OS.current_screen = 1

