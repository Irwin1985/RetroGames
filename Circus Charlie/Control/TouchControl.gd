extends CanvasLayer

func _ready():
	$Controls/LeftControls.position.y = OS.get_window_size().y
	$Controls/CenterControls.position = OS.get_window_size()
	$Controls/CenterControls.position.x /=2
	$Controls/RightControls.position = OS.get_window_size()
