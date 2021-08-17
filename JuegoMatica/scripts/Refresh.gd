extends Control


func _ready():
	if Global.exit_to_main_menu:
		$Timer.wait_time = 1.2
	$Timer.start()


func _on_Timer_timeout():
	var _scene_name := "Tutankamon"
	if Global.exit_to_main_menu:
		_scene_name = "MainMenu"

	Global.change_scene(_scene_name)
