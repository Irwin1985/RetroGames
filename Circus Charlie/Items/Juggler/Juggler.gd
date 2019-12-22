extends Node2D

onready var wait_timer : Timer = Timer.new()
onready var state_machine = $AnimationTree.get("parameters/playback")

func _ready():
	wait_timer.connect("timeout", self, "juggle_throw")
	wait_timer.wait_time = randf() * 2.75 + 1
	wait_timer.start()
	add_child(wait_timer)

func juggle_throw()->void:
	wait_timer.wait_time = randf() * 1.75 + .75
	state_machine.travel("juggle throw")
	yield(get_tree().create_timer(0.05),"timeout")
	var new_knife : Area2D = $Knife.duplicate()
	new_knife.get_node("AnimationPlayer").play("juggle")
	add_child(new_knife)
	yield(get_tree().create_timer(1.9),"timeout")
	state_machine.travel("juggle catch")
	yield(get_tree().create_timer(0.2),"timeout")
	new_knife.call_deferred("queue_free")