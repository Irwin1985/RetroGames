extends CanvasLayer

class_name GameHUD

var label_timer = Timer.new()
var game_timer = Timer.new()
var time_left = 5000
var time_delta = 10
signal little_time_left
signal out_of_time

func _ready():
	$PauseSound.volume_db = global.STANDARD_VOLUME
#	hide_lives()
#	update_lives(0)
	update_stage()
	create_timer()


func create_timer():
	# Label Timer
	label_timer.connect("timeout", self, "_on_timer_label_timeout")
	label_timer.wait_time = 0.5
	label_timer.start()
	add_child(label_timer)
	
	# Game Timer
	game_timer.connect("timeout", self, "_on_game_label_timeout")
	game_timer.wait_time = 0.3
	add_child(game_timer)
	update_timer()


func update_timer():
	$Bonus/LabelTimer.text = "%04d" % time_left


func begin_time():
	game_timer.start()


func stop_time():
	game_timer.stop()


func hide_lives():
	$Lives/SpriteLive1.visible = false
	$Lives/SpriteLive2.visible = false
	$Lives/SpriteLive3.visible = false


func update_score(score):
	$PlayerScore/PlayerScore.text = "%06d" % score


func update_hi_score(score):
	$HiScore/LabelHiScore.text = "%06d" % score


func update_lives(lives: int)->void:
	hide_lives()
	for l in lives:
		match l:
			0:
				$Lives/SpriteLive3.visible = true
			1:
				$Lives/SpriteLive2.visible = true
				$Lives/SpriteLive3.visible = true
			2:
				$Lives/SpriteLive1.visible = true
				$Lives/SpriteLive2.visible = true
				$Lives/SpriteLive3.visible = true
	$Lives/SpriteLife4.visible = lives >= 4


func update_stage():
	$Stage/LabelStage.text = "0" + str(global.current_level + 1)


func add_time_to_score(value : int)->void:
	time_left -= value
	update_timer()
	update_score(value)


func _on_timer_label_timeout():
	$PlayerScore/LabelPlayer.visible = !$PlayerScore/LabelPlayer.visible


func _on_game_label_timeout():
	time_left -= time_delta
	update_timer()
	if time_left > (1000 - time_delta) and time_left <= 1000:
		emit_signal("little_time_left")
	elif time_left <= 0:
		time_left = 0
		game_timer.stop()
		emit_signal("out_of_time")