extends Area2D

var _textures:Array = [
	load("res://assets/textures/powerup_bomb.png"),
	load("res://assets/textures/powerup_flame.png"),
	load("res://assets/textures/powerup_speed.png"),
	load("res://assets/textures/powerup_wallpass.png"),
	load("res://assets/textures/powerup_detonator.png"),
	load("res://assets/textures/powerup_bombpass.png"),
	load("res://assets/textures/powerup_flamepass.png"),
	load("res://assets/textures/powerup_mistery.png"),
]


func set_powerup(value:int) -> void:
	$Sprite.texture = _textures[value]
