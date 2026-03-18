extends Control
## 事件场景 - Event Scene
## Displays story events with branching choices during map exploration.

const PARCHMENT := Color(0.95, 0.92, 0.85)
const INK_DARK := Color(0.15, 0.12, 0.1)
const INK_MED := Color(0.35, 0.30, 0.25)
const INK_LIGHT := Color(0.6, 0.55, 0.5)
const GOLD := Color(0.85, 0.7, 0.3)
const RED_SEAL := Color(0.8, 0.15, 0.1)
const JADE := Color(0.4, 0.65, 0.45)

var _event: Resource = null  # EventData
var _title_label: Label
var _desc_label: Label
var _result_label: Label
var _choice_buttons: Array[Button] = []
var _continue_btn: Button
var _choice_made: bool = false


func _ready() -> void:
	_build_ui()
	if _event == null:
		_load_random_event()
	_display_event()


func set_event(event_data: Resource) -> void:
	_event = event_data


func _draw() -> void:
	# Parchment scroll background
	draw_rect(Rect2(0, 0, 1280, 720), PARCHMENT)

	# Scroll border
	_draw_scroll_border()

	# Decorative ink elements
	_draw_ink_decorations()


func _draw_scroll_border() -> void:
	var margin := 40.0
	var outer := Rect2(margin, margin, 1280 - margin * 2, 720 - margin * 2)

	# Outer border
	draw_rect(outer, INK_DARK, false, 3.0)
	# Inner border
	draw_rect(Rect2(margin + 8, margin + 8, outer.size.x - 16, outer.size.y - 16), INK_LIGHT, false, 1.0)

	# Corner decorations (L-shapes)
	var corners := [
		Vector2(margin, margin),
		Vector2(1280 - margin, margin),
		Vector2(margin, 720 - margin),
		Vector2(1280 - margin, 720 - margin),
	]
	for corner in corners:
		draw_circle(corner, 5, INK_DARK)


func _draw_ink_decorations() -> void:
	# Subtle mountain silhouette at bottom
	var mtn_pts := PackedVector2Array([
		Vector2(50, 680), Vector2(150, 620), Vector2(250, 650),
		Vector2(350, 600), Vector2(450, 640), Vector2(500, 680),
	])
	draw_polyline(mtn_pts, Color(INK_LIGHT, 0.3), 1.5)

	# Cloud wisps at top
	for i in range(3):
		var cx := 200.0 + i * 350.0
		var cy := 80.0 + sin(i * 1.5) * 20.0
		draw_arc(Vector2(cx, cy), 30, 0, PI, 16, Color(INK_LIGHT, 0.2), 1.0)
		draw_arc(Vector2(cx + 20, cy - 5), 20, 0, PI, 12, Color(INK_LIGHT, 0.15), 1.0)

	# Red seal in corner
	draw_rect(Rect2(1140, 600, 60, 60), RED_SEAL)
	draw_rect(Rect2(1144, 604, 52, 52), Color(PARCHMENT, 0.3), false, 2.0)


func _build_ui() -> void:
	# Event title
	_title_label = Label.new()
	_title_label.position = Vector2(120, 80)
	_title_label.custom_minimum_size = Vector2(1040, 50)
	_title_label.add_theme_font_size_override("font_size", 28)
	_title_label.add_theme_color_override("font_color", INK_DARK)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_title_label)

	# Event description
	_desc_label = Label.new()
	_desc_label.position = Vector2(120, 150)
	_desc_label.custom_minimum_size = Vector2(1040, 120)
	_desc_label.add_theme_font_size_override("font_size", 18)
	_desc_label.add_theme_color_override("font_color", INK_MED)
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_desc_label)

	# Result label (shown after choice)
	_result_label = Label.new()
	_result_label.position = Vector2(120, 480)
	_result_label.custom_minimum_size = Vector2(1040, 80)
	_result_label.add_theme_font_size_override("font_size", 18)
	_result_label.add_theme_color_override("font_color", JADE)
	_result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.visible = false
	add_child(_result_label)

	# Continue button (shown after choice)
	_continue_btn = Button.new()
	_continue_btn.text = Locale.tr("Continue Voyage", "继续航行")
	_continue_btn.position = Vector2(490, 620)
	_continue_btn.custom_minimum_size = Vector2(300, 50)
	_continue_btn.add_theme_font_size_override("font_size", 18)
	_continue_btn.visible = false
	_continue_btn.pressed.connect(_on_continue)
	add_child(_continue_btn)


func _load_random_event() -> void:
	_event = EventDatabase.get_random_event(GameState.rng, GameState.current_act)


func _display_event() -> void:
	if _event == null:
		_title_label.text = Locale.tr("Calm Seas", "平静的海面")
		_desc_label.text = Locale.tr("All is calm at sea.", "一切风平浪静。")
		_show_continue()
		return

	_title_label.text = Locale.pick(_event.event_name, _event.event_name_zh)
	_desc_label.text = Locale.pick(_event.description, _event.description_zh)

	# Create choice buttons
	_create_choice_buttons()


func _create_choice_buttons() -> void:
	for btn in _choice_buttons:
		btn.queue_free()
	_choice_buttons.clear()

	if _event == null:
		return

	var choices: Array = _event.choices
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]

		# Check requirements
		var meets_requirements := _check_requirements(choice.get("requirements", {}))

		var btn := Button.new()
		var choice_text: String = Locale.pick(choice.get("text", ""), choice.get("text_zh", ""))
		var effect_hint := _get_effect_hint(choice.get("effects", []))
		btn.text = "[%s] %s %s" % [chr(65 + i), choice_text, effect_hint]
		btn.position = Vector2(200, 300 + i * 55)
		btn.custom_minimum_size = Vector2(880, 48)
		btn.add_theme_font_size_override("font_size", 15)
		btn.disabled = not meets_requirements
		btn.pressed.connect(_on_choice_made.bind(i))
		add_child(btn)
		_choice_buttons.append(btn)


func _check_requirements(reqs: Dictionary) -> bool:
	if reqs.is_empty():
		return true
	if reqs.has("gold_min") and GameState.player_gold < reqs.gold_min:
		return false
	if reqs.has("relic") and not GameState.has_relic(reqs.relic):
		return false
	if reqs.has("diplomacy_level"):
		# Check if any current act nation meets the level
		var met := false
		for nation_id in range(8):
			if GameState.get_diplomacy_level(nation_id) >= reqs.diplomacy_level:
				met = true
				break
		if not met:
			return false
	return true


func _get_effect_hint(effects: Array) -> String:
	var hints := []
	for effect in effects:
		var eff: Dictionary = effect
		match eff.get("type", ""):
			"heal":
				hints.append("+%dHP" % eff.value)
			"damage":
				hints.append("-%dHP" % eff.value)
			"gold":
				if eff.value > 0:
					hints.append("+%d%s" % [eff.value, Locale.tr("G", "金")])
				else:
					hints.append("%d%s" % [eff.value, Locale.tr("G", "金")])
			"diplomacy":
				hints.append("+%d%s" % [eff.value, Locale.tr("Dipl", "外交")])
			"card":
				hints.append("+%s" % Locale.tr("Card", "卡牌"))
			"relic":
				hints.append("+%s" % Locale.tr("Relic", "遗物"))
	if hints.is_empty():
		return ""
	return "(%s)" % ", ".join(hints)


func _on_choice_made(choice_index: int) -> void:
	if _choice_made or _event == null:
		return
	_choice_made = true

	var choice: Dictionary = _event.choices[choice_index]

	# Apply effects
	_apply_effects(choice.get("effects", []))

	# Show result
	_result_label.text = Locale.pick(
		choice.get("result_text", "Choice made."),
		choice.get("result_text_zh", "选择已做出。")
	)
	_result_label.visible = true

	# Disable choice buttons
	for btn in _choice_buttons:
		btn.disabled = true

	# Emit signals
	EventBus.event_choice_made.emit(_event.id, choice_index)

	_show_continue()


func _apply_effects(effects: Array) -> void:
	for effect in effects:
		var eff: Dictionary = effect
		match eff.get("type", ""):
			"heal":
				GameState.modify_hp(eff.get("value", 0))
			"damage":
				GameState.modify_hp(-eff.get("value", 0))
			"gold":
				GameState.modify_gold(eff.get("value", 0))
			"diplomacy":
				var nation: int = eff.get("nation", _get_primary_nation())
				GameState.add_diplomacy_points(nation, eff.get("value", 0))
			"card":
				# Add card to deck
				var card_id: String = eff.get("card_id", "")
				if card_id != "":
					var card := CardDatabase.get_card(card_id)
					if card:
						GameState.player_deck.append((card as CardData).duplicate_card())
			"relic":
				var relic_id: String = eff.get("relic_id", "")
				if relic_id != "":
					GameState.add_relic(relic_id)
			"remove_card":
				# Remove a random card of given type from deck
				if GameState.player_deck.size() > 5:
					var idx := GameState.rng.randi_range(0, GameState.player_deck.size() - 1)
					GameState.player_deck.remove_at(idx)
			"combat":
				# Queue a combat encounter
				pass  # Handled by map scene
			"max_hp":
				GameState.player_max_hp += eff.get("value", 0)
				GameState.player_hp = mini(GameState.player_hp, GameState.player_max_hp)
			"upgrade_random_card":
				pass  # Card upgrade not implemented yet


func _get_primary_nation() -> int:
	# Get the first nation for the current act
	match GameState.current_act:
		1:
			return 0  # CHAMPA
		2:
			return 4  # CALICUT
		3:
			return 5  # HORMUZ
		_:
			return 0


func _show_continue() -> void:
	_continue_btn.visible = true


func _on_continue() -> void:
	EventBus.event_completed.emit(_event.id if _event else "none")
	# Return to map
	get_tree().change_scene_to_file("res://scenes/map/map_scene.tscn")
