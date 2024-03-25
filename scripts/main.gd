extends Control

@onready var kill_counter: Label = $BackgroundColor/TopBar/Panel/MarginContainer/HBoxContainer/ScoreBox/KillCounter
@onready var blood_counter: Label = $BackgroundColor/TopBar/Panel/MarginContainer/HBoxContainer/BloodBox/BloodCounter
@onready var clock: Label = $BackgroundColor/Clock
@onready var hired_goons: Control = $BackgroundColor/Shop/HiredGoons
@onready var bigger_knives: Control = $BackgroundColor/Shop/BiggerKnives
@onready var blood_press: Control = $BackgroundColor/Shop/BloodPress
@onready var blood_farm: Control = $BackgroundColor/Shop/BloodFarm
@onready var anim_sprite: AnimatedSprite2D = $BackgroundColor/Planet/AnimSprite
@onready var playtime: Label = $BackgroundColor/Playtime
@onready var blood_spurter: CPUParticles2D = $BackgroundColor/MurderButton/BloodSpurter

var blood_spurter_scene: PackedScene = preload("res://scenes/effects/blood_spurter.tscn")
var save_path = "user://score.save"

func _ready() -> void:
	load_score()

	if GameManager.first_play == null or GameManager.first_play == 0:
		GameManager.first_play = Time.get_unix_time_from_system()

func update_ui() -> void:
	kill_counter.text = str(short(round(GameManager.total_score)))
	blood_counter.text = str(short(round(GameManager.total_blood)))
	update_planet()
	playtime.text = seconds_to_human_readable(check_playtime())
	check_for_win()

func save_score():
	var data = {
		"total_score": GameManager.total_score,
		"base_click": GameManager.base_click,
		"click_multiplier": GameManager.click_multiplier,
		"passive_score": GameManager.passive_score,
		"passive_multiplier": GameManager.passive_multiplier,
		"total_blood": GameManager.total_blood,
		"blood_base_click": GameManager.blood_base_click,
		"blood_click_multiplier": GameManager.blood_click_multiplier,
		"blood_passive_score": GameManager.blood_passive_score,
		"blood_passive_multiplier": GameManager.blood_passive_multiplier,
		"hired_goons_level": hired_goons.powerup_level,
		"hired_goons_price": hired_goons.price,
		"bigger_knives_level": bigger_knives.powerup_level,
		"bigger_knives_price": bigger_knives.price,
		"blood_press_level": blood_press.powerup_level,
		"blood_press_price": blood_press.price,
		"blood_farm_level": blood_farm.powerup_level,
		"blood_farm_price": blood_farm.price,
		"first_play": GameManager.first_play,
		"timestamp": Time.get_unix_time_from_system(),
	}

	var file = FileAccess.open(save_path, FileAccess.ModeFlags.WRITE)
	if file:
		file.store_var(data)
		file.close()
	else:
		print("Failed to open file for writing.")

func load_score():
	var file = FileAccess.open(save_path, FileAccess.ModeFlags.READ)
	if file:
		var data = file.get_var()
		file.close()

		# Load general game data
		GameManager.total_score = data["total_score"]
		GameManager.base_click = data["base_click"]
		GameManager.click_multiplier = data["click_multiplier"]
		GameManager.passive_score = data["passive_score"]
		GameManager.passive_multiplier = data["passive_multiplier"]
		GameManager.total_blood = data["total_blood"]
		GameManager.blood_base_click = data["blood_base_click"]
		GameManager.blood_click_multiplier = data["blood_click_multiplier"]
		GameManager.blood_passive_score = data["blood_passive_score"]
		GameManager.blood_passive_multiplier = data["blood_passive_multiplier"]
		GameManager.first_play = data["first_play"]

		# Load timestamp and calculate offline progress
		var current_time = Time.get_unix_time_from_system()
		var last_time = data.get("timestamp", current_time)
		var seconds_away = current_time - last_time
		simulate_offline_progress(seconds_away)

		# Load power-up levels and prices
		hired_goons.powerup_level = floor(data.get("hired_goons_level"))
		hired_goons.price = floor(data.get("hired_goons_price"))
		bigger_knives.powerup_level = floor(data.get("bigger_knives_level"))
		bigger_knives.price = floor(data.get("bigger_knives_price"))
		blood_press.powerup_level = floor(data.get("blood_press_level"))
		blood_press.price = floor(data.get("blood_press_price"))
		blood_farm.powerup_level = floor(data.get("blood_farm_level"))
		blood_farm.price = floor(data.get("blood_farm_price"))

		# Update the UI or other game elements as necessary
		update_ui()
	else:
		print("Failed to open file for reading.")

func simulate_offline_progress(seconds : int) -> void:
	print("You were away from %f seconds" % seconds)
	GameManager.add_score((GameManager.base_click * GameManager.click_multiplier) * seconds)
	GameManager.add_blood((GameManager.blood_base_click * GameManager.blood_click_multiplier) * seconds)
	update_ui()

func short(value: float) -> String:
	var units: Array = ["", "K", "M", "B", "T"]
	var unit_index: int = 0
	while value >= 1000 and unit_index < units.size() - 1:
		unit_index += 1
		value /= 1000.0
	return "%.1f%s" % [value, units[unit_index]]

func play_click_effect() -> void:
	var spawn : Marker2D = $BackgroundColor/MurderButton/Marker2D
	var floating_text_scene : PackedScene = preload("res://scenes/effects/floatingtext.tscn")
	var text_effect := floating_text_scene.instantiate()
	text_effect.position = spawn.position
	spawn.add_child(text_effect)

func check_for_win(): #lol this will never run
	if GameManager.world_population - GameManager.total_score <= 0:
		$VictoryPanel.show()

func check_playtime() -> int:
	var now = Time.get_unix_time_from_system()
	var total_playtime = now - GameManager.first_play
	return int(total_playtime)

func seconds_to_human_readable(seconds: int) -> String:
	var days := seconds / 86400
	seconds %= 86400
	var hours := seconds / 3600
	seconds %= 3600
	var minutes := seconds / 60
	seconds %= 60

	var result: String = ""
	if days > 0:
		result += str(days) + "d "
	if hours > 0 or days > 0: # Include hours if there are any days
		result += str(hours) + "h "
	if minutes > 0 or hours > 0: # Include minutes if there are any hours
		result += str(minutes) + "m "
	if seconds > 0 or minutes > 0: # Include seconds if there are any minutes
		result += str(seconds) + "s"

	return result.strip_edges()


func randomized_hit_sound() -> void:
	var hitsound := $Sounds/Hit

	hitsound.pitch_scale = randf_range(0.6, .65)
	hitsound.play()


func update_planet() -> void: # makes the planet bloodier over time.
	if GameManager.total_score >= 1000000000:
		anim_sprite.play("rotate_lvl4")
	elif GameManager.total_score >= 100000000:
		anim_sprite.play("rotate_lvl3")
	elif GameManager.total_score >= 1000000:
		anim_sprite.play("rotate_lvl2")


func _on_tick() -> void:
	clock.text = Time.get_datetime_string_from_system(false, true).replace(" ", "\n")
	GameManager.add_score(GameManager.passive_score * GameManager.passive_multiplier)
	GameManager.add_blood(GameManager.blood_passive_score * GameManager.blood_passive_multiplier)
	update_ui()

func _on_murder_button_pressed() -> void:
	randomized_hit_sound()
	var new_blood_spurter = blood_spurter_scene.instantiate()
	add_child(new_blood_spurter)
	new_blood_spurter.global_position = blood_spurter.global_position # Adjust position as needed
	new_blood_spurter.emitting = true

	play_click_effect()
	GameManager.add_score(GameManager.base_click * GameManager.click_multiplier)
	GameManager.add_blood(GameManager.blood_base_click * GameManager.blood_click_multiplier)
	update_ui()
