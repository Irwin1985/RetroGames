extends Node2D

const total_swings : int = 10

func _ready():
	randomize()
	$Player.position.x += 0
	$Player.position.y -= 150
	var trampolines : PackedScene = preload("res://Items/Trampoline/trampoline.tscn")
	var swings : PackedScene = preload("res://Items/Swing/swing.tscn")
	for i in range (total_swings):
		# Add Trampolines
		if i < total_swings - 1: # Don't add the last one
			var new_trampoline : Trampoline = trampolines.instance()
			new_trampoline.position = Vector2((i + 1) * 256, 396)
			$EnvironmentObjects.add_child(new_trampoline)
		# Add Swings
		var new_swing : Swing = swings.instance()
		new_swing.position = Vector2(i * 256 + 160, 120)
		if i > 0:
			new_swing.set_speed(randf() + 0.5) # 0.5-1.5
		if i % 2 != 0:
			new_swing.reset_swing_position()
		$EnvironmentObjects.add_child(new_swing)

func _on_Detector_body_entered(body : PhysicsBody2D)->void:
	if body.name == "Player":
		body.hurt()

#################################################
# Losing methods
#func _on_HUD_out_of_time():
#	lose()
#
#func hurt():
#	$HUD.stop_time()
#	$Lion.hurt()
#	lose()

func lose():
#	stop_items()
	$Player.stop()
	$Sounds/LevelSound.stop()
#	$Sounds/HurtSound.play()
	global.lives -= 1
	if global.lives <= 0:
		global.is_game_over = true
		
#################################################
# Winning methods
func _on_Player_win():
#	for flame in $FlameContainer.get_children():
#		flame.queue_free()
#	var podium_level : Vector2 = $Items/Podium.position + Vector2.UP * 38
#	podium_level.x = $Player.get_position().x
#	$Player.set_position(podium_level)
#	$HUD.stop_time()
#	podium_center_timer.start()
#	bonus_timer.start()
	$Sounds/LevelSound.stop()
#	$Sounds/WinSound.play()