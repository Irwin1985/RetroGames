extends Area2D
class_name FlameRing

signal hurt
signal appear
signal disappear
signal bonus

export (int) var speed
const FLAME_POINTS = 100

var motion = Vector2.ZERO


func _ready():
	if $TimerMoveFlame.connect("timeout", self, "_on_TimerMoveFlame_timeout") != OK:
		print("Error connecting timeout of MoveFlame")


func _process(delta):
	position += motion * delta


func bonus():
	emit_signal("bonus", 500)
	global.give_points(1000)
	$SpriteBonus.visible = false
	$TimerKillBonus.start()


func play():
	$TimerMoveFlame.start()


func start(type):
	match type:
		"big":
			$AnimatedSpriteLeft.animation = "big_flame"
			$AnimatedSpriteRight.animation = "big_flame"
			$HurtCollision.position = Vector2(24, 156)
			$SpriteBonus.visible = false
			$Bonus/BonusCollision.disabled = true
		"bonus":
			$AnimatedSpriteLeft.animation = "bonus_flame"
			$AnimatedSpriteRight.animation = "bonus_flame"
			$HurtCollision.position = Vector2(24, 125)
			$SpriteBonus.visible = true
			$Bonus/BonusCollision.disabled = false


func stop():
	$AnimatedSpriteLeft.stop()
	$AnimatedSpriteRight.stop()


# warning-ignore:unused_argument
func _on_Score_body_entered(body):
	global.give_points(FLAME_POINTS)


func _on_TimerMoveFlame_timeout():
	motion.x = -speed


func _on_VisibilityNotifier2D_screen_entered():
	emit_signal("appear", self)


func _on_VisibilityNotifier2D_screen_exited():
#	queue_free()
	emit_signal("disappear", self)


func _on_Bonus_body_entered(body):
	if body.name == global.LION_NAME:
		bonus()


func _on_BonusFlame_body_entered(body):
	if body.name == global.LION_NAME:
		emit_signal("hurt")

