extends "res://Levels/level_base.gd"

export (PackedScene) var Ball

const BALL_PADDING_SIZE = 32
const BALL_TOP = 383
const SPAWN_BALL_INTERVAL = 1
const PLAYER_MINIMAL_DISTANCE = 500

var ball_index = -1
var ball_pattern = [6, 9, 8, 9, 7, 10, 10, 5, 6, 9, 8, 10, 5, 4, 8]
var last_ball_name = ""

onready var ball_timer = Timer.new()

var track_player_pos := false
var BallInstance: Area2D = null
var AnimSprite :AnimatedSprite = null


func _ready():
	set_timer_env()
#	Test only = delete when test the whole game
	global.play_first_sound = true
	global.current_level = 2 # delete this line when compile the game
#	Test only

	if global.current_check_point_path != "":
		var CheckPointNode: Position2D = get_node(global.current_check_point_path)
		if CheckPointNode != null:
			$Player.position = CheckPointNode.position

	if global.stage_3_current_ball_index >= 0:
		ball_index = global.stage_3_current_ball_index - 1
	spawn_ball()

func _process(delta):
	if track_player_pos:
		BallInstance.position.x = $Player.global_position.x


func spawn_ball():
	var BallInstance: Area2D = Ball.instance()
	var ball_position = 0
	
	BallInstance.name = "Enemy" + str(randi())
	BallInstance.connect("body_entered", self, "_on_ball_body_entered", 
			[], CONNECT_DEFERRED)
	BallInstance.connect("screen_exited", self, "_on_ball_screen_exited",
			[], CONNECT_DEFERRED)

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


func _on_Ball_player_detected(BallInstanceRef : Area2D):
	track_player_pos = true
	BallInstance = BallInstanceRef
	AnimSprite = BallInstance.get_node("AnimatedSprite")


func _on_Player_moved(motion):
	if track_player_pos and BallInstance != null:
		AnimSprite.play("default", true if motion < 0 else false)
		AnimSprite.speed_scale = 2
		


func _on_Player_stopped():
	if track_player_pos and BallInstance != null:
		BallInstance.get_node("AnimatedSprite").stop()


func _on_Player_jumped(motion):
	track_player_pos = false


func _on_Floor_body_entered(body):
	if body.name == PLAYER_NAME:
		game_over()


func game_over():
	global.stage_3_current_ball_index = ball_index
	$Player.hit_and_fall()
	$Sounds/LevelSound.stop()
	ball_timer.stop()
	hud.stop_time()
	for ball in $BallContainer.get_children():
		if ball != null:
			ball.can_move_itself = false
			ball.get_node("AnimatedSprite").stop()
			ball.monitoring = false
			ball.set_process(false)

func set_timer_env():
	# Ball Timer Settings
	ball_timer.wait_time = SPAWN_BALL_INTERVAL
	ball_timer.connect("timeout", self, "_on_ball_timer_timeout",
		[], CONNECT_DEFERRED)
	ball_timer.start()
	add_child(ball_timer)

func _on_Player_win():
	player_won()
#	platform_center_timer.start()

func _on_ball_timer_timeout():
	spawn_ball()

func _on_ball_screen_exited(_ball: Area2D):
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

func _on_CheckPoint70_body_entered(body):
	if body.name == PLAYER_NAME:
		global.current_check_point_path = "CheckPoints/chkpt_90m"

func _on_CheckPoint60_body_entered(body):
	if body.name == PLAYER_NAME:
		global.current_check_point_path = "CheckPoints/chkpt_80m"


func _on_CheckPoint50_body_entered(body):
	if body.name == PLAYER_NAME:
		global.current_check_point_path = "CheckPoints/chkpt_70m"


func _on_CheckPoint40_body_entered(body):
	if body.name == PLAYER_NAME:
		global.current_check_point_path = "CheckPoints/chkpt_60m"


func _on_CheckPoint30_body_entered(body):
	if body.name == PLAYER_NAME:
		global.current_check_point_path = "CheckPoints/chkpt_50m"


func _on_CheckPoint20_body_entered(body):
	if body.name == PLAYER_NAME:
		global.current_check_point_path = "CheckPoints/chkpt_40m"











