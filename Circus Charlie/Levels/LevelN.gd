extends Node2D

onready var picked_bonuses : int = 0
var hud : GameHUD = null

func _ready():
	randomize()
	set_player_position()
	hud = global.get_hud()
	if hud.connect("little_time_left", self, "_on_HUD_little_time_left") != OK:
		print("Error connecting little_time_left")
	if hud.connect("out_of_time", self, "_on_HUD_out_of_time") != OK:
		print("Error connecting out_of_time")
	if hud.connect("bonus_giving_finished", self, "_on_bonus_giving_finished") != OK:
		print("Error connecting bonus_giving_finished")
	add_child(hud)
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
		if i % 3 == 0:
# warning-ignore:integer_division
			new_trampoline.put_checkpoint(i / 3)
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
	var checkpoint_pos : int = 0
	match global.check_point:
		0, 1, 2, 3, 4, 5:
			checkpoint_pos = 512 * global.check_point
		_: # After the last one go back to 20M (5th CP)
			checkpoint_pos = 512 * 5
	$Player.position.x += checkpoint_pos


func _on_Bonus_pick():
	picked_bonuses += 1
	var bonus_points : int = 400 + picked_bonuses * 100
	var player_pos : Vector2 = $Player.get_global_transform_with_canvas().get_origin()
	player_pos.y -= 40
	hud.show_bonus_points(player_pos, bonus_points)
	global.give_points(bonus_points)


func _on_Bounds_body_entered(body : PhysicsBody2D):
	if body.name == "Player":
		body.hurt()


func _on_HUD_little_time_left():
	$Sounds/LevelSound.pitch_scale = 1.075


func stop_items():
	$Sounds/LevelSound.stop()
	hud.stop_time()
	for item in $Environment.get_children():
		item.stop()
	

#################################################
# Losing methods

func _on_Player_hit():
	stop_items()


func _on_HUD_out_of_time():
	lose()


func _on_Player_lose():
	lose()


func lose():
	stop_items()
	$Sounds/LevelSound.stop()
	global.lose_life()
	yield(get_tree().create_timer(0.66), "timeout")
	$Sounds/GameOverSound.play()

func _on_GameOverSound_finished():
	get_tree().call_deferred("change_scene","res://Levels/ScenePreviewer.tscn")

#################################################
# Winning methods

func _on_Player_win():
	hud.give_bonus_start()
	$Podium.player_center($Player)
#	audience_timer.start()
	$Sounds/LevelSound.stop()
	$Sounds/WinSound.play()


func _on_bonus_giving_finished():
	if not $Sounds/WinSound.playing:
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()


func _on_WinSound_finished():
#	audience_timer.stop()
#	$Background/Celebrating.visible = false
	if not hud.is_giving_bonus():
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()
	else:
		hud.bonus_giving_play()
