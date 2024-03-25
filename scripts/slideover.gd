extends Control

signal reset_game

var save_path = "user://"
var save_file = "user://score.save"

# UI Backbone
@onready var timer: Timer = $Timer
@onready var open_button: Button = $OpenButton
@onready var close_button: Button = $CloseButton
@onready var open: AudioStreamPlayer2D = $Sounds/Open
@onready var close: AudioStreamPlayer2D = $Sounds/Close

# UI Elements
@onready var total_pop_number: Label = $MarginContainer/Background/MarginContainer/VBoxContainer/Population/TotalPopNumber
@onready var progress_bar: ProgressBar = $MarginContainer/Background/MarginContainer/VBoxContainer/ProgressBar
@onready var pk_amount: Label = $MarginContainer/Background/MarginContainer/VBoxContainer/Passive/PKAmount
@onready var pb_amount: Label = $MarginContainer/Background/MarginContainer/VBoxContainer/PassiveBlood/PBAmount
@onready var pc_amount: Label = $MarginContainer/Background/MarginContainer/VBoxContainer/PerClick/PCAmount
@onready var bpc_amount: Label = $MarginContainer/Background/MarginContainer/VBoxContainer/BloodPerClick/BPCAmount

func update_ui() -> void:
	total_pop_number.text = str(round(GameManager.world_population - GameManager.total_score))
	pk_amount.text = str(int(round(GameManager.passive_score * GameManager.passive_multiplier)))
	pb_amount.text = str(int(round(GameManager.blood_passive_score * GameManager.blood_passive_multiplier)))
	pc_amount.text = str(int(round(GameManager.base_click * GameManager.click_multiplier)))
	bpc_amount.text = str(int(round(GameManager.blood_base_click * GameManager.blood_click_multiplier)))
	progress_bar.update_progress()


func short(value: float) -> String:
	var units: Array = ["", "K", "M", "B", "T"]
	var unit_index: int = 0
	while value >= 1000 and unit_index < units.size() - 1:
		unit_index += 1
		value /= 1000.0
	return "%.1f%s" % [value, units[unit_index]]

func _on_open_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(0, position.y), 0.2)
	open.play()

func _on_close_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(640, position.y), 0.2)
	close.play()


func _on_reset_progress_pressed() -> void:
	$MarginContainer/Background/MarginContainer/VBoxContainer/HBoxContainer/ResetProgress.hide()
	$MarginContainer/Background/MarginContainer/VBoxContainer/HBoxContainer/ResetNo.show()
	$MarginContainer/Background/MarginContainer/VBoxContainer/HBoxContainer/ResetYes.show()

func _on_reset_no_pressed() -> void:
	$MarginContainer/Background/MarginContainer/VBoxContainer/HBoxContainer/ResetProgress.show()
	$MarginContainer/Background/MarginContainer/VBoxContainer/HBoxContainer/ResetNo.hide()
	$MarginContainer/Background/MarginContainer/VBoxContainer/HBoxContainer/ResetYes.hide()


func _on_reset_yes_pressed() -> void:
	var main_scene = (preload("res://scenes/main.tscn"))
	var savefile = DirAccess.open(save_path)
	GameManager.reset_game()
	$MarginContainer/Background/MarginContainer/VBoxContainer/HBoxContainer/ResetProgress.show()
	$MarginContainer/Background/MarginContainer/VBoxContainer/HBoxContainer/ResetNo.hide()
	$MarginContainer/Background/MarginContainer/VBoxContainer/HBoxContainer/ResetYes.hide()

	if savefile:
		print("Removing Save...")
		savefile.remove_absolute(save_file)
	reset_game.emit()
	_on_close_button_pressed()
	GameManager.first_play = Time.get_unix_time_from_system()
	$Sounds/clang.play()


