extends Control


func _ready():
	$StageSound.volume_db = global.STANDARD_VOLUME
	if !global.play_first_sound:
		global.play_first_sound = true
		$StageSound.play()

	add_child(global.get_HudInstance(false))
	
	if !global.is_game_over:
		if global.game_mode == global.CHALLENGE_MODE:
			match global.level_difficulty:
				1:
					$StageCaption/StageLabel.text = "EASY"
				2:
					$StageCaption/StageLabel.text = "NORMAL"
				3:
					$StageCaption/StageLabel.text = "HARD"
				4:
					$StageCaption/StageLabel.text = "HARDER"
				5:
					$StageCaption/StageLabel.text = "EXTREME"
		else:
			$StageCaption/StageLabel.text = "STAGE %02d" % (global.current_level + 1)
			if global.game_mode == global.CLASSIC_MODE:
				match global.current_level:
					0:
						global.unlock(global.KEY_CHALLENGE_LEVEL1)
					1:
						global.unlock(global.KEY_CHALLENGE_LEVEL2)
					2:
						global.unlock(global.KEY_CHALLENGE_LEVEL3)
					3:
						global.unlock(global.KEY_CHALLENGE_LEVEL4)
					4:
						global.unlock(global.KEY_CHALLENGE_LEVEL5)
					5:
						global.unlock(global.KEY_CHALLENGE_LEVELN)
		yield(get_tree().create_timer(2), "timeout")
		while get_tree().paused:
			yield(get_tree().create_timer(0.25), "timeout")
		global.show_level()
	else: # Game Over
		$StageCaption/StageLabel.text = "GAME OVER"
		yield(get_tree().create_timer(4), "timeout")
		global.restart_game()
		get_tree().call_deferred("change_scene", "res://Menu/Menu.tscn")