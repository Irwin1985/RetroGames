extends Area2D

signal hurt
signal cyan_monkey_showed
signal screen_exited

const PLAYER_NAME = "Player"
const SPEED = 60
const RAYCAST_LENGTH = -180

var move = false
var playback_speed = 1 setget set_playback_speed
var show_cyan_monkey = false

func _ready():
	$AnimatedSprite.play()


func _process(delta):
	if move:
		position.x -= SPEED * delta
	else:
		$AnimatedSprite.stop()

	if $PlayerSensor.is_colliding():
		var collider = $PlayerSensor.get_collider()
		if collider.name == PLAYER_NAME and !show_cyan_monkey:
			show_cyan_monkey = true
			emit_signal("cyan_monkey_showed")


func enable_player_sensor():
	$PlayerSensor.cast_to = Vector2(RAYCAST_LENGTH, 0)
	$PlayerSensor.enabled = true


func set_playback_speed(new_speed):
	playback_speed = new_speed
	$AnimatedSprite.speed_scale = new_speed


func _on_VisibilityNotifier2D_screen_exited():	
	emit_signal("screen_exited", self)


func cyan_monkey_pause():
	move = false
	$AnimatedSprite.stop()
	$CyanMonkeyTimer.start()


func _on_CyanMonkeyTimer_timeout():
	$CyanMonkeyTimer.stop()
	$AnimatedSprite.frame = 2
	move = true
	$AnimatedSprite.play()





















