extends "res://Levels/level_base.gd"

const TOTAL_SWINGS: int = 9

onready var platform_center_timer = Timer.new()


func _ready():
	set_player_position()
	set_environment()
	platform_center_timer.connect("timeout", self, "_on_platform_center_timeout")	
	platform_center_timer.wait_time = 0.02
	add_child(platform_center_timer)
	audience_timer.connect("timeout", self, "_on_audience_timeout")	
	audience_timer.wait_time = 0.05
	add_child(audience_timer)


func set_environment():
	var Trampolines: PackedScene = preload("res://Items/Trampoline/trampoline.tscn")
	var Swings: PackedScene = preload("res://Items/Swing/swing.tscn")
	for i in range (TOTAL_SWINGS):
		# Add Trampolines
		if i < TOTAL_SWINGS - 1: # Don't add the last one
		# Skip some trampolines on highest difficulty
			var new_trampoline = Trampolines.instance()
			new_trampoline.position = Vector2((i + 1) * 256, 396)
			$EnvironmentObjects.add_child(new_trampoline)
		# Add Swings
		var new_swing = Swings.instance()
		new_swing.position = Vector2(i * 256 + 160, 124)
		if i == min(global.check_point, 3) * 2:
			new_swing.set_speed(0.85)
			new_swing.already_grabbed = true
		else:
			new_swing.set_speed(randf() * 0.2 + 0.75) # 0.75-0.95
			# Used for difficulty settings 
#			new_swing.set_speed(randf() * 0.25 + 0.70) # 0.70-0.95
#			new_swing.set_speed(randf() * 0.30 + 0.70) # 0.70-1
#			new_swing.set_speed(randf() * 0.35 + 0.65) # 0.65-1
#			new_swing.set_speed(randf() * 0.40 + 0.60) # 0.60-1
			if i % 2 != 0:
				new_swing.reset_swing_position()
			else:
#warning-ignore: integer_division
				new_swing.put_checkpoint(i/2)
		if new_swing.connect("first_grab", self, "_on_swing_first_grab") != OK:
			print("Error connecting swing's first grab signal")
		$EnvironmentObjects.add_child(new_swing)


func set_player_position():
	$Player.jumping = true
	$Player.position.x += min(global.check_point, 3) * 512
	$Player.position.y -= 150


func _on_swing_first_grab():
	var player_pos: Vector2 = $Player.get_global_transform_with_canvas().get_origin()
	player_pos.x += 50
	hud.show_bonus_points(player_pos, 500)
	global.give_points(500)


func _on_Detector_body_entered(body: PhysicsBody2D) -> void:
	if body.name == global.PLAYER_NAME:
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
	stop_items()
	$Player.hit_and_fall()


func _on_Player_lose():
	lose()


func _on_GameOverSound_finished():
	get_tree().call_deferred("change_scene","res://Levels/ScenePreviewer.tscn")


#################################################
# Winning methods

func _on_Player_win():
	for item in $EnvironmentObjects.get_children():
		item.call_deferred("queue_free")
	player_won()
	platform_center_timer.start()


func _on_platform_center_timeout() -> void:
	var xdelta: int = ($HighPlatform.get_position() - $Player.get_position() ).x
	if abs(xdelta) > 1:
		var direction : Vector2 = Vector2(xdelta, 0).normalized()
		$Player.set_position($Player.get_position() + direction)
	else:
		platform_center_timer.stop()


func _on_WinSound_finished():
	WinSound_finished($Player)