extends "res://Levels/level_base.gd"

export (PackedScene) var single_flame
export (PackedScene) var boiler

var pos = Vector2(0, 0)
var last_flame = null
var next_bonus_flame : int = 0

func _ready():
	if global.is_debug_mode:
		global.play_first_sound = true
		global.current_level = 0

	set_sfx_volume()
	set_player_position()
	next_bonus_flame = randi() % 5 + 4
	spawn_boiler()
	spawn_next_flame()


func set_sfx_volume():
	for audio in $Sounds.get_children():
		audio.volume_db = global.STANDARD_VOLUME


func set_player_position():
	if global.current_check_point_path != "":
		var CheckPointNode: Position2D = get_node(global.current_check_point_path)
		if CheckPointNode != null:
			$Lion.position.x = CheckPointNode.position.x


func spawn_next_flame():
	var flame = single_flame.instance()
	var rand = randi() % 4
	
	if last_flame == null:
		pos = Vector2($Lion.position.x + 380, 184)
	else:
		pos = last_flame.position + Vector2.RIGHT * (380 if (rand / 2) * 2 == 0 else 300)
	
	flame.position = pos
	if next_bonus_flame <= 0:
		next_bonus_flame = randi() % 12 + 4 # 4..15
		flame.start("bonus")
	else:
		flame.start("big")
	
	flame.connect("hurt", $Lion, "hurt")
	flame.connect("appear", self, "_on_Flame_appear")
	flame.connect("disappear", self, "_on_Flame_disappear")
	flame.connect("bonus", self, "show_points_on_player")
	$FlameContainer.call_deferred("add_child", flame)
	
	last_flame = flame
	next_bonus_flame -= 1


func spawn_boiler():
	var CheckPointNode: Position2D
	if global.current_check_point_path != "":
		CheckPointNode = get_node(global.current_check_point_path)

	for i in range(10):
		var bx : float = 545 + (500 * i)
		if CheckPointNode == null or CheckPointNode.position.x < bx:
			var b = boiler.instance()
			b.position = Vector2(bx, 379)
			b.connect("hurt", $Lion, "hurt")
			b.connect("bonus", self, "show_points_on_player")
			$BoilerContainer.add_child(b)


func _on_Flame_appear(flame : FlameRing)->void:
	if flame == last_flame:
		spawn_next_flame()


func _on_Flame_disappear(flame : FlameRing)->void:
	if flame.position.x < $Lion.position.x:
		flame.call_deferred("queue_free")


func show_points_on_player(points: int):
	var player_pos : Vector2 = $Lion.get_global_transform_with_canvas().get_origin()
	player_pos.y -= 70
	hud.show_bonus_points(player_pos, points)


func stop_items():
	for boiler in $BoilerContainer.get_children():
		boiler.stop()

	for flame in $FlameContainer.get_children():
		flame.stop()
		flame.set_process(false)


func _on_Lion_lose():
	stop_items()
	lose()


func _on_GameOverSound_finished():
	GameOverSound_finished()


func _on_Lion_win():
	for flame in $FlameContainer.get_children():
		flame.call_deferred("queue_free")
	stop_items()
	player_won()
	$Items/Podium.player_center($Lion)


func _on_WinSound_finished():
	WinSound_finished($Lion)