extends Control
## 航海地图 - Voyage Map Scene
## Manages the map view where the player selects their next destination.
## Generates the map on entry, renders it via MapRenderer, and handles node selection.

var _map_renderer: Control  # MapRenderer instance
var _act_label: Label
var _info_label: Label
var _map_generated: bool = false


func _ready() -> void:
	# Create the MapRenderer
	_map_renderer = Control.new()
	_map_renderer.set_script(preload("res://scripts/map/map_renderer.gd"))
	_map_renderer.position = Vector2.ZERO
	_map_renderer.size = Vector2(1280, 720)
	_map_renderer.node_selected.connect(_on_node_selected)
	add_child(_map_renderer)

	# Act label at top
	_act_label = Label.new()
	_act_label.position = Vector2(20, 10)
	_act_label.add_theme_font_size_override("font_size", 22)
	_act_label.add_theme_color_override("font_color", Color(0.15, 0.12, 0.1))
	add_child(_act_label)

	# Info label at bottom
	_info_label = Label.new()
	_info_label.position = Vector2(20, 680)
	_info_label.custom_minimum_size = Vector2(600, 30)
	_info_label.add_theme_font_size_override("font_size", 14)
	_info_label.add_theme_color_override("font_color", Color(0.4, 0.38, 0.35))
	add_child(_info_label)

	# Generate or restore map
	if GameState.current_map.is_empty():
		_generate_map()
	else:
		_restore_map()


func _generate_map() -> void:
	var generator := MapGenerator.new()
	var map_data: Dictionary = generator.generate(GameState.rng, GameState.current_act)
	GameState.current_map = map_data
	_map_renderer.set_map(map_data)

	# Find and set start nodes as available
	if map_data.has("nodes"):
		for node in map_data["nodes"]:
			if node.type == MapData.NodeType.START:
				node.available = true

	_map_generated = true
	_update_labels()
	EventBus.map_generated.emit(GameState.current_act)


func _restore_map() -> void:
	_map_renderer.set_map(GameState.current_map)
	if GameState.current_node_id >= 0:
		_map_renderer.move_to_node(GameState.current_node_id)
	else:
		# Mark start nodes available
		if GameState.current_map.has("nodes"):
			for node in GameState.current_map["nodes"]:
				if node.type == MapData.NodeType.START:
					node.available = true
	_map_generated = true
	_update_labels()


func _update_labels() -> void:
	var act_names_en := ["", "Southeast Asia", "Indian Ocean", "Middle East & Africa"]
	var act_names_zh := ["", "南洋", "印度洋", "中东与非洲"]
	var act_idx := clampi(GameState.current_act, 1, 3)
	var act_name: String = Locale.t(act_names_en[act_idx], act_names_zh[act_idx])
	_act_label.text = Locale.t(
		"Act %d: %s" % [GameState.current_act, act_name],
		"第%d幕: %s" % [GameState.current_act, act_name]
	)
	_info_label.text = Locale.t(
		"HP: %d/%d  |  Gold: %d  |  Relics: %d  |  Deck: %d" % [GameState.player_hp, GameState.player_max_hp, GameState.player_gold, GameState.player_relics.size(), GameState.player_deck.size()],
		"HP: %d/%d  |  金: %d  |  遗物: %d  |  牌组: %d" % [GameState.player_hp, GameState.player_max_hp, GameState.player_gold, GameState.player_relics.size(), GameState.player_deck.size()]
	)


func _on_node_selected(node_id: int) -> void:
	if not GameState.current_map.has("nodes"):
		return

	# Find the node
	var selected_node: MapData.MapNode = null
	for node in GameState.current_map["nodes"]:
		if node.id == node_id:
			selected_node = node
			break

	if selected_node == null:
		return

	# Update map state
	GameState.current_node_id = node_id
	_map_renderer.move_to_node(node_id)

	# Emit signal
	EventBus.map_node_selected.emit(node_id, selected_node.type)

	# Navigate to appropriate scene
	match selected_node.type:
		MapData.NodeType.COMBAT, MapData.NodeType.ELITE:
			get_tree().change_scene_to_file("res://scenes/combat/combat_scene.tscn")
		MapData.NodeType.BOSS:
			get_tree().change_scene_to_file("res://scenes/combat/combat_scene.tscn")
		MapData.NodeType.EVENT:
			get_tree().change_scene_to_file("res://scenes/event/event_scene.tscn")
		MapData.NodeType.REST:
			_handle_rest()
		MapData.NodeType.SHOP:
			_info_label.text = Locale.t("Shop not yet implemented", "商店尚未实装")
		MapData.NodeType.TREASURE:
			_handle_treasure()
		_:
			_info_label.text = Locale.t("Select next destination", "选择下一个目的地")


func _handle_rest() -> void:
	var heal_amount := int(GameState.player_max_hp * 0.3)
	GameState.modify_hp(heal_amount)
	EventBus.rest_heal.emit(heal_amount)
	_info_label.text = Locale.t("Rested and recovered %d HP" % heal_amount, "休整完毕，恢复了 %d HP" % heal_amount)
	_update_labels()


func _handle_treasure() -> void:
	var gold_reward := GameState.rng.randi_range(20, 50)
	GameState.modify_gold(gold_reward)
	_info_label.text = Locale.t("Found treasure! +%d Gold" % gold_reward, "发现宝箱！获得 %d 金" % gold_reward)
	_update_labels()
