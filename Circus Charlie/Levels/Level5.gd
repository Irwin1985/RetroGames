extends Node2D

const total_swings : int = 9

onready var platform_center_timer = Timer.new()
onready var audience_timer = Timer.new()

func _ready():
	randomize()
	$Player.position.x += 0
	$Player.position.y -= 150
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
		$EnvironmentObjects.add_child(new_swing)
	platform_center_timer.connect("timeout", self, "_on_platform_center_timeout")	
	platform_center_timer.wait_time = 0.02
	add_child(platform_center_timer)
	audience_timer.connect("timeout", self, "_on_audience_timeout")	
	audience_timer.wait_time = 0.05
	add_child(audience_timer)

func _on_Detector_body_entered(body : PhysicsBody2D)->void:
	if body.name == "Player":
		body.hurt()

func stop_items():
	for item in $EnvironmentObjects.get_children():
		item.call_deferred("queue_free")

#################################################
# Losing methods
#func _on_HUD_out_of_time():
#	lose()

func _on_Player_lose():
	lose()

func lose():
#	stop_items()
#	$HUD.stop_time()
	$Sounds/LevelSound.stop()
	global.lives -= 1
	if global.lives <= 0:
		global.is_game_over = true
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
#	$HUD.stop_time()
	platform_center_timer.start()
	audience_timer.start()
#	bonus_timer.start()
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
		
func _on_WinSound_finished():
		audience_timer.stop()
		$Background/Celebrating.visible = false
#	if bonus_timer.is_stopped():
		yield(get_tree().create_timer(0.5), "timeout")
		global.start_next_level()
#	else:
#		$Sounds/ReduceTimeSound.play()
