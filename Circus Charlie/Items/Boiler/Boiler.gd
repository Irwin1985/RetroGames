extends Area2D

signal hurt
signal bonus

const STANDARD_POINT = 200
const BONUS_POINT = 5000

var can_hide = false
var bonus_counter = 0
var bonus_total = 0
var can_pickup = false
onready var visibility = VisibilityNotifier2D.new()


func _ready():
	set_sfx_volume()
	visibility.connect("screen_exited", self, "_on_visibility_screen_exited")	
	add_child(visibility)
	$CoinSprite.visible = false
	bonus_total = ( randi() % 10 + 1 ) * 2


func set_sfx_volume():
	$CoinShowSound.volume_db = global.STANDARD_VOLUME


func stop():
	$AnimatedSprite.stop()


func cancel_bonus():
	can_pickup = false
	$CoinSprite.visible = false
	$AnimationPlayer.seek(0, true)


func _on_visibility_screen_exited():
	if can_hide:
		queue_free()


# warning-ignore:unused_argument
func _on_Boiler_body_entered(body):
	emit_signal("hurt")


func _on_AreaNotifier_body_entered(body):
	bonus_counter += 1
	if bonus_counter >= bonus_total:
		call_deferred("activate_bonus")
	if body.name == global.LION_NAME:
		global.give_points(STANDARD_POINT)
		can_hide = true


func activate_bonus():
	bonus_counter = 0
	bonus_total = ( randi() % 20 + 1 ) * 2
	yield(get_tree().create_timer(0.5), "timeout")
	if not $AnimatedSprite.is_playing():
		return # Don't throw coin when stopped
	can_pickup = true
	$CoinShowSound.play()
	$AnimationPlayer.play("coin")
	$CoinSprite.visible = true


func _on_CoinArea2D_body_entered(body):
	if body.name == global.LION_NAME and can_pickup:
		cancel_bonus()
		emit_signal("bonus", BONUS_POINT)
		$AnimationPlayer.stop()
		$AnimationPlayer.play("bonus")
		global.give_points(BONUS_POINT)


# warning-ignore:unused_argument
func _on_AnimationPlayer_animation_finished(anim_name):
	cancel_bonus()