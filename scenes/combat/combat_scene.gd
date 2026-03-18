extends Control

var _combat_manager: CombatManager
var _hand_display: HandDisplay
var _player_hud: PlayerHUD
var _enemy_displays: Array[EnemyDisplay] = []
var _end_turn_button: Button
var _status_label: Label  # Shows messages like "You win!" / "You lose!"
var _target_hint_label: Label
var _enemy_container: HBoxContainer
var _background: ColorRect


func _ready() -> void:
	# Build the scene programmatically

	# Background - dark ocean blue
	_background = ColorRect.new()
	_background.color = Color(0.05, 0.12, 0.2)
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_background)

	# Title
	var title = Label.new()
	title.text = Locale.t("COMBAT", "战斗")
	title.position = Vector2(540, 5)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	add_child(title)

	# Enemy container (top area)
	_enemy_container = HBoxContainer.new()
	_enemy_container.position = Vector2(300, 50)
	_enemy_container.add_theme_constant_override("separation", 40)
	add_child(_enemy_container)

	# Player HUD (middle-left area)
	_player_hud = PlayerHUD.new()
	_player_hud.position = Vector2(20, 300)
	add_child(_player_hud)

	# Hand display (bottom area)
	_hand_display = HandDisplay.new()
	_hand_display.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_hand_display)
	_hand_display.card_selected.connect(_on_card_selected)

	# End turn button
	_end_turn_button = Button.new()
	_end_turn_button.text = Locale.t("End Turn", "结束回合")
	_end_turn_button.position = Vector2(1140, 400)
	_end_turn_button.custom_minimum_size = Vector2(120, 50)
	_end_turn_button.pressed.connect(_on_end_turn_pressed)
	add_child(_end_turn_button)

	# Status/message label
	_status_label = Label.new()
	_status_label.position = Vector2(450, 350)
	_status_label.add_theme_font_size_override("font_size", 28)
	_status_label.add_theme_color_override("font_color", Color(1, 1, 0.5))
	_status_label.visible = false
	add_child(_status_label)

	# Target selection hint
	_target_hint_label = Label.new()
	_target_hint_label.text = Locale.t("Select a target", "选择目标")
	_target_hint_label.position = Vector2(480, 280)
	_target_hint_label.add_theme_font_size_override("font_size", 16)
	_target_hint_label.add_theme_color_override("font_color", Color(1, 1, 0, 0.8))
	_target_hint_label.visible = false
	add_child(_target_hint_label)

	# Setup combat manager
	_combat_manager = CombatManager.new()
	add_child(_combat_manager)
	_combat_manager.combat_state_changed.connect(_refresh_ui)
	_combat_manager.combat_ended.connect(_on_combat_ended)
	_combat_manager.request_target_selection.connect(_on_request_target)

	# Start combat with act 1 normal enemies
	# Pick 1-2 random enemies for now
	var enemy_pool = ["pirate_skiff", "jellyfish_swarm"]
	var num_enemies = GameState.rng.randi_range(1, 2)
	var selected: Array = []
	for i in num_enemies:
		selected.append(enemy_pool[GameState.rng.randi() % enemy_pool.size()])
	_combat_manager.start_combat(selected)

	_create_enemy_displays()
	_refresh_ui()


func _create_enemy_displays():
	# Clear old
	for ed in _enemy_displays:
		ed.queue_free()
	_enemy_displays.clear()

	for i in _combat_manager.enemy_instances.size():
		var ed = EnemyDisplay.new()
		ed.setup(_combat_manager.enemy_instances[i], i)
		ed.enemy_clicked.connect(_on_enemy_clicked)
		_enemy_container.add_child(ed)
		_enemy_displays.append(ed)


func _refresh_ui():
	# Update hand
	_hand_display.update_hand(_combat_manager.get_hand())

	# Update player HUD
	_player_hud.update_hud(
		GameState.player_hp, GameState.player_max_hp,
		GameState.player_block,
		_combat_manager.get_energy(), _combat_manager.get_max_energy(),
		_combat_manager.get_draw_count(), _combat_manager.get_discard_count()
	)

	# Update enemy displays
	for ed in _enemy_displays:
		ed.update_display()

	# Update end turn button
	_end_turn_button.disabled = not (_combat_manager.turn_manager and _combat_manager.turn_manager.is_player_turn())


func _on_card_selected(card_data, _card_display):
	_combat_manager.attempt_play_card(card_data)


func _on_enemy_clicked(enemy_display: EnemyDisplay):
	if _combat_manager.is_awaiting_target():
		_target_hint_label.visible = false
		var enemy = enemy_display.get_enemy()
		if enemy and enemy.is_alive():
			_combat_manager.select_target(enemy)


func _on_request_target(_card_data):
	_target_hint_label.visible = true


func _on_end_turn_pressed():
	_target_hint_label.visible = false
	_combat_manager.cancel_target_selection()
	_combat_manager.end_turn()


func _on_combat_ended(won: bool):
	_status_label.visible = true
	_end_turn_button.disabled = true
	if won:
		_status_label.text = Locale.t("VICTORY!", "胜利！")
		_status_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
	else:
		_status_label.text = Locale.t("DEFEAT...", "失败...")
		_status_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))

	# After 2 seconds, transition
	await get_tree().create_timer(2.0).timeout
	if won:
		# For now, just go back to main menu
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _input(event):
	# Right click cancels target selection
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if _combat_manager.is_awaiting_target():
			_combat_manager.cancel_target_selection()
			_target_hint_label.visible = false
			_refresh_ui()


func _exit_tree():
	_combat_manager.cleanup()
