extends StaticBody2D

const STOMP_JUMP = -250
onready var bounce_timer: Timer = Timer.new()
onready var PlayerRef: KinematicBody2D = null
var can_change_player_animation := false
var player_animation := ""
var detect_collision := true

func _ready():
	bounce_timer.wait_time = 0.2
	bounce_timer.connect("timeout", self, "_on_bounce_timer_timeout")
	add_child(bounce_timer)


func _process(delta):
	if can_change_player_animation:
		if PlayerRef != null and !player_animation.empty():
			PlayerRef.get_node("Charlie").animation = player_animation


func _on_Area2D_body_entered(body):
	if body.name == global.PLAYER_NAME and not body.hit and detect_collision:
		$PlayerHurt.get_node("CollisionShape2D").disabled = true
		$RampSound.play()
		for anim in get_children():
			if anim.is_in_group("animation"):
				anim.frame = 0
				anim.play("bounce")
		body.show_BonusLabel(100)
		PlayerRef = body
		player_animation = "bounce" if global.rand_bool() else "jump"
		can_change_player_animation = true
		bounce_timer.start()
		body.motion.y = STOMP_JUMP


func _on_Area2D_body_exited(body):
	if body.name == global.PLAYER_NAME:
		body.get_node("Charlie").animation = "jump"


func _on_PlayerHurt_body_entered(body):
	if body.name == global.PLAYER_NAME:
		detect_collision = false
		body.hit_and_fall()


func _on_bounce_timer_timeout():
	bounce_timer.stop()
	can_change_player_animation = false

func _on_PlayerDown_body_entered(body):
	if body.name == global.PLAYER_NAME and not body.hit and detect_collision:
		body.hit_and_fall()

func _on_VisibilityNotifier2D_screen_exited():
	call_deferred("queue_free")
