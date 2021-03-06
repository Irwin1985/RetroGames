extends MarginContainer

const  OPTIONS_PER_ROW : int = 3

onready var level1 = $NinePatchRect/MarginContainer/LevelContainer/TopLevels/Level1
onready var level2 = $NinePatchRect/MarginContainer/LevelContainer/TopLevels/Level2
onready var level3 = $NinePatchRect/MarginContainer/LevelContainer/TopLevels/Level3
onready var level4 = $NinePatchRect/MarginContainer/LevelContainer/BottomLevels/Level4
onready var level5 = $NinePatchRect/MarginContainer/LevelContainer/BottomLevels/Level5
onready var leveln = $NinePatchRect/MarginContainer/LevelContainer/BottomLevels/LevelN
onready var back = $NinePatchRect/MarginContainer/LevelContainer/Back

onready var select_options = [level1, level2, level3, level4, level5, leveln, back]
var selectable = [false, false, false, false, false, false, true]
var selected: int = 6

func _ready():
# Show unlocked levels
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

# Show unlocked stars
	show_stars(level1, global.KEY_CHALLENGE_LEVEL1)
	show_stars(level2, global.KEY_CHALLENGE_LEVEL2)
	show_stars(level3, global.KEY_CHALLENGE_LEVEL3)
	show_stars(level4, global.KEY_CHALLENGE_LEVEL4)
	show_stars(level5, global.KEY_CHALLENGE_LEVEL5)
	show_stars(leveln, global.KEY_CHALLENGE_LEVELN)
	move_cursor()

func show_stars(level: Node, challenge_key: String) -> void:
	var unlocked_stars : int = global.unlocked_stars(challenge_key)
	var star_count : int = 0
	for star in level.get_node("Block/Stars").get_children():
		star_count += 1
		if star_count <= unlocked_stars:
			star.visible = true
		else:
			star.visible = false


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
		selected -= OPTIONS_PER_ROW
		while selected >= 0 and not selectable[selected]:
			selected -= OPTIONS_PER_ROW
		if selected < 0:
			selected = len(select_options) - 1
	elif event.is_action_pressed("ui_down"):
		if selected == len(select_options) - 1:
			selected = 0
		else:
			selected += OPTIONS_PER_ROW
			while selected < len(select_options) and not selectable[selected]:
				selected += OPTIONS_PER_ROW
			if selected >= len(select_options):
				selected = len(select_options) - 1
	move_cursor()
	if event.is_action_pressed("ui_cancel"):
		get_tree().call_deferred("change_scene", "res://Menu/Menu.tscn")
	elif event.is_action_pressed("ui_accept"):
		if selected == len(select_options) - 1:
			get_tree().call_deferred("change_scene", "res://Menu/Menu.tscn")
		else:
			global.start_challenge_mode(selected)
