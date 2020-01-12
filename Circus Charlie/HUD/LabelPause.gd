extends Label

onready var timer_pause = Timer.new()


func _ready():
	visible = false
	timer_pause.connect("timeout", self, "_on_timer_pause_timeout")
	timer_pause.wait_time = 0.3
	add_child(timer_pause)


func _input(event):
	if global.can_pause:
		if event.is_action_pressed("ui_accept"):
			if !get_tree().paused:
				visible = true
				timer_pause.start()
				get_node("..").get_node("PauseSound").play()
				get_tree().paused = true
			else:
				get_tree().paused = false
				visible = false
				timer_pause.stop()


func _on_timer_pause_timeout():
	visible = !visible