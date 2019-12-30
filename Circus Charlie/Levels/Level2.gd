extends Node2D

export (PackedScene) var Monkey

const MONKEY_PADDING_SIZE = 32
const MONKEY_TOP = 230
const CYAN_MONKEY_INDEX = 9
const SPAWN_MONKEY_INTERVAL = 1
const MONKEY_NORMAL_SPEED = 1
const MONKEY_HIGH_SPEED = 2
const PLAYER_NAME = "Player"
const PLAYER_MINIMAL_DISTANCE = 300
const BONUS_PER_WON_TIME = 10

var hud : GameHUD = null
var monkey_index = -1
var monkey_pattern = [6, 9, 8, 9, 7, 10, 10, 5, 6, 9, 8, 10, 5, 4, 8]
var show_cyan_monkey = false
var last_monkey_name = ""
onready var monkey_timer = Timer.new()
onready var bonus_timer = Timer.new()

func _ready():
	randomize()
	add_HUD()
	$Sounds/LevelSound.volume_db = global.STANDARD_VOLUME
	set_timer_env()
	show_cyan_monkey = global.stage_2_first_time_lauched
	set_bonus_timer()
	
#	Test only = delete when test the whole game
	show_cyan_monkey = true
#	Test only

	if global.stage_2_current_monkey_index >= 0:
		monkey_index = global.stage_2_current_monkey_index - 1
	spawn_monkey()


func add_HUD():
	hud = global.get_hud()
#	if hud.connect("little_time_left", self, "_on_HUD_little_time_left") != OK:
#		print("Error connecting little_time_left")
#	if hud.connect("out_of_time", self, "_on_HUD_out_of_time") != OK:
#		print("Error connecting out_of_time")
	if hud.connect("bonus_giving_finished", self, "_on_bonus_giving_finished") != OK:
		print("Error connecting bonus_giving_finished")
	add_child(hud)


func set_bonus_timer():
	bonus_timer.connect("timeout", self, "_on_bonus_timer_timeout", 
		[], CONNECT_DEFERRED)
	bonus_timer.wait_time = 0.02
	add_child(bonus_timer)


func spawn_monkey():
	var monkey: Area2D = Monkey.instance()
	var monkey_position = 0
	
	monkey.name = "Enemy" + str(randi())
	monkey.connect("body_entered", self, "_on_monkey_body_entered", [], CONNECT_DEFERRED)
	monkey.connect("screen_exited", self, "_on_monkey_screen_exited",
			[], CONNECT_DEFERRED)
	
	if $MonkeyContainer.get_child_count() == 0:
		monkey_position = $MonkeyFirtPosition.position.x
	else:
		get_monkey_index()
		monkey_position = $MonkeyContainer.get_child(
				$MonkeyContainer.get_child_count() - 1).position.x
		
		monkey_position += monkey_pattern[monkey_index] * MONKEY_PADDING_SIZE
		if monkey_index == CYAN_MONKEY_INDEX and show_cyan_monkey:
			monkey.enable_player_sensor()

	monkey.position = Vector2(monkey_position, MONKEY_TOP)
	monkey.move = true
	$MonkeyContainer.add_child(monkey)
	last_monkey_name = monkey.name


func get_monkey_index():
	monkey_index += 1
	if monkey_index > monkey_pattern.size() - 1:
		show_cyan_monkey = global.rand_bool()
		monkey_index = 0


func set_monkey_speed(new_speed):
	for monkey in $MonkeyContainer.get_children():
		if monkey != null:
			monkey.playback_speed = new_speed


#func _on_bonus_timer_timeout():
#	$HUD.add_time_to_score(BONUS_PER_WON_TIME)
#	if $HUD.time_left <= 0:
#		bonus_timer.stop()
#		$Sounds/ReduceTimeSound.stop()
#		global.transition_to_next_level()


func _on_bonus_giving_finished():
	if not $Sounds/WinSound.playing:
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()


func set_timer_env():
	monkey_timer.wait_time = SPAWN_MONKEY_INTERVAL
	monkey_timer.connect("timeout", self, "_on_monkey_timer_timeout",
		[], CONNECT_DEFERRED)
	monkey_timer.start()
	add_child(monkey_timer)


func _on_Player_moved():
	set_monkey_speed(MONKEY_HIGH_SPEED)


func _on_Player_stopped():
	set_monkey_speed(MONKEY_NORMAL_SPEED)


func _on_Player_win():
#	$HUD.stop_time()
	hud.stop_time()


func _on_monkey_body_entered(body):
	if body.name == PLAYER_NAME:
		global.stage_2_current_monkey_index = monkey_index
#		$Player.hurt()
		$Player.hit_and_fall()
		$Sounds/LevelSound.stop()
		monkey_timer.stop()
		hud.stop_time()
		for monkey in $MonkeyContainer.get_children():
			if monkey != null:
				monkey.move = false
				monkey.get_node("StaticBody2D").get_node("CollisionShape2D").disabled = true
				monkey.get_node("AnimatedSprite").stop()
				monkey.monitoring = false
				monkey.set_process(false)

#		var HurtSound = $Player.get_node("Sounds").get_node("HurtSound")
#		var FallingDownSound = $Player.get_node("Sounds").get_node("FallingDownSound")
#
#		HurtSound.play()
#		yield(HurtSound, "finished")
#		yield(get_tree().create_timer(0.5), "timeout")

		$Floor/CollisionShape2D.disabled = true
		$UnderFloor/CollisionShape2D.disabled = false
#
#		$Player.set_physics_process(true)
#		FallSound.play()
#		yield(FallingDownSound, "finished")


func _on_HurtFloor_body_entered(body):
	if body.name == "Player":
		body.hurt()


func _on_monkey_timer_timeout():
	spawn_monkey()


func _on_monkey_screen_exited(_monkey: Area2D):
	if _monkey != null:
		if _monkey.position.x < $Player.position.x:
			_monkey.queue_free()


#func _on_Player_hurt_proceed():
func _on_Player_lose():
	yield(get_tree().create_timer(0.4), "timeout")
	global.lives -= 1
	if global.lives <= 0:
		global.game_over()
	get_tree().change_scene("res://Levels/ScenePreviewer.tscn")
	return
	$Floor/CollisionShape2D.disabled = true
	for monkey in $MonkeyContainer.get_children():
		if monkey != null:
			monkey.get_node("StaticBody2D").get_node("CollisionShape2D").disabled = true
	$UnderFloor/CollisionShape2D.disabled = false


func _on_GoalSensor_body_entered(body):
	if body.name == PLAYER_NAME:
		monkey_timer.stop()
		for monkey in $MonkeyContainer.get_children():
			var offset = monkey.position.x - $Player.position.x
			print(offset)
			if offset > PLAYER_MINIMAL_DISTANCE:
				monkey.call_deferred("queue_free")
