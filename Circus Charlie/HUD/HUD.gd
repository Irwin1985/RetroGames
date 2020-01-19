extends CanvasLayer

class_name GameHUD

signal little_time_left
signal out_of_time
signal bonus_giving_finished

var label_timer = Timer.new()
var game_timer = Timer.new()
var bonus_timer = Timer.new()
var time_left = 5000
var time_delta = 10

func _ready():
	$AlphaVersionLabel.visible = global.IS_ALPHA_VERSION
	set_sfx_volume()
	update_stage()
	create_timer()

func set_sfx_volume():
	for audio in $Sounds.get_children():
		audio.volume_db = global.STANDARD_VOLUME


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
	
	# Bonus to score timer
	bonus_timer.connect("timeout", self, "_on_bonus_timeout")	
	bonus_timer.wait_time = 0.02
	add_child(bonus_timer)


func update_timer():
	$Bonus/LabelTimer.text = "%04d" % time_left


func begin_time():
	game_timer.start()


func stop_time():
	game_timer.stop()


func hide_lives():
	for life in $Lives.get_children():
		life.visible = false


func update_score(score):
	$PlayerScore/PlayerScore.text = "%06d" % score
	if global.life_score_counter >= global.LIFE_SCORE_LIMIT:
		global.life_score_counter = 0
		$Sounds/LiveEarned.play()
		global.lives += 1
		update_lives(global.lives)


func update_hi_score(score):
	$HiScore/LabelHiScore.text = "%06d" % score


func update_lives(lives: int) -> void:
	hide_lives()
	$Lives/SpriteLive1.visible = lives >= 1
	$Lives/SpriteLive2.visible = lives >= 2
	$Lives/SpriteLive3.visible = lives >= 3
	$Lives/SpriteLife4.visible = lives >= 4
	$Lives/SpriteLife5.visible = lives >= 5
	$Lives/SpriteLife6.visible = lives >= 6


func update_stage():
	$Stage/LabelStage.text = "%02d" % (global.current_level + 1)


func show_bonus_points(pos: Vector2, points: int, do_not_play_sound: bool = false) -> void:
	var label_points = $LabelPoints.duplicate()
	label_points.text = str(points)
	label_points.rect_position = pos - (label_points.rect_size / 2)
	label_points.visible = true
	if not do_not_play_sound:
		$Sounds/BonusSound.play()
	add_child(label_points)
	yield(get_tree().create_timer(0.5),"timeout")
	label_points.call_deferred("queue_free")


func _on_game_label_timeout():
	time_left -= time_delta
	update_timer()
	if time_left > (1000 - time_delta) and time_left <= 1000:
		emit_signal("little_time_left")
	elif time_left <= 0:
		time_left = 0
		game_timer.stop()
		emit_signal("out_of_time")


func give_bonus_start():
	stop_time()
	bonus_timer.start()


func bonus_giving_play():
	$Sounds/BonusGivingSound.play()


func is_giving_bonus():
	return not bonus_timer.is_stopped()


func _on_bonus_timeout():
	add_time_to_score(10)
	if time_left <= 0:
		emit_signal("bonus_giving_finished")
		$Sounds/BonusGivingSound.stop()
		bonus_timer.stop()


func add_time_to_score(value: int) -> void:
	if time_left > value:
		global.give_points(value)
		time_left -= value
	else:
		global.give_points(time_left)
		time_left = 0
	update_timer()


func _on_timer_label_timeout():
	$PlayerScore/LabelPlayer.visible = !$PlayerScore/LabelPlayer.visible
	$PlayerScore/PlayerSeparator.visible = $PlayerScore/PlayerSeparator.visible

func _on_LabelPause_paused_game():
	$Sounds/PauseSound.play()
