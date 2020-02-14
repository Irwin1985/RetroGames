extends MarginContainer

onready var level1 = $NinePatchRect/MarginContainer/LevelContainer/TopLevels/Level1
onready var level2 = $NinePatchRect/MarginContainer/LevelContainer/TopLevels/Level2
onready var level3 = $NinePatchRect/MarginContainer/LevelContainer/TopLevels/Level3
onready var level4 = $NinePatchRect/MarginContainer/LevelContainer/BottomLevels/Level4
onready var level5 = $NinePatchRect/MarginContainer/LevelContainer/BottomLevels/Level5
onready var leveln = $NinePatchRect/MarginContainer/LevelContainer/BottomLevels/LevelN
onready var back = $NinePatchRect/MarginContainer/LevelContainer/Back

onready var select_options = [level1, level2, level3, level4, level5, leveln, back]
var selectable = [false, false, false, false, false, false, true]
var selected: int = 0

func _ready():
	if global.is_unlocked(global.KEY_CHALLENGE_LEVEL1):
		level1.visible = true
		selectable[0] = true
#		$NinePatchRect/MarginContainer/LevelContainer/TopLevels/Level1/TextureButton.grab_focus()
	if global.is_unlocked(global.KEY_CHALLENGE_LEVEL2):
		level2.visible = true
		selectable[1] = true
	if global.is_unlocked(global.KEY_CHALLENGE_LEVEL3):
		level3.visible = true
		selectable[2] = true
	if global.is_unlocked(global.KEY_CHALLENGE_LEVEL4):
		level4.visible = true
		selectable[3] = true
	if global.is_unlocked(global.KEY_CHALLENGE_LEVEL5):
		level5.visible = true
		selectable[4] = true
	if global.is_unlocked(global.KEY_CHALLENGE_LEVELN):
		leveln.visible = true
		selectable[5] = true
	move_cursor()


func move_cursor():
	for idx in range(len(select_options)):
		if idx == selected:
			select_options[idx].get_node("Hand").modulate = Color(1,1,1)
			if select_options[idx].has_node("Block"):
				select_options[idx].get_node("Block/Unselected").visible = false
				select_options[idx].get_node("Block/Selected").visible = true
		else:
			select_options[idx].get_node("Hand").modulate = Color(0,0,0)
			if select_options[idx].has_node("Block"):
				select_options[idx].get_node("Block/Unselected").visible = true
				select_options[idx].get_node("Block/Selected").visible = false


func _input(event):
	if event.is_action_pressed("ui_left"):
		selected -= 1
		if selected < 0:
			selected += len(select_options)
		while not selectable[selected]:
			selected -= 1
			if selected < 0:
				selected += len(select_options)
	elif event.is_action_pressed("ui_right"):
		selected = (selected + 1) % len(select_options)
		while not selectable[selected]:
			selected = (selected + 1) % len(select_options)
	elif event.is_action_pressed("ui_up"):
		if selected >= 3:
			selected -= 3
			if not selectable[selected]:
				selected = len(select_options) - 1
		else:
			selected = len(select_options) - 1
	elif event.is_action_pressed("ui_down"):
		if selected <= 3:
			selected += 3
			if not selectable[selected]:
				selected = len(select_options) - 1
		elif selected == len(select_options) - 1 and selectable[0]:
			selected = 0
		else:
			selected = len(select_options) - 1
	move_cursor()
	if event.is_action_pressed("ui_cancel"):
		get_tree().call_deferred("change_scene", "res://Menu/Menu.tscn")
	elif event.is_action_pressed("ui_accept"):
		if selected == len(select_options) - 1:
			get_tree().call_deferred("change_scene", "res://Menu/Menu.tscn")
		else:
			global.start_challenge_mode(selected)