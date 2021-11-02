extends Node2D

export (PackedScene) var BrickScene
export (PackedScene) var ExitScene
export (PackedScene) var PowerupScene

const BLOCK_OFFSET = 32
const NUM_ROWS = 11
const LEFT_SIDE = 15
const RIGHT_SIDE = 14

const TIME = 200
var time_left: int = TIME

var left_bricks:Dictionary
var right_bricks:Dictionary
var level_bricks:int


func _ready() -> void:
	randomize()
	OS.center_window()
	_add_static_blocks()
	$HUD.update_hud("Time", TIME)
	$HUD.update_hud("Left", Global.lives)
	_set_environment()
	

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
	
			colShape.shape = rectangleShape2D
			colShape.position = Vector2(pos.x + BLOCK_OFFSET * j if j > 0 else pos.x, pos.y)
			$CollisionContainer.add_child(colShape)


func _on_GameTimer_timeout() -> void:
	time_left -= 1
	$HUD.update_hud("Time", time_left)
	if time_left <= 0:
		pass # game over


func _set_environment() -> void:
	left_bricks = Global.left_bricks
	right_bricks = Global.right_bricks
	level_bricks = Global.get_level_bricks()

	var l_bricks := int(level_bricks / 2)
	var r_bricks := level_bricks - l_bricks
	_generate_bricks(LEFT_SIDE, l_bricks)
	_generate_bricks(RIGHT_SIDE, r_bricks)
	_set_door()
	_set_powerup()


func _generate_bricks(cols:int, bricks:int) -> void:
	var col:int = 0
	var row:int = 0
	var key:String
	var BrickInstance = null
	var brick_pos: Vector2

	for i in bricks:
		while true:
			key = _get_key(cols)
			if key == 'a1' or key == 'b3':
				continue
			if cols == LEFT_SIDE:
				if !left_bricks[key][0]:
					left_bricks[key][0] = true
					brick_pos = left_bricks[key][1]
					break
			else:
				if !right_bricks[key][0]:
					right_bricks[key][0] = true
					brick_pos = right_bricks[key][1]
					break
		# create the brick
		BrickInstance = BrickScene.instance()
		BrickInstance.update_pos(brick_pos)
		BrickInstance.connect("show_secret", self, "_on_brick_show_secret")
		$BreakContainer.add_child(BrickInstance)


func _set_door() -> void:
	var _random_brick := randi() % $BreakContainer.get_child_count()
	var BrickInstance := $BreakContainer.get_child(_random_brick)

	if BrickInstance != null:
		BrickInstance.set_secret_type(Global.DOOR)


func _set_powerup() -> void:
	var _random_brick := randi() % $BreakContainer.get_child_count()
	var BrickInstance := $BreakContainer.get_child(_random_brick)

	if BrickInstance != null:
		BrickInstance.set_secret_type(Global.POWERUP)
		BrickInstance.set_secret_value(_get_ramdon_powerup())


func _get_ramdon_powerup() -> int:
	return randi() % 7


func _get_key(cols:int) -> String:
	var col = randi() % cols
	var row = _get_row()
	var key = Global.num_to_letter(col) + str(row)
	
	return key


func _get_row() -> int:
	var row: int = 0
	row = randi() % NUM_ROWS

	while row % 2 == 0:
		row = randi() % NUM_ROWS

	return row


func _on_brick_show_secret(type:int, value:int) -> void:
	if type == Global.DOOR:
		var ExitInstance
		ExitInstance = ExitScene.instance()
		add_child(ExitInstance)
	elif type == Global.POWERUP:
		var PowerupInstance
		PowerupInstance = PowerupScene.instance()
		PowerupInstance.set_powerup(value)
		add_child(PowerupInstance)
