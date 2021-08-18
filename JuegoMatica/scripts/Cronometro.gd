extends Control

signal times_up

enum {
	NUMERO_0,
	NUMERO_1,
	NUMERO_2,
	NUMERO_3,
	NUMERO_4,
	NUMERO_5,
	NUMERO_6,
	NUMERO_7,
	NUMERO_8,
	NUMERO_9,
}

var _numeros := [
	"res://assets/piramide_numero_0.png",
	"res://assets/piramide_numero_1.png",
	"res://assets/piramide_numero_2.png",
	"res://assets/piramide_numero_3.png",
	"res://assets/piramide_numero_4.png",
	"res://assets/piramide_numero_5.png",
	"res://assets/piramide_numero_6.png",
	"res://assets/piramide_numero_7.png",
	"res://assets/piramide_numero_8.png",
	"res://assets/piramide_numero_9.png",
]
var _time := 0


func _ready() -> void:
	$Timer.stop()


func count_down(from:int)->void:
	_time = from
	_update_display()
	$Timer.start()


func _on_Timer_timeout():
	_time -= 1
	_update_display()

	if _time <= 0:
		emit_signal("times_up")


func _update_display()->void:
	var _array := _time_to_array()
	$Minuto.texture = load(_numeros[_array[0]])
	$Segundo.texture = load(_numeros[_array[1]])


func _time_to_array()->Array:
	var _left := 0
	var _right := 0

	if _time > 0:
		if len(str(_time)) == 1:
			_right = str(_time).left(1).to_int()-1
		else:
			_left = str(_time).left(1).to_int()-1
			_right = str(_time).right(1).to_int()-1
		
	return [_left, _right]


func pause()->void:
	$Timer.stop()
