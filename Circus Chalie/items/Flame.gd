extends Area2D
export (int) var speed
signal hurt
signal bonus
signal score

var motion = Vector2.ZERO
var can_move_bnonus = false

func _ready():
	$Control/Label.visible = false
	$TimerMoveFlame.connect("timeout", self, "_on_TimerMoveFlame_timeout")
	$TimerKillBonus.connect("timeout", self, "_on_TimerKillBonus_timeout")
	
func play():
	$TimerMoveFlame.start()
	
func _process(delta):
	position += motion * delta
	if can_move_bnonus:
		$Control/Label.rect_position.x += 2
	
func _on_TimerMoveFlame_timeout():
	motion.x = -speed

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
func _on_Bonus_body_entered(body):
	if body.name == "Lion":
		bonus()

func bonus():
	emit_signal("bonus", 1000)
	$Control/Label.visible = true
	can_move_bnonus = true
	$BonusSound.play()
	$SpriteBonus.visible = false
	$TimerKillBonus.start()
	
func _on_BonusFlame_body_entered(body):
	if body.name == "Lion":
		emit_signal("hurt")

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
	emit_signal("score", 100)
