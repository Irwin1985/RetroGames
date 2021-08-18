extends Control

signal resume_game


func _ready() -> void:
	set_process(false)


func set_respuesta(result:float)->void:
	$Resultado.text = str(result)
	visible = true
	set_process(true)


func _process(delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
		self.visible = false
		emit_signal("resume_game")
		set_process(false)
