extends Control


func update_hud(type:String, value:int) -> void:
	var _num_str = str(value)
	var _counter := 0
	if type == 'Time':
		for i in _num_str:
			_counter += 1
			var _node_name = type + str(_counter)
			var _time_node := $CanvasLayer.get_node(_node_name)
			if _time_node != null:
				_time_node.texture = Global.num_negra[int(i)]
				_time_node.visible = true
	else:
		if value < 10 and type == 'Left':
			$CanvasLayer/Left2.texture = Global.num_negra[int(value)]
			$CanvasLayer/Left2.visible = true
		else:
			for i in range(len(_num_str), 0, -1):
				var _node_name = type + str(i)
				var _time_node := $CanvasLayer.get_node(_node_name)
				if _time_node != null:
					var index: int = int(_num_str[i-1])
					_time_node.texture = Global.num_negra[index]
					_time_node.visible = true
