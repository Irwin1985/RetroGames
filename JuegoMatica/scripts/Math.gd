extends Node

class_name MathClass

"""
Algoritmo matemático: genera expresiones aritméticas de tipo
suma, resta, multiplicación y división.
También puede generar expresiones negativas.
"""

enum {
	ADD,
	SUB,
	MUL,
	DIV,
	NONE
}

const EXP_LEFT_OPERAND = 0
const EXP_RIGHT_OPERAND = 1
const MIN_RANGE = 0
const MAX_RANGE = 1


############################
#  5       +        2
# left  _operator  right
############################

var _operator
var _left_operand
var _right_operand
var _min_range
var _max_range

var negativos := false

"""
generate_expression: Genera una expresión aritmética.
	array_exp:  el índice 0 representa la base para el operador left.
				el índice 1 representa la base para el operador right.
	type: 		representa el tipo de operación (ver enum)
	list: 		una lista de expresiones ya generadas para no duplicar
"""
func generate_expression(array_exp:Array, type:int, list:Array)->void:
	var _negate_operand := false
	var _is_left_negated := false
	while true:
		# update left operand
		var op_range = _get_range(array_exp[EXP_LEFT_OPERAND])
		_left_operand = int(rand_range(op_range[MIN_RANGE], op_range[MAX_RANGE]))
		
		# update right operand
		op_range = _get_range(array_exp[EXP_RIGHT_OPERAND])	
		_right_operand = int(rand_range(op_range[MIN_RANGE], op_range[MAX_RANGE]))
		_operator = type

		if negativos:
			_negate_operand = _random_bool()
			if _negate_operand:
				if _random_bool():
					_left_operand *= -1
				else:
					_right_operand *= -1

		var _exp = to_string()
		if _exp in [list]:
			reset()
			continue
		else:
			break


func get_result():
	match _operator:
		ADD:
			return _left_operand + _right_operand
		SUB:
			return _left_operand - _right_operand
		MUL:
			return _left_operand * _right_operand
		DIV:
			return _left_operand / _right_operand


func reset():
	_left_operand = 0
	_right_operand = 0
	_operator = NONE
	

func to_string():
	return str(_left_operand) + _get__operator_str() + str(_right_operand)


func _get__operator_str():
	match _operator:
		ADD:
			return "+"
		SUB:
			return "-"
		MUL:
			return "x"
		DIV:
			return "%"
		_:
			return "!"


# devuelve el rango (min, max) de un número positivo
func _get_range(num):
	if num == 0:
		return

	if num == 1:
		_min_range = 1
		_max_range = 9
	else:
		_min_range = pow(10, num-1) # 2 => 10 pow (2-1) => 10
		_max_range = pow(10, num) - 1 # 2 => 100 - 1 = 99
	
	return [_min_range, _max_range]


func _random_bool()->bool:
	return randi() % 2 == 0
