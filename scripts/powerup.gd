extends Control
class_name Powerup

func set_button_text(button : Button, powerup_name : String, price : float) -> void:
	button.text = powerup_name + "\nBlood:  " + str(int(price))

func increase_price(base_cost : float, cost_multiplier : float, powerup_level : int) -> float:
	return base_cost * pow(cost_multiplier, powerup_level)
