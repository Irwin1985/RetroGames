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
	set_sfx_volume()
	update_stage()
	create_timer()
	set_process(false)
	if global.game_mode == global.FREE_MODE:
		$FreeMode.set_visible(true)
		$HiScore.set_visible(false)
		$PlayerScore.set_visible(false)
		$Lives.set_visible(false)
		
	elif global.game_mode == global.CHALLENGE_MODE:
		$Stage.set_visible(false)
		$Difficulty.set_visible(true)
		match global.level_difficulty:
			1:
				$Difficulty/Desc.text = "EASY"
			2:
				$Difficulty/Desc.text = "NORMAL"
			3:
				$Difficulty/Desc.text = "HARD"
			4:
				$Difficulty/Desc.text = "HARDER"
			5:
				$Difficulty/Desc.text = "EXTREME"
	elif global.game_mode == global.ENDURANCE_MODE:
		$Stage.set_visible(false)
		$EnduranceMode.set_visible(true)
		$Bonus.set_visible(false)
		$Time.set_visible(true)
		$Lives.set_visible(false)
		update_endurance_timer()

	$AlphaVersionLabel.visible = global.IS_ALPHA_VERSION


func start_endurance() -> void:
	set_process(true)
	
func stop_endurance() -> void:
	set_process(false)

func update_endurance_timer() -> void:
	var total_time : String = "%.3f" % global.endurance_time
	var seconds : int = total_time.substr(0, total_time.find(".")).to_int()
	var mill : int = total_time.substr(total_time.find(".") + 1, 3).to_int()
	var strMill = "%03d" % (mill)
	var strSeconds = "%02d" % (seconds % 60)
	var strMinutes = "%02d" % (seconds / 60)
	var strHours = "%02d" % (seconds / 3600)
	$Time/LabelTimer.text = strHours + " " + strMinutes + " " + strSeconds + " " + strMill

func _process(delta : float) -> void:
	global.endurance_time += delta
	update_endurance_timer()

func set_sfx_volume():
	for audio in $Sounds.get_children():
		audio.volume_db = global.STANDARD_VOLUME


func create_timer():
	# Label Timer
	label_timer.connect("timeout", self, "_on_timer_label_timeout", [], CONNECT_DEFERRED)
	label_timer.wait_time = 0.5
	label_timer.start()
	add_child(label_timer)
	
	# Game Timer
	game_timer.connect("timeout", self, "_on_game_label_timeout", [], CONNECT_DEFERRED)
	game_timer.wait_time = 0.3
	add_child(game_timer)
	update_timer()
	
	# Bonus to score timer
	bonus_timer.connect("timeout", self, "_on_bonus_timeout", [], CONNECT_DEFERRED)
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


func give_life() -> void:
	$Sounds/LiveEarned.play()
	for life in $Lives.get_children():
		if not life.visible:
			life.visible = true
			break


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


func set_time(game_time : int) -> void:
	time_left = game_time
	update_timer()

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
