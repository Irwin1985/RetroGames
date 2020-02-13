extends Node2D

onready var juggle_timer: Timer = Timer.new()
onready var state_machine = $AnimationTree.get("parameters/playback")


func _ready() -> void:
	if juggle_timer.connect("timeout", self, "juggle_throw") != OK:
		print("Error connecting timeout of juggle_timer")
	juggle_timer.wait_time = randf() * 2.75 + 1
	juggle_timer.start()
	add_child(juggle_timer)


func juggle_throw() -> void:
	juggle_timer.wait_time = randf() * 2.75 + 1
	state_machine.travel("juggle throw")
	var new_knife: Area2D = $Knife.duplicate()
	new_knife.get_node("AnimationPlayer").play("juggle")
	$Knives.add_child(new_knife)
	yield(get_tree().create_timer(1.7),"timeout")
	state_machine.travel("juggle catch")
	yield(new_knife.get_node("AnimationPlayer"),"animation_finished")
	new_knife.call_deferred("queue_free")


func stop() -> void:
	juggle_timer.stop()
	$AnimationPlayer.stop()
	$AnimationTree.set_active(false)
	for knife in $Knives.get_children():
		knife.get_node("AnimationPlayer").stop()


func _on_Knife_area_entered(area : Area2D) -> void:
	if area.get_parent().name == global.PLAYER_NAME:
		area.get_parent().hit_and_fall()
