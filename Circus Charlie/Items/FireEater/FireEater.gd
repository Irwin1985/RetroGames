extends Node2D

onready var fire_timer: Timer = Timer.new()
onready var state_machine = $AnimationTree.get("parameters/playback")


func _ready():
	if fire_timer.connect("timeout", self, "spit_fire") != OK:
		print("Error connecting timeount of fire_timer")
	fire_timer.wait_time = randf() * 1.75 + .75
	fire_timer.start()
	add_child(fire_timer)


func spit_fire() -> void:
#	fire_timer.wait_time = randf() * 1.75 + .75
	fire_timer.wait_time = randi() % 3 + .75
	state_machine.travel("Fire Spitting")
	yield(get_tree().create_timer(0.2),"timeout")
	if fire_timer.is_stopped():
		return # Don't fire when stopped
	var new_fire : Area2D = $Fire.duplicate()
	new_fire.get_node("AnimationPlayer").play("Fire")
	$Flames.add_child(new_fire)
	yield(new_fire.get_node("AnimationPlayer"),"animation_finished")
	new_fire.call_deferred("queue_free")


func stop():
	fire_timer.stop()
	$AnimationPlayer.stop()
	$AnimationTree.set_active(false)
	for fire in $Flames.get_children():
		fire.get_node("AnimationPlayer").stop()


func _on_Fire_area_entered(area : Area2D) -> void:
	if area.get_parent().name == global.PLAYER_NAME:
		area.get_parent().hit_and_fall()
