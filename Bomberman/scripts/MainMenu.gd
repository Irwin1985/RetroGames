extends Node2D

onready var arrow_position := [
	$StartPosition.global_position,
	$ContinuePosition.global_position,
]

var cur_state := false


func _ready() -> void:
	OS.center_window()
	set_arrow()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("select"):
		cur_state = not cur_state
		set_arrow()
	if Input.is_action_just_pressed("start"):
		_call_scene()


func _call_scene() -> void:
	if cur_state:
		print("continue...")
	else:
		var _result := get_tree().change_scene("res://scenes/Stage.tscn")


func set_top(new_top:int) -> void:
	var _top_str = str(new_top)
	var _counter := 0

	for i in _top_str:
		_counter += 1
		var _sprite_name = "Sprite" + str(_counter)
		var _sprite_node := $Top.get_node(_sprite_name)
		if _sprite_node != null:
			_sprite_node.texture = Global.num_gris[int(i)]
			_sprite_node.visible = true
			


func set_arrow() -> void:
	$ArrowSprite.position = arrow_position[_convert_state()]


func _convert_state() -> int:
	return 0 if not cur_state else 1
