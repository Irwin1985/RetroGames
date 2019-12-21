extends Node2D

export (PackedScene) var single_flame
export (PackedScene) var boiler

onready var sentinel = preload("res://Items/Sentinel/Sentinel.tscn")
onready var bonus_timer = Timer.new()
onready var podium_center_timer = Timer.new()
var pos = Vector2(0, 0)


func _ready():
	randomize()
	set_sfx_volume()
	set_player_position()
	global.can_pause = true
	$HUD.update_score(0)
	$HUD.update_hi_score()
	$HUD.begin_time()
	spawn_boiler()
	spawn_sentinel()
	create_bonus_score_timer()
	create_podium_center_timer()

func create_bonus_score_timer()->void:
	bonus_timer.connect("timeout", self, "_on_bonus_timer_timeout")	
	bonus_timer.wait_time = 0.02
	add_child(bonus_timer)
	
func create_podium_center_timer()->void:
	podium_center_timer.connect("timeout", self, "_on_podium_center_timeout")	
	podium_center_timer.wait_time = 0.02
	add_child(podium_center_timer)

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
		
		flame.connect("hurt", self, "_on_flame_hurt")
		flame.connect("bonus", self, "_on_flame_bonus")
		flame.connect("score", self, "_on_flame_score")
		$FlameContainer.call_deferred("add_child", flame)

func spawn_boiler():
	for i in range(10):
		var b = boiler.instance()
		b.position = Vector2(545 + (500 * i), 379)
		b.connect("hurt", self, "_on_boiler_hurt")
		b.connect("score", self, "_on_boiler_score")
		b.connect("pickup", self, "_on_boiler_pickup")
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

func _on_flame_bonus(score):
	$HUD.update_score(score)

func _on_flame_score(score):
	$HUD.update_score(score)

func _on_flame_hurt():
	hurt()

func _on_boiler_score(score):
	$HUD.update_score(score)

func _on_boiler_pickup(score):
	$HUD.update_score(score)

func _on_boiler_hurt():
	hurt()
	
func _on_HUD_little_time_left():
	$Sounds/LevelSound.pitch_scale = 1.075


#################################################
# Losing methods
func _on_HUD_out_of_time():
	lose()

func hurt():
	$HUD.stop_time()
	$Lion.hurt()
	lose()

func lose():
	stop_items()
	$Lion.stop()
	$Sounds/LevelSound.stop()
	$Sounds/HurtSound.play()
	global.lives -= 1
	if global.lives <= 0:
		global.is_game_over = true
		
func _on_HurtSound_finished():
	yield(get_tree().create_timer(0.5), "timeout")
	$Sounds/GameOverSound.play()

func _on_GameOverSound_finished():
	get_tree().change_scene("res://Levels/ScenePreviewer.tscn")


#################################################
# Winning methods
func _on_Lion_win():
	for flame in $FlameContainer.get_children():
		flame.queue_free()
	var podium_level : Vector2 = $Items/Podium.position + Vector2.UP * 38
	podium_level.x = $Lion.get_position().x
	$Lion.set_position(podium_level)
	$HUD.stop_time()
	podium_center_timer.start()
	bonus_timer.start()
	$Sounds/LevelSound.stop()
	$Sounds/WinSound.play()	

func _on_podium_center_timeout()->void:
	var xdelta : int = ($Items/Podium.get_position() - $Lion.get_position() ).x
	if abs(xdelta) > 1:
		var direction : Vector2 = Vector2(xdelta, 0).normalized()
		$Lion.set_position($Lion.get_position() + direction)
	else:
		podium_center_timer.stop()

func _on_bonus_timer_timeout():
	$HUD.add_time_to_score(10)
	if $HUD.time_left <= 0:
		$Sounds/ReduceTimeSound.stop()
		bonus_timer.stop()
		if not $Sounds/WinSound.playing:
			yield(get_tree().create_timer(0.5), "timeout")
			global.start_next_level()
			
func _on_WinSound_finished():
	if bonus_timer.is_stopped():
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()
	else:
		$Sounds/ReduceTimeSound.play()