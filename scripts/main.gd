extends Control

@onready var kill_counter: Label = $TopBar/Panel/MarginContainer/HBoxContainer/ScoreBox/KillCounter
@onready var blood_counter: Label = $TopBar/Panel/MarginContainer/HBoxContainer/BloodBox/BloodCounter
@onready var clock: Label = $Clock

# system variables
var current_time : Dictionary

func _ready() -> void:
	pass

func update_ui() -> void:
	kill_counter.text = str(round(GameManager.total_score))
	blood_counter.text = str(round(GameManager.total_blood))

func _on_tick() -> void:
	clock.text = Time.get_datetime_string_from_system(false, true).replace(" ", "\n")
	GameManager.add_score(GameManager.passive_score)
	GameManager.add_blood(GameManager.blood_passive_score)
	update_ui()

func _on_murder_button_pressed() -> void:
	GameManager.add_score(GameManager.base_click * GameManager.click_multiplier)
	GameManager.add_blood(GameManager.blood_base_click * GameManager.blood_click_multiplier)
	update_ui()
