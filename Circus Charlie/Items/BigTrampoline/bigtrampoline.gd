extends Trampoline
class_name BigTrampoline

signal bonus_pick

var give_points : bool = true
var bounce_count : int = 0
var checkpoint : int = 0


func put_bonus():
	$Bonus.set_visible(true)
	$Bonus/CollisionShape2D.set_disabled(false)


func put_checkpoint(distance : int)->void:
	checkpoint = distance


func bounce_player(body : PhysicsBody2D)->void:
	if body.name == "Player":
		if checkpoint != 0:
			global.set_checkpoint(checkpoint)
		if give_points:
			give_points = false
			global.give_points(20)
		var bounciness : float = 1100
		bounce_count += 1
		if bounce_count == 1:
			bounciness = 500
		elif bounce_count == 2:
			bounciness = 650
		elif bounce_count == 3:
			bounciness = 800
		body.bounce_big_trampoline(self, bounciness)
		$BounceSound.play()
		yield(get_tree().create_timer(0.5), "timeout")
	bounce_enabled = true


func reset_bounces()->void:
	bounce_count = 0


func _on_Bonus_body_entered(body):
	if body.name == "Player":
		print("Pick bonus")
		$Bonus.set_visible(false)
		$Bonus/CollisionShape2D.call_deferred("set_disabled", true)
		$Bonus/BonusSound.play()
		emit_signal("bonus_pick")