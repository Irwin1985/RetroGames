extends Control


func _ready() -> void:
	set_stage(Global.current_level)


func set_stage(new_stage:int) -> void:
	if new_stage < 10:
		$LetterContainer/Number1.texture = Global.num_gris[new_stage]
		$LetterContainer/Number1.visible = true
	else:
		var _num_str = str(new_stage)
		var _counter := 0
		
		for i in _num_str:
			_counter += 1
			var _sprite_name = "Number" + str(_counter)
			var _sprite_node := $LetterContainer.get_node(_sprite_name)
			if _sprite_node != null:
				_sprite_node.texture = Global.num_gris[int(i)]
				_sprite_node.visible = true


func _on_StageSound_finished() -> void:
	var _result = get_tree().change_scene("res://scenes/World.tscn")
