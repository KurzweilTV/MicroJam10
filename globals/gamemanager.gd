extends Node

var world_population : int = 10000000000

# kills variables
var total_score : float
var base_click : float = 1
var click_multiplier : float = 1
var passive_score : float = 0
var passive_multiplier : float = 1

# blood variables
var total_blood : float
var blood_base_click : float = 1
var blood_click_multiplier : float = 1
var blood_passive_score : float = 0
var blood_passive_multiplier : float = 1

func add_score(score: float) -> void:
	total_score += score

func add_blood(blood: float) -> void:
	total_blood += blood

func spend_blood(blood: float) -> void:
	print("Spending blood: %f" % blood)
	total_blood -= blood

func attempt_purchase(blood: float) -> bool:
	print("Total Blood: %f" % total_blood)
	print("Blood: %f" % blood)
	if total_blood >= blood:
		spend_blood(blood)
		return true
	else:
		return false
