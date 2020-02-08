extends MarginContainer

func _ready():
	if global.is_unlocked(global.KEY_CHALLENGE_LEVEL1):
		$NinePatchRect/MarginContainer/LevelContainer/TopLevels/Level1.visible = true
		$NinePatchRect/MarginContainer/LevelContainer/TopLevels/Level1/TextureButton.grab_focus()
	if global.is_unlocked(global.KEY_CHALLENGE_LEVEL2):
		$NinePatchRect/MarginContainer/LevelContainer/TopLevels/Level2.visible = true
	if global.is_unlocked(global.KEY_CHALLENGE_LEVEL3):
		$NinePatchRect/MarginContainer/LevelContainer/TopLevels/Level3.visible = true
	if global.is_unlocked(global.KEY_CHALLENGE_LEVEL4):
		$NinePatchRect/MarginContainer/LevelContainer/BottomLevels/Level4.visible = true
	if global.is_unlocked(global.KEY_CHALLENGE_LEVEL5):
		$NinePatchRect/MarginContainer/LevelContainer/BottomLevels/Level5.visible = true
	if global.is_unlocked(global.KEY_CHALLENGE_LEVELN):
		$NinePatchRect/MarginContainer/LevelContainer/BottomLevels/LevelN.visible = true


func _on_Level1_button_down():
	global.start_challenge_mode(0)


func _on_Level2_button_down():
	global.start_challenge_mode(1)


func _on_Level3_button_down():
	global.start_challenge_mode(2)


func _on_Level4_button_down():
	global.start_challenge_mode(3)


func _on_Level5_button_down():
	global.start_challenge_mode(4)


func _on_LevelN_button_down():
	global.start_challenge_mode(5)
