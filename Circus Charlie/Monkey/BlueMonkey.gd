extends KinematicBody2D

signal player_detected
signal player_bonus

export (int) var gravity_power = 40
export (int) var jump_power = 500
export (int) var speed = 200

var can_jump := false
var start_pos
var velocity = Vector2()


func _ready():
	$AnimatedSprite.speed_scale = 2
	$AnimatedSprite.animation = "run"
	start_pos = position.y


func _physics_process(delta):
	velocity.x = -speed
	if $JumpSensor.is_colliding():
		var collider = $JumpSensor.get_collider()
		if collider.name == "MonkeyBack":
			collider.get_parent().cyan_monkey_pause()
			$AnimatedSprite.animation = "jump"
			can_jump = true
			velocity.y = -jump_power

	if $PlayerSensor.is_colliding() and $MonkeySensor.is_colliding():
		if $PlayerSensor.get_collider().name == global.PLAYER_NAME:
			$PlayerSensor.enabled = false
			$MonkeySensor.enabled = false
			emit_signal("player_bonus")

	if can_jump:
		velocity.y += gravity_power * delta * 60
	velocity = move_and_slide(velocity, Vector2.UP)
	process_collide()
	if is_on_floor():
		can_jump = false
		velocity.y = start_pos
		$AnimatedSprite.animation = "run"


func process_collide():
	for slide_idx in range(get_slide_count()):
		var collider: KinematicCollision2D = get_slide_collision(slide_idx)
		if collider.collider.name == global.PLAYER_NAME:
			emit_signal("player_detected")
			collider.collider.hit_and_fall()
			$AnimatedSprite.stop()
			set_physics_process(false)


func _on_SensorTimer_timeout():
	call_deferred("queue_free")