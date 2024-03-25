extends Control
class_name Powerup
signal update_ui

func set_button_text(button : Button, powerup_name : String, price : float) -> void:
	var string_price = short(price)
	button.text = powerup_name + "\nBlood: " + string_price

func increase_price(base_cost : float, cost_multiplier : float, powerup_level : int) -> float:
	return base_cost * pow(cost_multiplier, powerup_level)

func short(value: float) -> String:
	var units: Array = ["", "K", "M", "B", "T"]
	var unit_index: int = 0
	while value >= 1000 and unit_index < units.size() - 1:
		unit_index += 1
		value /= 1000.0
	return "%.1f%s" % [value, units[unit_index]]

func spawn_text(phrase: String) -> void:
	var floating_text_scene : PackedScene = preload("res://scenes/effects/floatingtext.tscn")
	var text_effect := floating_text_scene.instantiate()
	text_effect.passed_text = phrase
	add_child(text_effect)
