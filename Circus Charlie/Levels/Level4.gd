extends "res://Levels/level_base.gd"

var track_horse_position := true
var last_jump := false
var bonus_earned := false
var bonus_point := 0

func _ready():
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
		hud.show_bonus_points(player_pos, bonus_point)
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