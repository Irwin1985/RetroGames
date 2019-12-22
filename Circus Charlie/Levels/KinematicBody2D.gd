extends KinematicBody2D

var speed : Vector2 = Vector2.ZERO
var gravity = 10

func _physics_process(delta: float)->void:
	speed.y += gravity * delta * 60
	speed = move_and_slide(speed, Vector2.UP)

func bounce_trampoline(trampoline : BigTrampoline, bounciness: float, bounce_in_center : bool = true)->void:
	if Input.is_action_pressed("game_left"):
		speed = Vector2(-200, -265)
		trampoline.reset_bounces()
		$AnimationPlayer.seek(1)
		$AnimationPlayer.play_backwards("spin jump")
	elif Input.is_action_pressed("game_right"):
		speed = Vector2(200, -265)
		trampoline.reset_bounces()
		$AnimationPlayer.seek(0)
		$AnimationPlayer.play("spin jump")
	else:
		speed = Vector2(0, -bounciness)
		$AnimationPlayer.play("jump")
	if bounce_in_center:
		var center_vector : Vector2 = Vector2(trampoline.get_bounce_center().x - position.x, 0) 
		move_local_x(center_vector.x)

func hurt()->void:
	speed = Vector2.ZERO
	$HurtSound.play()
	$AnimationPlayer.play("hurt")