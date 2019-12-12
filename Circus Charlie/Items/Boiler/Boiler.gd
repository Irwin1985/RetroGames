extends Area2D

signal hurt
signal pickup
signal score

var can_hide = false
var is_bonus = false
var bonus_counter = 0
var bonus_total = 0
var can_pickup = false

const STANDARD_POINT = 200
const BONUS_POINT = 5000

onready var visibility = VisibilityNotifier2D.new()


func _ready():
	set_sfx_volume()
	visibility.connect("screen_exited", self, "_on_visibility_screen_exited")	
	add_child(visibility)
	$CoinSprite.visible = false
	$ControlBonus/LabelBonus.hide()


func set_sfx_volume():
	$CoinPickupSound.volume_db = global.STANDARD_VOLUME
	$CoinShowSound.volume_db = global.STANDARD_VOLUME


func stop():
	$AnimatedSprite.stop()


func put_bonus(count):
	is_bonus = true	
	bonus_total = count


func cancel_bonus():
	is_bonus = false
	can_pickup = false
	bonus_total = 0
	bonus_counter = 0
	$CoinSprite.visible = false
	$CoinSprite/CoinArea2D/CollisionShape2D.disabled = true
	$ControlBonus/LabelBonus.hide()


func _on_visibility_screen_exited():
	if can_hide:
		queue_free()


func _on_Boiler_body_entered(body):
	emit_signal("hurt")


func _on_AreaNotifier_body_entered(body):
	if is_bonus:
		bonus_counter += 1
		if bonus_counter >= bonus_total:
			can_pickup = true
			is_bonus = false
			yield(get_tree().create_timer(0.5), "timeout")
			$CoinShowSound.play()
			$CoinSprite.visible = true
			$AnimationPlayer.play("coin")
			
	if body.name == "Lion":
		if !can_hide:
			global.check_point += 1
		emit_signal("score", 200)
		can_hide = true


func _on_CoinArea2D_body_entered(body):
	if body.name == "Lion" and can_pickup:
		$ControlBonus.rect_position.y = $CoinSprite.position.y
		cancel_bonus()
		$ControlBonus/LabelBonus.show()
		$AnimationPlayer.stop()
		$CoinPickupSound.play()
		$AnimationPlayer.play("bonus")
		emit_signal("pickup", 5000)


func _on_AnimationPlayer_animation_finished(anim_name):
	cancel_bonus()