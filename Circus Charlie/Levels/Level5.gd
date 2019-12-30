extends Node2D

const total_swings : int = 9

onready var platform_center_timer = Timer.new()
onready var audience_timer = Timer.new()
var hud : GameHUD = null


func _ready():
	randomize()
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
	var trampolines : PackedScene = preload("res://Items/Trampoline/trampoline.tscn")
	var swings : PackedScene = preload("res://Items/Swing/swing.tscn")
	for i in range (total_swings):
		# Add Trampolines
		if i < total_swings - 1: # Don't add the last one
			var new_trampoline = trampolines.instance()
			new_trampoline.position = Vector2((i + 1) * 256, 396)
			$EnvironmentObjects.add_child(new_trampoline)
		# Add Swings
		var new_swing = swings.instance()
		new_swing.position = Vector2(i * 256 + 160, 124)
		if i == 0:
			new_swing.set_speed(0.9)
		else:
			new_swing.set_speed(randf() * 0.3 + 0.85) # 0.85-1.15
#			new_swing.set_speed(randf() * 0.6 + 0.7) # 0.7-1.3
#			new_swing.set_speed(randf() * 0.9 + 0.55) # 0.55-1.45
#			new_swing.set_speed(randf() * 1.2 + 0.4) # 0.4-1.6
			if i % 2 != 0:
				new_swing.reset_swing_position()
			else:
				new_swing.put_checkpoint(i/2)
		if new_swing.connect("first_grab", self, "_on_swing_first_grab") != OK:
			print("Error connecting swing's first grab signal")
		$EnvironmentObjects.add_child(new_swing)
	platform_center_timer.connect("timeout", self, "_on_platform_center_timeout")	
	platform_center_timer.wait_time = 0.02
	add_child(platform_center_timer)
	audience_timer.connect("timeout", self, "_on_audience_timeout")	
	audience_timer.wait_time = 0.05
	add_child(audience_timer)


func set_player_position():
	$Player.jumping = true
	var checkpoint_pos : int = 0
	match global.check_point:
		1, 2, 3:
			checkpoint_pos = 512 * global.check_point
		4: # Last one at 10M goes back to 20M
			checkpoint_pos = 512 * 3
		_:
			checkpoint_pos = 0
	$Player.position.x += checkpoint_pos
	$Player.position.y -= 150


func _on_swing_first_grab():
	global.give_points(500)


func _on_Detector_body_entered(body : PhysicsBody2D)->void:
	if body.name == "Player":
		body.hurt()


func stop_items():
	$Sounds/LevelSound.stop()
	for item in $EnvironmentObjects.get_children():
		item.stop()


func _on_HUD_little_time_left():
	$Sounds/LevelSound.pitch_scale = 1.075


#################################################
# Losing methods

func _on_HUD_out_of_time():
#	lose()
	stop_items()
	$Player.hit_and_fall()


func _on_Player_lose():
	lose()


func lose():
	hud.stop_time()
#	stop_items()
	$Sounds/LevelSound.stop()
	global.lose_life()
	yield(get_tree().create_timer(0.66), "timeout")
	$Sounds/GameOverSound.play()


func _on_GameOverSound_finished():
	get_tree().call_deferred("change_scene","res://Levels/ScenePreviewer.tscn")


#################################################
# Winning methods

func _on_Player_win():
	for item in $EnvironmentObjects.get_children():
		item.call_deferred("queue_free")
#	var podium_level : Vector2 = $Items/Podium.position + Vector2.UP * 38
#	podium_level.x = $Player.get_position().x
#	$Player.set_position(podium_level)
	hud.give_bonus_start()
	platform_center_timer.start()
	audience_timer.start()
	$Sounds/LevelSound.stop()
	$Sounds/WinSound.play()


func _on_platform_center_timeout()->void:
	var xdelta : int = ($HighPlatform.get_position() - $Player.get_position() ).x
	if abs(xdelta) > 1:
		var direction : Vector2 = Vector2(xdelta, 0).normalized()
		$Player.set_position($Player.get_position() + direction)
	else:
		platform_center_timer.stop()


func _on_audience_timeout()->void:
	$Background/Celebrating.visible = not $Background/Celebrating.visible


func _on_bonus_giving_finished():
	if not $Sounds/WinSound.playing:
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()


func _on_WinSound_finished():
	audience_timer.stop()
	$Background/Celebrating.visible = false
	if not hud.is_giving_bonus():
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()
	else:
		hud.bonus_giving_play()
