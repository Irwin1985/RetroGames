extends Node2D

const BLOCK_OFFSET = 32

func _ready() -> void:
	OS.center_window()
	_add_static_blocks()


func _add_static_blocks() -> void:
	# creamos la figura (RectangleShape2D)
	# para ahorrar recursos.
	var rectangleShape2D = RectangleShape2D.new()
	rectangleShape2D.extents = Vector2(8, 8)

	for i in 5: # for exterior (FILAS)
		var position2D = get_node("PositionContainer/Position" + str(i))
		for j in 14: # for interior (COLUMNAS)
			var colShape = CollisionShape2D.new()
			var pos = position2D.position

#			if j > 0:
#				x = 32 * j
#				pos.x += BLOCK_OFFSET * j
	
			colShape.shape = rectangleShape2D
			colShape.position = Vector2(pos.x + BLOCK_OFFSET * j if j > 0 else pos.x, pos.y)
			$CollisionContainer.add_child(colShape)

