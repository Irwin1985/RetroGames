extends Control


func _ready():
	$StageSound.volume_db = global.STANDARD_VOLUME
	if !global.play_first_sound:
		global.play_first_sound = true
		$StageSound.play()

	add_child(global.get_HudInstance(false))
	
	if !global.is_game_over:
		$StageCaption/StageLabel.text = "STAGE  0" + str(global.current_level + 1)
		yield(get_tree().create_timer(2), "timeout")
		while get_tree().paused:
			yield(get_tree().create_timer(0.25), "timeout")
		global.show_level()
	else: # Game Over
		$StageCaption/StageLabel.text = "GAME    OVER"
		yield(get_tree().create_timer(4), "timeout")
		global.restart_game()
		get_tree().call_deferred("change_scene", "res://Menu/Menu.tscn")