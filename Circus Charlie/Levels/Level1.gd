extends Node2D

export (PackedScene) var single_flame
export (PackedScene) var boiler

onready var sentinel = preload("res://Items/Sentinel/Sentinel.tscn")
var pos = Vector2(0, 0)
var hud : GameHUD = null


func _ready():
	randomize()
	set_sfx_volume()
	set_player_position()
	global.can_pause = true
	hud = global.get_hud()
	if hud.connect("little_time_left", self, "_on_HUD_little_time_left") != OK:
		print("Error connecting little_time_left")
	if hud.connect("out_of_time", self, "_on_HUD_out_of_time") != OK:
		print("Error connecting out_of_time")
	if hud.connect("bonus_giving_finished", self, "_on_bonus_giving_finished") != OK:
		print("Error connecting bonus_giving_finished")
	add_child(hud)
	spawn_boiler()
	spawn_sentinel()


func set_sfx_volume():
	for audio in $Sounds.get_children():
		audio.volume_db = global.STANDARD_VOLUME


func set_player_position():
	var checkpoint_pos = 0
	match global.check_point:
		2:
			checkpoint_pos = $CheckPoints/chkpt_90m.position.x
		3:
			checkpoint_pos = $CheckPoints/chkpt_80m.position.x
		4:
			checkpoint_pos = $CheckPoints/chkpt_70m.position.x
		5:
			checkpoint_pos = $CheckPoints/chkpt_60m.position.x
		6:
			checkpoint_pos = $CheckPoints/chkpt_50m.position.x
		7:
			checkpoint_pos = $CheckPoints/chkpt_40m.position.x
		8:
			checkpoint_pos = $CheckPoints/chkpt_30m.position.x
		9, 10:
			checkpoint_pos = $CheckPoints/chkpt_20m.position.x
		_:
			checkpoint_pos = $Lion.position.x
	$Lion.position.x = checkpoint_pos


func spawn_flame(how_many):
	for i in range(how_many):
		
		var flame = single_flame.instance()
		var rand = randi() % 4
		var rand_bonus = randi() % 20
		
		if pos.x == 0:
			pos = Vector2($Lion.position.x + 380, 184)
		else:
			pos = Vector2(pos.x + (380 if (rand / 2) * 2 == 0 else 300), 184)
		
		flame.position = pos
		if (rand_bonus / 2) * 2 == 0:
			flame.start("bonus")
		else:
			flame.start("big")
		
		flame.connect("hurt", $Lion, "hurt")
		$FlameContainer.call_deferred("add_child", flame)


func spawn_boiler():
	for i in range(10):
		var b = boiler.instance()
		b.position = Vector2(545 + (500 * i), 379)
		b.connect("hurt", $Lion, "hurt")
		$BoilerContainer.add_child(b)


func spawn_sentinel():
	for i in range(9):
		var s = sentinel.instance()
		s.position = Vector2(100 + (250 * i), 340)		
		s.connect("entered", self, "_on_sentinel_entered")
		$SentinelsContainer.add_child(s)


func stop_items():
	for boiler in $BoilerContainer.get_children():
		boiler.stop()


	for flame in $FlameContainer.get_children():
		flame.stop()
		flame.set_process(false)


func _on_sentinel_entered():
	spawn_flame(5)


func _on_HUD_little_time_left():
	$Sounds/LevelSound.pitch_scale = 1.075


#################################################
# Losing methods
func _on_HUD_out_of_time():
	$Lion.lose()


func _on_Lion_lose():
	lose()


func lose():
	hud.stop_time()
	stop_items()
	$Sounds/LevelSound.stop()
	global.lose_life()
	yield(get_tree().create_timer(0.66), "timeout")
	$Sounds/GameOverSound.play()


func _on_GameOverSound_finished():
	get_tree().call_deferred("change_scene","res://Levels/ScenePreviewer.tscn")


#################################################
# Winning methods
func _on_Lion_win():
	for flame in $FlameContainer.get_children():
		flame.queue_free()
	hud.give_bonus_start()
	$Items/Podium.player_center($Lion)
	$Sounds/LevelSound.stop()
	$Sounds/WinSound.play()


func _on_bonus_giving_finished():
	if not $Sounds/WinSound.playing:
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()


func _on_WinSound_finished():
	if not hud.is_giving_bonus():
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()
	else:
		hud.bonus_giving_play()
