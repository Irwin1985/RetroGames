extends "res://Levels/level_base.gd"

export (PackedScene) var Monkey

const MONKEY_PADDING_SIZE = 28.4
const MONKEY_TOP = 216
const CYAN_MONKEY_INDEX = 9
const CYAN_MONKEY_BONUS_POINTS = 500
const SPAWN_MONKEY_INTERVAL = 1
const MONKEY_NORMAL_SPEED = 1
const MONKEY_HIGH_SPEED = 2
const PLAYER_MINIMAL_DISTANCE = 500

var monkey_index = -1
var monkey_pattern = [6.2, 10.2, 8.5, 10.1, 7.4, 11.8, 10.7, 5, 6.2, 10.2, 10.1, 10.7, 5, 4, 8.5]
var show_cyan_monkey = false
var last_monkey_name = ""

onready var monkey_timer = Timer.new()
onready var platform_center_timer = Timer.new()
onready var BlueMonkey: PackedScene = preload("res://Monkey/BlueMonkey.tscn")
var bonus_earned := false
var bonus_point := 0

func _ready():
	$Player/CollisionShape2D.shape.extents = Vector2(15, 9)
	set_timer_env()
	show_cyan_monkey = global.stage_2_first_time_lauched
	
	if global.is_debug_mode:
		global.play_first_sound = true
		global.current_level = 1

	if global.current_check_point_path != "":
		var CheckPointNode: Position2D = get_node(global.current_check_point_path)
		if CheckPointNode != null:
			$Player.position = CheckPointNode.position

	if global.stage_2_current_monkey_index >= 0:
		monkey_index = global.stage_2_current_monkey_index - 1
	spawn_monkey()


func _process(delta):
	if bonus_earned and $Player.is_on_floor():
		bonus_earned = false
		var player_pos : Vector2 = $Player.get_global_transform_with_canvas().get_origin()
		player_pos.y -= 40
		player_pos.x += 35
		hud.show_bonus_points(player_pos, bonus_point)
		bonus_point = 0


func spawn_monkey():
	var MonkeyInstance: Area2D = Monkey.instance()
	var monkey_position = 0
	
	MonkeyInstance.name = "Enemy" + str(randi())
	MonkeyInstance.connect("body_entered", self, "_on_monkey_body_entered", [], CONNECT_DEFERRED)
	MonkeyInstance.connect("screen_exited", self, "_on_monkey_screen_exited", [], CONNECT_DEFERRED)
	MonkeyInstance.connect("cyan_monkey_showed", self, "_on_MonkeyInstance_monkey_showed")
	MonkeyInstance.connect("bonus_earned", self, "_on_MonkeyInstance_bonus_earned")

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


func _on_platform_center_timeout()->void:
	var xdelta : int = ($HighPlatform.get_position() - $Player.get_position() ).x
	if abs(xdelta) > 1:
		var direction : Vector2 = Vector2(xdelta, 0).normalized()
		$Player.set_position($Player.get_position() + direction)
	else:
		platform_center_timer.stop()


func _on_Player_moved(motion = 0):
	set_monkey_speed(MONKEY_HIGH_SPEED)


func _on_Player_stopped():
	set_monkey_speed(MONKEY_NORMAL_SPEED)


func _on_Player_win():
	for monkey in $MonkeyContainer.get_children():
		monkey.call_deferred("queue_free")
	player_won()
	$Player.position.y = 164
	platform_center_timer.start()


func _on_monkey_body_entered(body):
	if body.name == global.PLAYER_NAME:
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
	BlueMonkeyInstance.global_position.x = $Player.global_position.x + 430
	BlueMonkeyInstance.position.y = MONKEY_TOP
	add_child(BlueMonkeyInstance)


func _on_monkey_timer_timeout():
	spawn_monkey()


func _on_monkey_screen_exited(_monkey: Area2D):
	if _monkey != null:
		if _monkey.position.x < $Player.position.x:
			_monkey.call_deferred("queue_free")


func _on_MonkeyInstance_bonus_earned(bonus):
	global.give_points(bonus)


func _on_HurtFloor_body_entered(body):
	if body.name == global.PLAYER_NAME:
		body.hurt()


func _on_Player_lose():
	lose()


func _on_GoalSensor_body_entered(body):
	if body.name == global.PLAYER_NAME:
		monkey_timer.stop()
		for monkey in $MonkeyContainer.get_children():
			var offset = monkey.position.x - $Player.position.x
			if offset > PLAYER_MINIMAL_DISTANCE:
				monkey.call_deferred("queue_free")


func _on_GameOverSound_finished():
	GameOverSound_finished()


func _on_WinSound_finished():
	WinSound_finished($Player)


func _on_BlueMonkey_player_bonus():
	bonus_earned = true
	bonus_point = CYAN_MONKEY_BONUS_POINTS


func _on_PlatformSensor_body_entered(body):
	if body.name == global.PLAYER_NAME:
		$HighPlatform/PlatformTable/CollisionShape2D.disabled = false
		$HighPlatform/PlatformTop/CollisionShape2D2.disabled = false
