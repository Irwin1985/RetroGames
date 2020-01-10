extends Area2D
export (int) var speed = 200

func _process(delta):
	position += speed * delta

