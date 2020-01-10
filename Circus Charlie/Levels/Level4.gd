extends "res://Levels/level_base.gd"


func _ready():
	$Player.Horse = $Horse

func _process(delta):
	$Horse.position.x = $Player.global_position.x

