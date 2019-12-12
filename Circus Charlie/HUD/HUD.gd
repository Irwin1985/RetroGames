extends CanvasLayer

onready var label_timer = Timer.new()
onready var game_timer = Timer.new()
var time_left = 5000


func _ready():
	hide_lives()
	update_lives()
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
	if score > 0:
		global.player_score += score	
	$PlayerScore/PlayerScore.text = "%06d" % global.player_score


func update_hi_score():	
	$HiScore/LabelHiScore.text = "%06d" % global.hi_score


func update_lives():
	hide_lives()
	for l in global.lives:
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


func update_stage():
	$Stage/LabelStage.text = "0" + str(global.current_level + 1)


func add_time_to_score(value : int)->void:
	time_left -= value
	update_timer()
	update_score(value)


func _on_timer_label_timeout():
	$PlayerScore/LabelPlayer.visible = !$PlayerScore/LabelPlayer.visible


func _on_game_label_timeout():
	time_left -= 10
	update_timer()