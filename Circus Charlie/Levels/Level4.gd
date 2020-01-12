extends "res://Levels/level_base.gd"
var track_horse_position := true
var last_jump := false

func _ready():
	$Player.Horse = $Horse
#	Test only = delete when test the whole game
	global.play_first_sound = true
	global.current_level = 3 # delete this line when compile the game
#	Test only
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


func _on_Player_bonus(bonus):
	global.give_points(bonus)


func _on_Floor_body_entered(body):
	if body.name == PLAYER_NAME:
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


func _on_Player_lose():
	lose()


func _on_GameOverSound_finished():
	GameOverSound_finished()


func _on_WinSound_finished():
	WinSound_finished()


func _on_GoalSensor_body_entered(body):
	if body.name == PLAYER_NAME:
		last_jump = true


func _on_Player_jumped(motion):
	if last_jump:
		track_horse_position = false
		$Horse.move_alone = true


func _on_Podium_player_detected():
	$Player.hit_and_fall()


func _on_PlayerPodiumRule_body_entered(body):
	if body.name == PLAYER_NAME:
		$Podium/CollisionShape2D.queue_free()
		$Podium/PodiumTop/CollisionShape2D.queue_free()






