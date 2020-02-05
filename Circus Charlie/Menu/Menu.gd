extends Control

const HAND_Y_OFFSET = 12

enum option {CLASSIC_MODE, FREE_MODE, CHALLENGE_MODE, ENDURANCE_MODE, OPTIONS, EXIT}

enum menu_type {MAIN_MENU, SELECT_LEVEL, ENTERING_GAME}

var selected_option : int = 0
var blink_timer = Timer.new()
var menu : int = menu_type.MAIN_MENU
var level_select : int = 1

onready var options = [
		$Portrait/ClassicMode,
		$Portrait/FreeMode,
		$Portrait/ChallengeMode,
		$Portrait/EnduranceMode,
		$Portrait/Options,
		$Portrait/Exit
	]

func _ready():
	$StartSound.volume_db = global.STANDARD_VOLUME
	$Portrait.hide()
	
	# Blink Timer
	blink_timer.connect("timeout", self, "_blink_timeout", [], CONNECT_DEFERRED)
	blink_timer.wait_time = 0.2
	add_child(blink_timer)
	
	# Start Timer
	yield(get_tree().create_timer(1), "timeout")
	$Portrait.show()


func _blink_timeout() -> void:
	options[selected_option].visible = !options[selected_option].visible


func _input(event):
	match menu:
		menu_type.MAIN_MENU:
			if event.is_action_pressed("ui_accept"):
				if selected_option == option.FREE_MODE:
					$Portrait/FreeMode/LevelSelect.visible = true
					$Portrait/FreeMode/LevelSelect.text = "LEVEL %02d" % level_select
					menu = menu_type.SELECT_LEVEL
				else:
					level_select = 1
					menu = menu_type.ENTERING_GAME
					blink_timer.start()
					$StartSound.play()
			elif event.is_action_pressed("ui_down"):
				selected_option = (selected_option + 1) % len(options)
				move_hand()
			elif event.is_action_pressed("ui_up"):
				selected_option = (selected_option - 1) % len(options)
				move_hand()
			elif event.is_action_pressed("debug_mode"):
				if selected_option == option.CLASSIC_MODE:
					$Portrait/FreeMode/LevelSelect.visible = true
					menu = menu_type.SELECT_LEVEL
		menu_type.SELECT_LEVEL:
			if event.is_action_pressed("ui_accept"):
				menu = menu_type.ENTERING_GAME
				blink_timer.start()
				$StartSound.play()
			elif event.is_action_pressed("ui_cancel"):
				$Portrait/FreeMode/LevelSelect.visible = false
				menu = menu_type.MAIN_MENU
			elif event.is_action_pressed("ui_down") or \
					event.is_action_pressed("ui_left"):
				level_select = int(max(1, level_select - 1))
				$Portrait/FreeMode/LevelSelect.text = "LEVEL %02d" % level_select
			elif event.is_action_pressed("ui_up") or \
					event.is_action_pressed("ui_right"):
				level_select = int(min(99, level_select + 1))
				$Portrait/FreeMode/LevelSelect.text = "LEVEL %02d" % level_select
		menu_type.ENTERING_GAME:
			pass


func move_hand() -> void:
	$Portrait/SelectHand.rect_position.y = \
			options[selected_option].rect_position.y + HAND_Y_OFFSET


func _on_StartSound_finished():
	match selected_option:
		option.CLASSIC_MODE:
			global.start_classic_mode(level_select - 1)
		option.FREE_MODE:
			global.start_free_mode(level_select - 1)
		option.CHALLENGE_MODE:
			pass
		option.ENDURANCE_MODE:
			pass
		option.OPTIONS:
			pass
		option.EXIT:
			get_tree().quit()
