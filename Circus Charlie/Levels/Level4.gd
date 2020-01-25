extends "res://Levels/level_base.gd"

var track_horse_position := true
var last_jump := false
var bonus_earned := false
var bonus_point := 0
var platforms_positions = {"platforms":[{"level_1":{"offset":500,"start":670,"patterns":[{"ramp1":[40,-18,4],"ramp2":[170,-18,4]},{"ramp1":[40,-35,4],"ramp2":[200,-18,4]},{"ramp1":[40,-18,4],"ramp2":[170,-35,4]},{"ramp1":[40,-35,4],"ramp2":[170,-35,4]}]}},{"level_2":{"offset":500,"start":670,"patterns":[{"ramp1":[40,-18,2],"ramp2":[170,-35,4]},{"ramp1":[40,-35,2],"ramp2":[200,-18,2]},{"ramp1":[40,-35,2],"ramp2":[170,-18,4]},{"ramp1":[40,-18,4],"ramp2":[240,-18,2]}]}},{"level_3":{"offset":500,"start":630,"patterns":[{"ramp1":[40,-18,2],"ramp2":[250,-18,2]},{"ramp1":[100,-18,0],"ramp2":[230,-18,2]},{"ramp1":[65,-35,4],"ramp2":[220,-81,2]},{"ramp1":[100,-18,4],"ramp2":[230,-70,0]}]}},{"level_4":{"offset":500,"start":630,"patterns":[{"ramp1":[10,-18,0],"ramp2":[200,-18,0]},{"ramp1":[60,-18,0],"ramp2":[220,-35,2]},{"ramp1":[60,-18,4],"ramp2":[190,-81,0]},{"ramp1":[30,-18,4],"ramp2":[240,-18,4]}]}}]}


func _ready():
	draw_platforms()
	$Player.Horse = $Horse
	if global.is_debug_mode:
		global.play_first_sound = true
		global.current_level = 3

	if global.current_check_point_path != "":
		var CheckPointNode: Position2D = get_node(global.current_check_point_path)
		if CheckPointNode != null:
			$Player.position.x = CheckPointNode.position.x
			$Horse.position.x = $Player.global_position.x + 10
			hide_objects()


func hide_objects():
	for bounce_container in $Bounce.get_children():
		for bounce in bounce_container.get_children():
			if bounce.global_position.x < $Player.global_position.x:
				bounce.queue_free()
			if int(bounce.global_position.x - $Player.global_position.x) <= 500:
				bounce.queue_free()


func _process(delta):
	if track_horse_position:
		$Horse.position.x = $Player.global_position.x + 10

	if bonus_earned:
		bonus_earned = false
		var player_pos : Vector2 = $Player.get_global_transform_with_canvas().get_origin()
		player_pos.y += 10
		player_pos.x += 35
		global.give_points(bonus_point)
		hud.show_bonus_points(player_pos, bonus_point, true)
		bonus_point = 0


func _on_Player_bonus(bonus):
	bonus_earned = true
	bonus_point = bonus
#	global.give_points(bonus)


func _on_Floor_body_entered(body):
	if body.name == global.PLAYER_NAME:
		game_over()
		$Player/Sounds/FallSound.stop()
		$Player/Sounds/HurtSound.play()


func game_over():
	$Player.hurt()
	$Sounds/LevelSound.stop()
	hud.stop_time()


func _on_Player_hit():
	track_horse_position = false


func _on_Player_win():
	player_won()
	$Podium.player_center($Player)
	$Player.position.y = 333


func _on_Player_lose():
	lose()


func _on_GameOverSound_finished():
	GameOverSound_finished()


func _on_WinSound_finished():
	WinSound_finished($Player)


func _on_GoalSensor_body_entered(body):
	if body.name == global.PLAYER_NAME:
		last_jump = true


func _on_Player_jumped(motion):
	if last_jump:
		track_horse_position = false
		$Horse.move_alone = true


func _on_Podium_player_detected():
	$Player.hit_and_fall()


func _on_PlayerPodiumRule_body_entered(body):
	if body.name == global.PLAYER_NAME:
		$Podium/CollisionShape2D.queue_free()
		$Podium/PodiumTop/CollisionShape2D.queue_free()


func draw_platforms():
	var index = 0
	var ramp_idx = 0
	var level = get_level_difficulty()
	var ramp_pair = [0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1]
	for pair in ramp_pair:
		var RampParent: Node2D = Node2D.new()
		RampParent.position = Vector2(level.start + (level.offset * index), 334)
		index += 1

		for ramp_idx in range(2):
			var x_pos = 0
			var y_pos = 0
			var ramp_size = 0
			if ramp_idx == 0:
				x_pos = level.patterns[pair].ramp1[0]
				y_pos = level.patterns[pair].ramp1[1]
				ramp_size = level.patterns[pair].ramp1[2]
			else:
				x_pos = level.patterns[pair].ramp2[0]
				y_pos = level.patterns[pair].ramp2[1]
				ramp_size = level.patterns[pair].ramp2[2]

			var Ramp: StaticBody2D = global.create_platform(ramp_size)
			Ramp.position = Vector2(x_pos, y_pos)
			RampParent.add_child(Ramp)
		$Bounce.add_child(RampParent)

#	for pair in level.pairs:
#		var RampParent: Node2D = Node2D.new()
#		RampParent.position = Vector2(670 + (level.offset * index), 334)
#		index += 1
#
#		for ramp_idx in range(2):
#			var x_pos = 0
#			var y_pos = 0
#			var ramp_size = 0
#			if ramp_idx == 0:
#				x_pos = level.patterns[pair].ramp1[0]
#				y_pos = level.patterns[pair].ramp1[1]
#				ramp_size = level.patterns[pair].ramp1[2]
#			else:
#				x_pos = level.patterns[pair].ramp2[0]
#				y_pos = level.patterns[pair].ramp2[1]
#				ramp_size = level.patterns[pair].ramp2[2]
#
#			var Ramp: StaticBody2D = global.create_platform(ramp_size)
#			Ramp.position = Vector2(x_pos, y_pos)
#			RampParent.add_child(Ramp)
#		$Bounce.add_child(RampParent)


func get_level_difficulty() -> Dictionary:
	var level: Dictionary
	match global.level_difficulty:
		global.LEVEL_1:
			level = platforms_positions.platforms[0].level_1
		global.LEVEL_2:
			level = platforms_positions.platforms[1].level_2
		global.LEVEL_3:
			level = platforms_positions.platforms[2].level_3
		global.LEVEL_4:
			level = platforms_positions.platforms[3].level_4
		_:
			level = platforms_positions.platforms[3].level_4
	return level