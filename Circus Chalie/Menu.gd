extends Control
var enter_counter = 0
var counter = 0

func _ready():
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
#				$Timer.wait_time = 1
#				$Timer.autostart = false
#				$Timer.start()

func _process(delta):
	counter += 1
	if counter >= 10:
		counter = 0
		$Portrait/LabelSelect.visible = !$Portrait/LabelSelect.visible

func _on_Timer_timeout():
	enter_counter += 1
	$Portrait.show()

func _on_StartSound_finished():
	global.current_level += 1
	get_tree().change_scene("res://ScenePreviewer.tscn")
