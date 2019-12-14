extends Node2D

export (PackedScene) var single_flame
export (PackedScene) var boiler

onready var sentinel = preload("res://Items/Sentinel/Sentinel.tscn")
onready var bonus_timer = Timer.new()
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


func create_bonus_score_timer()->void:
	bonus_timer.connect("timeout", self, "_on_bonus_timer_timeout")	
	bonus_timer.wait_time = 0.02
	add_child(bonus_timer)


func stop_items():
	for boiler in $BoilerContainer.get_children():
		boiler.stop()

	for flame in $FlameContainer.get_children():
		flame.stop()
		flame.set_process(false)


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
		call_deferred("add_flame_deferred", flame)

func add_flame_deferred(flame)->void:
		$FlameContainer.add_child(flame)


func spawn_boiler():
	var rand_boiler = randi() % 10
	for i in range(10):
		var b = boiler.instance()
		var bonus_total = 0
		b.position = Vector2(545 + (500 * i), 379)
		b.connect("hurt", self, "_on_boiler_hurt")
		b.connect("score", self, "_on_boiler_score")
		b.connect("pickup", self, "_on_boiler_pickup")
		# Only one random boiler has a coin
		if rand_boiler == i:
			# Coin appears only after jumping backwards (pair number of jumps)
			bonus_total = int(rand_range(1, 3)) * 2
			b.put_bonus(bonus_total)
		$BoilerContainer.add_child(b)


func spawn_sentinel():
	for i in range(9):
		var s = sentinel.instance()
		s.position = Vector2(100 + (250 * i), 340)		
		s.connect("entered", self, "_on_sentinel_entered")
		$SentinelsContainer.add_child(s)


func hurt():
	stop_items()
	$HUD.stop_time()
	$Lion.hurt()
	$Sounds/LevelSound.stop()
	$Sounds/HurtSound.play()
	global.lives -= 1
	if global.lives <= 0:
		global.is_game_over = true


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


func _on_bonus_timer_timeout():
	$HUD.add_time_to_score(10)
	if $HUD.time_left <= 0:
		$Sounds/ReduceTimeSound.stop()
		bonus_timer.stop()
		global.transition_to_next_level()


func _on_sentinel_entered():
	spawn_flame(5)


func _on_flame_hurt():
	hurt()


func _on_flame_bonus(score):
	$HUD.update_score(score)


func _on_flame_score(score):
	$HUD.update_score(score)


func _on_boiler_hurt():
	hurt()


func _on_boiler_score(score):
	$HUD.update_score(score)

func _on_boiler_pickup(score):
	$HUD.update_score(score)


func _on_HurtSound_finished():
	yield(get_tree().create_timer(0.5), "timeout")
	$Sounds/GameOverSound.play()


func _on_GameOverSound_finished():
	get_tree().change_scene("res://Levels/ScenePreviewer.tscn")


func _on_Lion_win():
	for flame in $FlameContainer.get_children():
		flame.queue_free()
	$HUD.stop_time()	
	bonus_timer.start()
	$Sounds/LevelSound.stop()
	$Sounds/WinSound.play()	


func _on_WinSound_finished():
	$Sounds/ReduceTimeSound.play()
