extends Trampoline
class_name BigTrampoline

var bounce_count : int = 0

func bounce_player(body : PhysicsBody2D)->void:
	if body.name == "Player":
		var bounciness : float = 900
		bounce_count += 1
		if bounce_count == 1:
			bounciness = 400
		elif bounce_count == 2:
			bounciness = 550
		elif bounce_count == 3:
			bounciness = 700
		body.bounce_big_trampoline(self, bounciness)
		$BounceSound.play()
		yield(get_tree().create_timer(0.5), "timeout")
	bounce_enabled = true
	
func put_bonus():
	$Bonus.set_visible(true)
	$Bonus/CollisionShape2D.set_disabled(false)

func reset_bounces()->void:
	bounce_count = 0

func _on_Bonus_body_entered(body):
	if body.name == "Player":
		print("Pick bonus")
		$Bonus.set_visible(false)
		$Bonus/CollisionShape2D.call_deferred("set_disabled", true)
