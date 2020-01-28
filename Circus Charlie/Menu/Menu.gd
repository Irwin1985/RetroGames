extends Control

var selected_option : int = 0
onready var options = [
		$Portrait/ClassicMode,
		$Portrait/FreeMode,
		$Portrait/ChallengeMode,
		$Portrait/EnduranceMode,
		$Portrait/Options,
		$Portrait/Exit
	]

var blink_timer = Timer.new()
var start_timer = Timer.new()


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
	start_timer.start()
	add_child(start_timer)


func _blink_timeout()->void:
	options[selected_option].visible = !options[selected_option].visible


func _start_timeout()->void:
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


func move_hand()->void:
	$Portrait/SelectHand.rect_position.y = \
			options[selected_option].rect_position.y + 12


func _on_StartSound_finished():
	if selected_option != 1:
		global.start_classic_mode()
	elif selected_option == 1:
		global.start_free_mode()