extends Node

const PLAYER_NAME = "Player"
const BONUS_PER_WON_TIME = 10

var hud : GameHUD = null
onready var bonus_timer = Timer.new()
onready var audience_timer = Timer.new()


func _ready():
	randomize()
	add_HUD()
	global.can_pause = true
	$Sounds/LevelSound.volume_db = global.STANDARD_VOLUME
	set_timers()


func add_HUD():
	hud = global.get_hud()
	if hud.connect("little_time_left", self, "_on_HUD_little_time_left") != OK:
		print("Error connecting little_time_left")
	if hud.connect("out_of_time", self, "_on_HUD_out_of_time") != OK:
		print("Error connecting out_of_time")
	if hud.connect("bonus_giving_finished", self, "_on_bonus_giving_finished") != OK:
		print("Error connecting bonus_giving_finished")
	add_child(hud)


func set_timers():
	# Bonus Timer Settings
	bonus_timer.connect("timeout", self, "_on_bonus_timer_timeout", 
		[], CONNECT_DEFERRED)
	bonus_timer.wait_time = 0.02
	add_child(bonus_timer)

	# Audience Timer Settings
	audience_timer.connect("timeout", self, "_on_audience_timeout")	
	audience_timer.wait_time = 0.05
	add_child(audience_timer)


func _on_bonus_giving_finished():
	if not $Sounds/WinSound.playing:
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()


func player_won():
	hud.give_bonus_start()
	audience_timer.start()
	$Sounds/LevelSound.stop()
	$Sounds/WinSound.play()


func lose():
	hud.stop_time()
	$Sounds/LevelSound.stop()
	global.lose_life()
	yield(get_tree().create_timer(0.66), "timeout")
	$Sounds/GameOverSound.play()


func WinSound_finished():
	audience_timer.stop()
	if not hud.is_giving_bonus():
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()
	else:
		hud.bonus_giving_play()


func GameOverSound_finished():
	get_tree().call_deferred("change_scene","res://Levels/ScenePreviewer.tscn")


func _on_HUD_little_time_left():
	$Sounds/LevelSound.pitch_scale = global.pitch_scale
	$Sounds/LevelSound.stop()
	$Sounds/LevelSound.play()


func _on_HUD_out_of_time():
	if get_node("Player") != null:
		get_node("Player").lose()
