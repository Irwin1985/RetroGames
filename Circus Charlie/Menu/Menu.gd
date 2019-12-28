extends Control

var enter_counter = 0
var counter = 0


func _ready():
	$StartSound.volume_db = global.STANDARD_VOLUME
	$Portrait.hide()
	set_process(false)


func _input(event):
	if Input.is_action_pressed("ui_accept"):
		enter_counter += 1
		match enter_counter:
			1:
				$Timer.stop()
				$Portrait.show()
			2:
				$StartSound.play()
				set_process(true)

func _process(delta):
	counter += delta
	if counter >= 0.2:
		counter = 0
		$Portrait/SelectLabel.visible = !$Portrait/SelectLabel.visible


func _on_Timer_timeout():
	enter_counter += 1
	$Portrait.show()


func _on_StartSound_finished():
	global.start_next_level()
