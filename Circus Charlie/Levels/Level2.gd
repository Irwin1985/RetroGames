extends "res://Levels/level_base.gd"

export (PackedScene) var Monkey

const MONKEY_PADDING_SIZE = 28.4
const MONKEY_TOP = 216
const CYAN_MONKEY_BONUS_POINTS = 500
const SPAWN_MONKEY_INTERVAL = 1
const MONKEY_NORMAL_SPEED = 1
const MONKEY_HIGH_SPEED = 2
const PLAYER_MINIMAL_DISTANCE = 500
#const MONKEY_LEFT_MARGIN = 430
const MONKEY_LEFT_MARGIN = 410
const MONKEY_FIRST_LEFT_MARGIN = 360
const ONE_MONKEY = 1
const TWO_MONKEYS = 2

onready var MonkeyIndexRules: MonkeyRules

var monkey_index = -1
var monkey_pattern: Array = []

var level_dif: Dictionary = \
{
  "level_1": [
	6.2,
	10.2,
	8.5,
	10.1,
	7.4,
	11.8,
	10.7,
	5,
	6.2,
	10.2,
	10.1,
	10.7,
	5,
	4,
	8.5],
  "level_2": [
	6,
	4.7,
	12,
	4.1,
	12,
	4.1,
	3.6,
	9.5,
	13.5,
	5,
	3.6,
	8.9,
	6.2,
	4.9,
	11.8],
  "level_3": [
	9.8,
	13.5,
	3.5,
	4.5,
	10.0,
	8.0,
	6.8,
	9.8,
	13.5,
	3.5,
	8.0,
	9.8,
	13.5,
	3.5,
	4.5],
  "level_4": [
	9.8,
	13.7,
	9.8,
	13.7,
	9.8,
	3.5,
	13.7,
	9.8,
	13.7,
	9.8,
	13.7,
	9.8,
	6.8,
	1.28,
	13.7]
}

var last_monkey_name = ""
onready var monkey_timer = Timer.new()
onready var platform_center_timer = Timer.new()
onready var BlueMonkey: PackedScene = preload("res://Monkey/BlueMonkey.tscn")

var bonus_earned := false
var bonus_point := 0


func _ready():
	MonkeyIndexRules = MonkeyRules.new()
	monkey_pattern = get_level_difficulty()
	$Player/CollisionShape2D.shape.extents = Vector2(15, 9)
	set_timer_env()

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
		monkey_position = $Player.position.x + MONKEY_FIRST_LEFT_MARGIN
	else:
		MonkeyInstance.total_cyan_monkey = get_monkey_index()
		monkey_position = $MonkeyContainer.get_child(
				$MonkeyContainer.get_child_count() - 1).position.x
		
		monkey_position += monkey_pattern[monkey_index] * MONKEY_PADDING_SIZE
		if MonkeyInstance.total_cyan_monkey > 0:
			MonkeyInstance.enable_player_sensor()

	MonkeyInstance.position = Vector2(monkey_position, MONKEY_TOP)
	MonkeyInstance.move = true
	$MonkeyContainer.add_child(MonkeyInstance)
	last_monkey_name = MonkeyInstance.name


func get_monkey_index() -> int:
	var total_cyan_monkey = 0
	monkey_index += 1
	if monkey_index > monkey_pattern.size() - 1:
		monkey_index = 0
	MonkeyIndexRules.current_monkey_index = monkey_index
	total_cyan_monkey = MonkeyIndexRules.update_cyan_monkey()
	return total_cyan_monkey


func set_monkey_speed(new_speed):
	for monkey in $MonkeyContainer.get_children():
		if monkey != null:
			monkey.playback_speed = new_speed


func set_timer_env():
	# Monkey Timer Settings
	monkey_timer.wait_time = SPAWN_MONKEY_INTERVAL
	monkey_timer.connect("timeout", self, "_on_monkey_timer_timeout",
		[], CONNECT_DEFERRED)
	add_child(monkey_timer)
	monkey_timer.start()

	# Platform Center Timer Settings
	platform_center_timer.connect("timeout", self, "_on_platform_center_timeout")	
	platform_center_timer.wait_time = 0.02
	add_child(platform_center_timer)


func _on_platform_center_timeout() -> void:
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


func _on_MonkeyInstance_monkey_showed(total_monkeys: int) -> void:
	var left_margin = MONKEY_LEFT_MARGIN
	match total_monkeys:
		ONE_MONKEY:
#			if global.level_difficulty == global.LEVEL_2:
#				left_margin = 400
			var FirstMonkey = create_cyan_monkey()
			FirstMonkey.global_position.x = $Player.global_position.x + MONKEY_LEFT_MARGIN
			if FirstMonkey.global_position.x < $Walls/RightWall.global_position.x:
				add_child(FirstMonkey)

		TWO_MONKEYS:
#			if global.level_difficulty == global.LEVEL_2:
#				left_margin = 400
#			elif global.level_difficulty == global.LEVEL_3:
#				left_margin = 400

			var monkey_margin = 1.28
			var FirstMonkey = create_cyan_monkey()
			FirstMonkey.global_position.x = $Player.global_position.x + MONKEY_LEFT_MARGIN
			if FirstMonkey.global_position.x < $Walls/RightWall.global_position.x:
				add_child(FirstMonkey)

			var SecondMonkey = create_cyan_monkey()
			SecondMonkey.global_position.x = FirstMonkey.global_position.x + monkey_margin * MONKEY_PADDING_SIZE
			if SecondMonkey.global_position.x < $Walls/RightWall.global_position.x:
				add_child(SecondMonkey)

	bonus_point = CYAN_MONKEY_BONUS_POINTS * total_monkeys


func create_cyan_monkey():
	var MonkeyScene = BlueMonkey.instance()
	MonkeyScene.connect("player_detected", self, "game_over", [], CONNECT_DEFERRED)
	MonkeyScene.connect("player_bonus", self, "_on_BlueMonkey_player_bonus", [], CONNECT_DEFERRED)
	MonkeyScene.position.y = MONKEY_TOP
	return MonkeyScene


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


func _on_PlatformSensor_body_entered(body):
	if body.name == global.PLAYER_NAME:
		$HighPlatform/PlatformTable/CollisionShape2D.disabled = false
		$HighPlatform/PlatformTop/CollisionShape2D2.disabled = false


func get_level_difficulty() -> Array:
	var level: Array
	match global.level_difficulty:
		global.LEVEL_1:
			level = level_dif["level_1"]
		global.LEVEL_2:
			level = level_dif["level_2"]
		global.LEVEL_3:
			level = level_dif["level_3"]
		global.LEVEL_4:
			level = level_dif["level_4"]
		_:
			level = level_dif["level_4"]
	return level
