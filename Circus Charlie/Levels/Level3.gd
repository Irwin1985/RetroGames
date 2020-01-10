extends "res://Levels/level_base.gd"

export (PackedScene) var Ball

const BALL_PADDING_SIZE = 32
const BALL_TOP = 383
const SPAWN_BALL_INTERVAL = 1
const PLAYER_MINIMAL_DISTANCE = 500

var ball_index = -1
var ball_pattern = [7, 4, 6, 3, 5, 6, 5, 4, 7, 3, 6, 5, 7, 3, 6]
var last_ball_name = ""
var play_ball_hurt := false

onready var ball_timer = Timer.new()

var track_player_pos := false
var PlayerBall: Area2D = null
var AnimSprite :AnimatedSprite = null


func _ready():
	set_timer_env()
	setBallInstance($PlayerBall)
#	Test only = delete when test the whole game
	global.play_first_sound = true
	global.current_level = 2 # delete this line when compile the game
#	Test only
	if global.current_check_point_path != "":
		var CheckPointNode: Position2D = get_node(global.current_check_point_path)
		if CheckPointNode != null:
			$PlayerBall.position.x = CheckPointNode.position.x
			$Player.position.x = CheckPointNode.position.x

	if global.stage_3_current_ball_index >= 0:
		ball_index = global.stage_3_current_ball_index - 1
	spawn_ball()

func _process(delta):
	if track_player_pos and PlayerBall != null:
		PlayerBall.position.x = $Player.global_position.x


func spawn_ball():
	var BallInstance: Area2D = Ball.instance()
	var ball_position = 0
	
	BallInstance.name = "Enemy" + str(randi())
	BallInstance.connect("screen_exited", self, "_on_BallInstance_screen_exited",[], CONNECT_DEFERRED)
	BallInstance.connect("player_detected", self, "_on_BallInstance_player_detected",[], CONNECT_DEFERRED)
	BallInstance.connect("bonus", self, "_on_BallInstance_bonus", [], CONNECT_DEFERRED)
	
	if $BallContainer.get_child_count() == 0:
		ball_position = $Player.position.x + 360
	else:
		get_ball_index()
		ball_position = $BallContainer.get_child(
				$BallContainer.get_child_count() - 1).position.x
		
		ball_position += ball_pattern[ball_index] * BALL_PADDING_SIZE

	BallInstance.position = Vector2(ball_position, BALL_TOP)
	BallInstance.can_move_itself = true
	$BallContainer.add_child(BallInstance)
	last_ball_name = BallInstance.name


func get_ball_index():
	ball_index += 1
	if ball_index > ball_pattern.size() - 1:
		ball_index = 0


func _on_Player_moved(motion):
	if track_player_pos and PlayerBall != null:
		AnimSprite.play("default", false if motion < 0 else true)
		AnimSprite.speed_scale = 2
		


func _on_Player_stopped():
	if track_player_pos and PlayerBall != null:
		PlayerBall.get_node("AnimatedSprite").stop()


func _on_Player_jumped(motion):
	track_player_pos = motion == 0
	if !track_player_pos and PlayerBall != null:
		PlayerBall.orientation = -1 if motion > 0 else 1
		PlayerBall.can_move_itself = false
		AnimSprite.speed_scale = 3
		PlayerBall.speed = 160

func _on_Floor_body_entered(body):
	if body.name == PLAYER_NAME:
		game_over()
		if play_ball_hurt:
			$Sounds/HurtSound.play()
		else:
			$Player/Sounds/HurtSound.play()


func game_over():
	global.stage_3_current_ball_index = ball_index
	$Player.hurt()
	$Sounds/LevelSound.stop()
	ball_timer.stop()
	hud.stop_time()

func set_timer_env():
	# Ball Timer Settings
	ball_timer.wait_time = SPAWN_BALL_INTERVAL
	ball_timer.connect("timeout", self, "_on_ball_timer_timeout",
		[], CONNECT_DEFERRED)
	ball_timer.start()
	add_child(ball_timer)

func _on_Player_win():
	player_won()
	$Podium.player_center($Player)

func _on_ball_timer_timeout():
	spawn_ball()

func _on_BallInstance_screen_exited(_ball: Area2D):
	if _ball != null:
		if _ball.position.x < $Player.position.x:
			_ball.queue_free()


func _on_Player_lose():
	lose()


func _on_GoalSensor_body_entered(body):
	if body.name == PLAYER_NAME:
		ball_timer.stop()
		for ball in $BallContainer.get_children():
			var offset = ball.position.x - $Player.position.x
			if offset > PLAYER_MINIMAL_DISTANCE:
				ball.call_deferred("queue_free")


func _on_GameOverSound_finished():
	GameOverSound_finished()


func _on_WinSound_finished():
	WinSound_finished()


func _on_BallInstance_player_detected(BallInstanceRef : Area2D):
	setBallInstance(BallInstanceRef)


func setBallInstance(BallRef : Area2D, track_player : bool = true):
	track_player_pos = track_player
	PlayerBall = BallRef
	AnimSprite = PlayerBall.get_node("AnimatedSprite")
	PlayerBall.connect("area_entered", self, "_on_BallInstance_area_entered", [], CONNECT_DEFERRED)
	PlayerBall.get_node("RayCast2D").enabled = false


func _on_BallInstance_bonus():
	$Player.bonus_earned = true


func _on_BallInstance_hurt():
	Player_hurt()


func _on_BallInstance_area_entered(area):
	if area.is_in_group("ball") and track_player_pos and PlayerBall != null:
		if $Player.motion.x == 0: # Player's ball was hitted
			AnimSprite.speed_scale = 3
			PlayerBall.can_move_itself = true
			PlayerBall.orientation = -1
			PlayerBall.speed = 160
			area.can_move_itself = false
		else: # Player's ball hits
			AnimSprite.speed_scale = 3
			PlayerBall.can_move_itself = true
			PlayerBall.orientation = -1
			PlayerBall.speed = 160
			# Area Settings
			area.get_node("AnimatedSprite").speed_scale = 3
			area.speed = 160
			area.orientation = 1
		Player_hurt()

func Player_hurt():
	play_ball_hurt = true
	$Player/Sounds/HurtSound.play()
	$Player.hit_and_fall()
	track_player_pos = false





