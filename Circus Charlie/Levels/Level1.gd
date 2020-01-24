extends "res://Levels/level_base.gd"

export (PackedScene) var single_flame
export (PackedScene) var boiler

var pos = Vector2(0, 0)
var last_flame = null
var next_bonus_flame : int = 0
var patterns = [
# Level 1
	[
		{ 'distance': 133, 'type': "big" },
		{ 'distance': 180, 'type': "big" },
		{ 'distance': 132, 'type': "big" },
		{ 'distance': 212, 'type': "big" },
		{ 'distance': 134, 'type': "big" },
		{ 'distance': 228, 'type': "bonus" },
		{ 'distance': 228, 'type': "big" },
		{ 'distance': 132, 'type': "big" },
		{ 'distance': 212, 'type': "big" },
		{ 'distance': 199, 'type': "big" },
		{ 'distance': 164, 'type': "big" },
		{ 'distance': 148, 'type': "big" },
		{ 'distance': 196, 'type': "big" },
		{ 'distance': 212, 'type': "big" },
		{ 'distance': 132, 'type': "big" },
		{ 'distance': 228, 'type': "big" }
	],
# Level 6
	[
		{ 'distance': 147, 'type': "big" },
		{ 'distance': 147, 'type': "big" },
		{ 'distance': 235, 'type': "big" },
		{ 'distance':6, 'type': "big" },
		{ 'distance': 231, 'type': "bonus" },
		{ 'distance': 115, 'type': "big" },
		{ 'distance': 99, 'type': "big" },
		{ 'distance': 138, 'type': "big" },
		{ 'distance': 131, 'type': "bonus" },
		{ 'distance': 111, 'type': "big" },
		{ 'distance': 131, 'type': "big" },
		{ 'distance': 147, 'type': "big" },
		{ 'distance': 99, 'type': "big" },
		{ 'distance': 143, 'type': "big" },
		{ 'distance': 147, 'type': "bonus" },
		{ 'distance': 96, 'type': "big" }
	],
# Level 11
	[
		{ 'distance': 83, 'type': "big" },
		{ 'distance': 147, 'type': "bonus" },
		{ 'distance': 147, 'type': "big" },
		{ 'distance': 235, 'type': "big" },
		{ 'distance':6, 'type': "big" },
		{ 'distance': 232, 'type': "bonus" },
		{ 'distance': 83, 'type': "big" },
		{ 'distance': 148, 'type': "big" },
		{ 'distance': 147, 'type': "big" },
		{ 'distance': 95, 'type': "bonus" },
		{ 'distance': 147, 'type': "big" },
		{ 'distance': 96, 'type': "big" },
		{ 'distance': 163, 'type': "big" },
		{ 'distance': 234, 'type': "big" },
		{ 'distance':6, 'type': "big" },
		{ 'distance': 232, 'type': "big" }
	],
# Level 16 onwards
	[
		{ 'distance': 165, 'type': "big" },
		{ 'distance': 164, 'type': "big" },
		{ 'distance': 235, 'type': "bonus" },
		{ 'distance':6, 'type': "big" },
		{ 'distance': 232, 'type': "big" },
		{ 'distance': 68, 'type': "bonus" },
		{ 'distance': 180, 'type': "big" },
		{ 'distance': 68, 'type': "big" },
		{ 'distance': 179, 'type': "bonus" },
		{ 'distance': 66, 'type': "big" },
		{ 'distance': 245, 'type': "big" },
		{ 'distance':6, 'type': "bonus" },
		{ 'distance': 233, 'type': "big" },
		{ 'distance': 68, 'type': "big" },
		{ 'distance': 181, 'type': "big" },
		{ 'distance': 68, 'type': "bonus" },
		{ 'distance': 176, 'type': "big" }
	],
	#Test extreme difficulty
	[
		{ 'distance': 165, 'type': "big" },
		{ 'distance': 40, 'type': "big" },
		{ 'distance': 164, 'type': "big" },
		{ 'distance':6, 'type': "bonus" },
		{ 'distance':12, 'type': "big" },
		{ 'distance': 232, 'type': "big" },
		{ 'distance': 68, 'type': "bonus" },
		{ 'distance': 180, 'type': "big" },
		{ 'distance': 6, 'type': "big" },
		{ 'distance': 68, 'type': "big" },
		{ 'distance': 68, 'type': "bonus" },
		{ 'distance': 66, 'type': "big" },
		{ 'distance': 245, 'type': "bonus" },
		{ 'distance':6, 'type': "bonus" },
		{ 'distance': 120, 'type': "big" },
		{ 'distance': 68, 'type': "big" },
		{ 'distance': 120, 'type': "big" },
		{ 'distance': 6, 'type': "big" },
		{ 'distance': 6, 'type': "big" },
		{ 'distance': 6, 'type': "big" },
		{ 'distance': 68, 'type': "bonus" },
		{ 'distance': 176, 'type': "big" }
	]
]

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
	var this_pattern = patterns[int(min(global.level_difficulty - 1, 3))]
	var this_flame = this_pattern[global.level_pattern]

	if last_flame == null:
		pos = Vector2($Lion.position.x + 380, 184)
	else:
		pos = last_flame.position + Vector2.RIGHT * this_flame['distance'] * 2
	
	flame.position = pos
	flame.start(this_flame["type"])
	
	flame.connect("hurt", $Lion, "hurt")
	flame.connect("appear", self, "_on_Flame_appear")
	flame.connect("disappear", self, "_on_Flame_disappear")
	flame.connect("bonus", self, "show_points_on_player")
	$FlameContainer.call_deferred("add_child", flame)
	
	last_flame = flame
	
	global.level_pattern = (global.level_pattern + 1) % len(this_pattern)


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