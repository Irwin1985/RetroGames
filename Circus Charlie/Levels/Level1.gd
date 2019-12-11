extends Node2D
export (PackedScene) var single_flame
export (PackedScene) var boiler
onready var sentinel = preload("res://items/Sentinel.tscn")
onready var bonus_timer = Timer.new()
var pos = Vector2(0, 0)

func _ready():
	randomize()
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

func _on_bonus_timer_timeout():
	$HUD.add_time_to_score(10)
	if $HUD.time_left <= 0:
		bonus_timer.stop()
	
func _stop_items():
	# boiler
	for boiler in $BoilerContainer.get_children():
		boiler.stop()
	# Flame
	for flame in $FlameContainer.get_children():
		flame.stop()
		flame.set_process(false)
	
# Flame Section
func _on_flame_hurt():
	hurt()

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
		$FlameContainer.add_child(flame)

func _on_flame_bonus(score):
	$HUD.update_score(score)
	
func _on_flame_score(score):
	$HUD.update_score(score)
# End Flame

# Boiler Section
func spawn_boiler():
	for i in range(10):
		var rand_boiler = randi() % 10
		var b = boiler.instance()
		var bonus_total = 0
		b.position = Vector2(545 + (500 * i), 379)
		b.connect("hurt", self, "_on_boiler_hurt")
		b.connect("score", self, "_on_boiler_score")
		b.connect("pickup", self, "_on_boiler_pickup")
		if (rand_boiler / 2) * 2 == 0:
			bonus_total = int(rand_range(2, 6))
			b.put_bonus(bonus_total)
		$BoilerContainer.add_child(b)

func _on_boiler_hurt():
	hurt()

func _on_boiler_score(score):
	$HUD.update_score(score)

func _on_boiler_pickup(score):
	$HUD.update_score(score)
# End Boiler

func hurt():
	_stop_items()
	$HUD.stop_time()
	$Lion.hurt()
	$Sounds/LevelSound.stop()
	$Sounds/HurtSound.play()
	global.lives -= 1
	if global.lives <= 0:
		global.game_over = true

func _on_HurtSound_finished():
	yield(get_tree().create_timer(0.5), "timeout")
	$Sounds/GameOverSound.play()

func _on_GameOverSound_finished():
	get_tree().change_scene("res://ScenePreviewer.tscn")

func spawn_sentinel():
	for i in range(9):
		var s = sentinel.instance()
		s.position = Vector2(100 + (250 * i), 340)		
		s.connect("entered", self, "_on_sentinel_entered")
		$SentinelsContainer.add_child(s)

func _on_sentinel_entered():
	spawn_flame(5)

# Lion Code Section
func _on_Lion_win():
	for flame in $FlameContainer.get_children():
		flame.queue_free()
	$HUD.stop_time()
	bonus_timer.start()
	$Sounds/LevelSound.stop()
	$Sounds/WinSound.play()

func set_player_position():
	match global.check_point:
		2:
			$Lion.position.x = $Position2D90.position.x
		3:
			$Lion.position.x = $Position2D80.position.x
		4:
			$Lion.position.x = $Position2D70.position.x
		5:
			$Lion.position.x = $Position2D60.position.x
		6:
			$Lion.position.x = $Position2D50.position.x
		7:
			$Lion.position.x = $Position2D40.position.x
		8:
			$Lion.position.x = $Position2D30.position.x
		9:
			$Lion.position.x = $Position2D20.position.x
		10:
			$Lion.position = $Position2D10.position