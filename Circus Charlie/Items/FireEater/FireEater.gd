extends Node2D

onready var wait_timer : Timer = Timer.new()
onready var state_machine = $AnimationTree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready():
	wait_timer.connect("timeout", self, "spit_fire")
	wait_timer.wait_time = randf() * 1.75 + .75
	wait_timer.start()
	add_child(wait_timer)

func spit_fire()->void:
	wait_timer.wait_time = randf() * 1.75 + .75
	state_machine.travel("Fire Spitting")
	yield(get_tree().create_timer(0.2),"timeout")
	var new_fire : Area2D = $Fire.duplicate()
	new_fire.get_node("AnimationPlayer").play("Fire")
	add_child(new_fire)
	yield(get_tree().create_timer(1.1),"timeout")
	new_fire.call_deferred("queue_free")
#	$Fire/AnimationPlayer.play("Fire")
