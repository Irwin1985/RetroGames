extends Area2D
export (int) var speed
signal hurt

var motion = Vector2.ZERO
var can_move_bonus = false


func _ready():
	$Control/Label.visible = false
	if $TimerMoveFlame.connect("timeout", self, "_on_TimerMoveFlame_timeout") != OK:
		print("Error connecting timeout of MoveFlame")
	if $TimerKillBonus.connect("timeout", self, "_on_TimerKillBonus_timeout") != OK:
		print("Error connecting timeout of KillBonus")


func _process(delta):
	position += motion * delta
	if can_move_bonus:
		$Control/Label.rect_position.x += 2


func bonus():
	global.give_points(1000)
	$Control/Label.visible = true
	can_move_bonus = true
	$BonusSound.play()
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


func _on_TimerKillBonus_timeout():
	$Control/Label.visible = false


func _on_Score_body_entered(body):
	global.give_points(100)


func _on_TimerMoveFlame_timeout():
	motion.x = -speed


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Bonus_body_entered(body):
	if body.name == "Lion":
		bonus()


func _on_BonusFlame_body_entered(body):
	if body.name == "Lion":
		emit_signal("hurt")