extends Node2D

export (PackedScene) var Monkey

const MONKEY_PADDING_SIZE = 32
const MONKEY_TOP = 230
const CYAN_MONKEY_INDEX = 9
const SPAWN_MONKEY_INTERVAL = 1
const MONKEY_NORMAL_SPEED = 1
const MONKEY_HIGH_SPEED = 2
const PLAYER_NAME = "Player"
const PLAYER_MINIMAL_DISTANCE = 500
const BONUS_PER_WON_TIME = 10

var hud : GameHUD = null
var monkey_index = -1
var monkey_pattern = [6, 9, 8, 9, 7, 10, 10, 5, 6, 9, 8, 10, 5, 4, 8]
var show_cyan_monkey = false
var last_monkey_name = ""

onready var monkey_timer = Timer.new()
onready var bonus_timer = Timer.new()
onready var platform_center_timer = Timer.new()
onready var audience_timer = Timer.new()
onready var BlueMonkey: PackedScene = preload("res://Monkey/BlueMonkey.tscn")

func _ready():
	randomize()
	add_HUD()
	global.can_pause = true
	$Sounds/LevelSound.volume_db = global.STANDARD_VOLUME
	set_timer_env()
	show_cyan_monkey = global.stage_2_first_time_lauched
	set_bonus_timer()
	
#	Test only = delete when test the whole game
	show_cyan_monkey = true # delete this line when compile the game
	global.play_first_sound = true
	global.current_level = 1 # delete this line when compile the game
#	Test only

	if global.current_check_point_path != "":
		var CheckPointNode: Position2D = get_node(global.current_check_point_path)
		if CheckPointNode != null:
			$Player.position = CheckPointNode.position

	if global.stage_2_current_monkey_index >= 0:
		monkey_index = global.stage_2_current_monkey_index - 1
	spawn_monkey()


func add_HUD():
	hud = global.get_hud()
	if hud.connect("little_time_left", self, "_on_HUD_little_time_left") != OK:
		print("Error connecting little_time_left")
	if hud.connect("out_of_time", self, "_on_HUD_out_of_time") != OK:
		print("Error connecting out_of_time")
	if hud.connect("bonus_giving_finished", self, "_on_bonus_giving_finished") != OK:
		print("Error connecting bonus_giving_finished")
	add_child(hud)


func set_bonus_timer():
	bonus_timer.connect("timeout", self, "_on_bonus_timer_timeout", 
		[], CONNECT_DEFERRED)
	bonus_timer.wait_time = 0.02
	add_child(bonus_timer)


func spawn_monkey():
	var MonkeyInstance: Area2D = Monkey.instance()
	var monkey_position = 0
	
	MonkeyInstance.name = "Enemy" + str(randi())
	MonkeyInstance.connect("body_entered", self, "_on_monkey_body_entered", 
			[], CONNECT_DEFERRED)
	MonkeyInstance.connect("screen_exited", self, "_on_monkey_screen_exited",
			[], CONNECT_DEFERRED)
	MonkeyInstance.connect("cyan_monkey_showed", self, "_on_MonkeyInstance_monkey_showed")

	if $MonkeyContainer.get_child_count() == 0:
		monkey_position = $Player.position.x + 360
	else:
		get_monkey_index()
		monkey_position = $MonkeyContainer.get_child(
				$MonkeyContainer.get_child_count() - 1).position.x
		
		monkey_position += monkey_pattern[monkey_index] * MONKEY_PADDING_SIZE
		if monkey_index == CYAN_MONKEY_INDEX and show_cyan_monkey:
			MonkeyInstance.enable_player_sensor()

	MonkeyInstance.position = Vector2(monkey_position, MONKEY_TOP)
	MonkeyInstance.move = true
	$MonkeyContainer.add_child(MonkeyInstance)
	last_monkey_name = MonkeyInstance.name


func get_monkey_index():
	monkey_index += 1
	if monkey_index > monkey_pattern.size() - 1:
		show_cyan_monkey = global.rand_bool()
		monkey_index = 0


func set_monkey_speed(new_speed):
	for monkey in $MonkeyContainer.get_children():
		if monkey != null:
			monkey.playback_speed = new_speed


func _on_bonus_giving_finished():
	if not $Sounds/WinSound.playing:
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()


func set_timer_env():
	# Monkey Timer Settings
	monkey_timer.wait_time = SPAWN_MONKEY_INTERVAL
	monkey_timer.connect("timeout", self, "_on_monkey_timer_timeout",
		[], CONNECT_DEFERRED)
	monkey_timer.start()
	add_child(monkey_timer)

	# Platform Center Timer Settings
	platform_center_timer.connect("timeout", self, "_on_platform_center_timeout")	
	platform_center_timer.wait_time = 0.02
	add_child(platform_center_timer)

	# Audience Timer Settings
	audience_timer.connect("timeout", self, "_on_audience_timeout")	
	audience_timer.wait_time = 0.05
	add_child(audience_timer)


func _on_platform_center_timeout()->void:
	var xdelta : int = ($HighPlatform.get_position() - $Player.get_position() ).x
	if abs(xdelta) > 1:
		var direction : Vector2 = Vector2(xdelta, 0).normalized()
		$Player.set_position($Player.get_position() + direction)
	else:
		platform_center_timer.stop()


func _on_Player_moved():
	set_monkey_speed(MONKEY_HIGH_SPEED)


func _on_Player_stopped():
	set_monkey_speed(MONKEY_NORMAL_SPEED)


func _on_Player_win():
	hud.give_bonus_start()
	platform_center_timer.start()
	audience_timer.start()
	$Sounds/LevelSound.stop()
	$Sounds/WinSound.play()


func _on_monkey_body_entered(body):
	if body.name == PLAYER_NAME:
		game_over()


func game_over():
	global.stage_2_current_monkey_index = monkey_index
	$Player.hit_and_fall()
	$Sounds/LevelSound.stop()
	monkey_timer.stop()
	hud.stop_time()
	for monkey in $MonkeyContainer.get_children():
		if monkey != null:
			monkey.move = false
			monkey.get_node("AnimatedSprite").stop()
			monkey.monitoring = false
			monkey.set_process(false)
	$Floor/CollisionShape2D.disabled = true
	$UnderFloor/CollisionShape2D.disabled = false


func _on_MonkeyInstance_monkey_showed():
	var BlueMonkeyInstance = BlueMonkey.instance()
	BlueMonkeyInstance.connect("player_detected", self, "game_over", [], CONNECT_DEFERRED)
	BlueMonkeyInstance.connect("player_bonus", self, "_on_BlueMonkey_player_bonus", [], CONNECT_DEFERRED)
	BlueMonkeyInstance.position.x = $Player.position.x + 940
	BlueMonkeyInstance.position.y = $Player.position.y
	add_child(BlueMonkeyInstance)


func _on_monkey_timer_timeout():
	spawn_monkey()


func _on_monkey_screen_exited(_monkey: Area2D):
	if _monkey != null:
		if _monkey.position.x < $Player.position.x:
			_monkey.queue_free()


func _on_HurtFloor_body_entered(body):
	if body.name == "Player":
		body.hurt()


func _on_Player_lose():
	lose()


func lose():
	hud.stop_time()
	$Sounds/LevelSound.stop()
	global.lose_life()
	yield(get_tree().create_timer(0.66), "timeout")
	$Sounds/GameOverSound.play()


func _on_GoalSensor_body_entered(body):
	if body.name == PLAYER_NAME:
		monkey_timer.stop()
		for monkey in $MonkeyContainer.get_children():
			var offset = monkey.position.x - $Player.position.x
			if offset > PLAYER_MINIMAL_DISTANCE:
				monkey.call_deferred("queue_free")


func _on_GameOverSound_finished():
	get_tree().call_deferred("change_scene","res://Levels/ScenePreviewer.tscn")


func _on_WinSound_finished():
	audience_timer.stop()
	if not hud.is_giving_bonus():
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()
	else:
		hud.bonus_giving_play()


func _on_CheckPoint60_body_entered(body):
	if body.name == PLAYER_NAME:
		global.current_check_point_path = "CheckPoints/chkpt_90m"


func _on_CheckPoint50_body_entered(body):
	if body.name == PLAYER_NAME:
		global.current_check_point_path = "CheckPoints/chkpt_80m"


func _on_CheckPoint40_body_entered(body):
	if body.name == PLAYER_NAME:
		global.current_check_point_path = "CheckPoints/chkpt_70m"


func _on_CheckPoint30_body_entered(body):
	if body.name == PLAYER_NAME:
		global.current_check_point_path = "CheckPoints/chkpt_60m"


func _on_CheckPoint20_body_entered(body):
	if body.name == PLAYER_NAME:
		global.current_check_point_path = "CheckPoints/chkpt_50m"


func _on_HUD_little_time_left():
	$Sounds/LevelSound.pitch_scale = global.pitch_scale
	$Sounds/LevelSound.stop()
	$Sounds/LevelSound.play()


func _on_HUD_out_of_time():
	$Player.lose()


func _on_BlueMonkey_player_bonus():
	$Player.bonus_earned_for_jumping_cyan_monkey()







