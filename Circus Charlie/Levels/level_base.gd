extends Node

const PLAYER_NAME = "Player"
const LION_NAME =  "Lion"
const BONUS_PER_WON_TIME = 10

var hud : GameHUD = null
onready var audience_timer = Timer.new()


func _ready():
	randomize()
	add_HUD()
	global.can_pause = true
	$Sounds/LevelSound	.volume_db = global.STANDARD_VOLUME
	set_timers()


func add_HUD():
	hud = global.get_HudInstance()
	hud.connect("little_time_left", self, "_on_HUD_little_time_left")
	hud.connect("out_of_time", self, "_on_HUD_out_of_time")
	hud.connect("bonus_giving_finished", self, "start_next_level_on_condition")
	add_child(hud)


func set_timers():
	# Audience Timer Settings
	audience_timer.connect("timeout", self, "_on_audience_timeout",
			[], CONNECT_DEFERRED)
	audience_timer.wait_time = 0.05
	add_child(audience_timer)


func player_won():
	hud.give_bonus_start()
	$Background/Celebrating.visible = true
	audience_timer.start()
	$Sounds/LevelSound.stop()
	$Sounds/WinSound.play()


func lose():
	hud.stop_time()
	$Sounds/LevelSound.stop()
	global.lose_life()
	yield(get_tree().create_timer(0.66), "timeout")
	$Sounds/GameOverSound.play()


func WinSound_finished(player):
	if player != null:
		player.get_node("Charlie").stop()
		player.get_node("Charlie").frame = 0
	audience_timer.stop()
	$Background/Celebrating.visible = false
	
	if hud.time_left > 0:
		hud.bonus_giving_play()
	else:
		start_next_level_on_condition()


func start_next_level_on_condition():
	if not $Sounds/WinSound.playing:
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()


func GameOverSound_finished():
	get_tree().call_deferred("change_scene","res://Levels/ScenePreviewer.tscn")


func _on_HUD_little_time_left():
	$Sounds/LevelSound.pitch_scale = global.pitch_scale
	$Sounds/LevelSound.stop()
	$Sounds/LevelSound.play()


func _on_HUD_out_of_time():
	var found := false
	if get_node(PLAYER_NAME) != null:
		found = true
		get_node(PLAYER_NAME).lose()
	if not found and get_node(LION_NAME) != null:
		found = true
		get_node(LION_NAME).lose()

func _on_audience_timeout()->void:
	$Background/Celebrating.visible = not $Background/Celebrating.visible