extends Node
class_name MonkeyRules

const LEVEL_1 = "level1"
const LEVEL_2 = "level2"
const LEVEL_3 = "level3"
const LEVEL_4 = "level4"

var current_monkey_index = 0
var monkey_index: Dictionary = {
	"level1": {"9": 1},
	"level2": {"1": 1, "3": 1, "7": 2, "13": 1, "15": 1},
	"level3": {"0": 2, "4": 1, "7": 2, "11": 2, "15": 1},
	"level4": {"0": 2, "2": 2, "5": 1, "7": 2, "9": 2}
}

func get_total_monkey_by_level(level: String) -> int:
	var total_monkeys = 0
	for key in monkey_index[level]:
		if current_monkey_index == int(key):
			total_monkeys = monkey_index[level][key]
	return total_monkeys


func update_cyan_monkey() -> int:
	if current_monkey_index < 0:
		return 0
	var total_cyan_monkeys = 0
	match global.level_difficulty:
		global.LEVEL_1:
			total_cyan_monkeys = get_total_monkey_by_level(LEVEL_1)
		global.LEVEL_2:
			total_cyan_monkeys = get_total_monkey_by_level(LEVEL_2)
		global.LEVEL_3:
			total_cyan_monkeys = get_total_monkey_by_level(LEVEL_3)
		global.LEVEL_4:
			total_cyan_monkeys = get_total_monkey_by_level(LEVEL_4)
		_:
			total_cyan_monkeys = get_total_monkey_by_level(LEVEL_4)
	return total_cyan_monkeys
