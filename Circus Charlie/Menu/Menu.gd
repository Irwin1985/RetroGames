extends Control

const HAND_Y_OFFSET = 12

enum option {CLASSIC_MODE, FREE_MODE, CHALLENGE_MODE, ENDURANCE_MODE, OPTIONS, EXIT}

var selected_option : int = 0
var blink_timer = Timer.new()
var start_timer = Timer.new()

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
	start_timer.connect("timeout", self, "_start_timeout", [], CONNECT_DEFERRED)
	start_timer.wait_time = 1
	add_child(start_timer)
	start_timer.start()


func _blink_timeout() -> void:
	options[selected_option].visible = !options[selected_option].visible


func _start_timeout() -> void:
	$Portrait.show()


func _input(event):
	if event.is_action_pressed("ui_accept"):
		blink_timer.start()
		$StartSound.play()
	elif event.is_action_pressed("ui_down"):
		selected_option = (selected_option + 1) % len(options)
		move_hand()
	elif event.is_action_pressed("ui_up"):
		selected_option = (selected_option - 1) % len(options)
		move_hand()


func move_hand() -> void:
	$Portrait/SelectHand.rect_position.y = \
			options[selected_option].rect_position.y + HAND_Y_OFFSET


func _on_StartSound_finished():
	match selected_option:
		option.CLASSIC_MODE:
			global.start_classic_mode()
		option.FREE_MODE:
			global.start_free_mode()
		option.CHALLENGE_MODE:
			pass
		option.ENDURANCE_MODE:
			pass
		option.OPTIONS:
			pass
		option.EXIT:
			get_tree().quit()
