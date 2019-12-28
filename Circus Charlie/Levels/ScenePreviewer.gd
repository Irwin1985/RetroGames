extends Control

#onready var timer = Timer.new()


func _ready():
	$StageSound.volume_db = global.STANDARD_VOLUME
	if !global.play_first_sound:
		global.play_first_sound = true
		$StageSound.play()

	add_child(global.get_hud(false))
#	$HUD.update_lives()
#	$HUD.update_score(0)
#	$HUD.update_hi_score(0)
	
	if !global.is_game_over:
		$StageCaption/StageLabel.text = "STAGE 0" + str(global.current_level + 1)
		yield(get_tree().create_timer(2), "timeout")
		get_tree().call_deferred("change_scene", \
				global.stage[global.current_level])
	else: # Game Over
		$StageCaption/StageLabel.text = "GAME OVER"
		yield(get_tree().create_timer(4), "timeout")
		global.restart_game()
		get_tree().call_deferred("change_scene", "res://Menu/Menu.tscn")
#	timer.connect("timeout", self, "_on_timer_timeout")
#	timer.wait_time = 2
#	add_child(timer)
#	timer.start()
#
#func _on_timer_timeout():
#	get_tree().change_scene(global.stage[global.current_level])

