extends Node2D

onready var picked_bonuses : int = 0

func _ready():
	randomize()
	set_player_position()
	var trampolines : PackedScene = preload("res://Items/BigTrampoline/bigtrampoline.tscn")
	var jugglers : PackedScene = preload("res://Items/Juggler/Juggler.tscn")
	var fire_eaters : PackedScene = preload("res://Items/FireEater/FireEater.tscn")
	var next_bonus : int = 4
	for i in range (21):
		var new_trampoline = trampolines.instance()
# warning-ignore:integer_division
		new_trampoline.position = Vector2(i * 512 / 3 + 100, 370)
		$Environment.add_child(new_trampoline)
		if i == next_bonus:
			new_trampoline.put_bonus()
			next_bonus += randi() % 3 + 2
			if next_bonus > 20 and i < 19:
				next_bonus = 20
			if new_trampoline.connect("bonus_pick", self, "_on_Bonus_pick") != OK:
				print("Error connecting bonus_pick of new trampoline")
		if i >= 3:
			var random : int = randi() % 5
			if random == 1 or random == 2:
				var new_fire_eater : Node2D = fire_eaters.instance()
# warning-ignore:integer_division
				new_fire_eater.position = Vector2(i * 512 / 3 + 185, 388)
				$Environment.add_child(new_fire_eater)
			elif random == 3 or random == 4:
				var new_juggler : Node2D = jugglers.instance()
# warning-ignore:integer_division
				new_juggler.position = Vector2(i * 512 / 3 + 185, 388)
				$Environment.add_child(new_juggler) 

func set_player_position():
	$Player.jumping = true
	
func _on_Bonus_pick():
	picked_bonuses += 1
	global.give_points(400 + picked_bonuses * 100)

func _on_Bounds_body_entered(body : PhysicsBody2D):
	if body.name == "Player":
		body.hurt()

#################################################
func _on_Player_hit():
	$Sounds/LevelSound.stop()
	for item in $Environment.get_children():
		item.stop()
	
# Losing methods
#func _on_HUD_out_of_time():
#	lose()

func _on_Player_lose():
	lose()

func lose():
#	stop_items()
#	$HUD.stop_time()
	$Sounds/LevelSound.stop()
	global.lose_life()
	yield(get_tree().create_timer(0.66), "timeout")
	$Sounds/GameOverSound.play()

func _on_GameOverSound_finished():
	get_tree().call_deferred("change_scene","res://Levels/ScenePreviewer.tscn")

#################################################
# Winning methods

func _on_Player_win():
#	for item in $EnvironmentObjects.get_children():
#		item.call_deferred("queue_free")
#	var podium_level : Vector2 = $Items/Podium.position + Vector2.UP * 38
#	podium_level.x = $Player.get_position().x
#	$Player.set_position(podium_level)
#	$HUD.stop_time()
#	platform_center_timer.start()
#	audience_timer.start()
#	bonus_timer.start()
	$Sounds/LevelSound.stop()
	$Sounds/WinSound.play()


func _on_WinSound_finished():
#	audience_timer.stop()
#	$Background/Celebrating.visible = false
#	if bonus_timer.is_stopped():
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()
#	else:
#		$Sounds/ReduceTimeSound.play()
