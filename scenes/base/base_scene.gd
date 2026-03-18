extends Control
## 刘家港主基地 - Liujiagang Harbor Base
## Roguelike meta-progression hub between runs.
## Players return here after each voyage to upgrade, manage deck, and prepare.

const PARCHMENT := Color(0.95, 0.92, 0.85)
const INK_DARK := Color(0.15, 0.12, 0.1)
const INK_MED := Color(0.35, 0.30, 0.25)
const INK_LIGHT := Color(0.6, 0.55, 0.5)
const GOLD := Color(0.85, 0.7, 0.3)
const RED_SEAL := Color(0.8, 0.15, 0.1)
const JADE := Color(0.4, 0.65, 0.45)
const WOOD := Color(0.55, 0.38, 0.22)

# Meta-upgrade definitions
const META_UPGRADES := {
	"hull_upgrade": {
		name = "Hull Upgrade", name_zh = "船体加固",
		desc = "Start with +5 Max HP per level", desc_zh = "每级增加5点初始最大生命值",
		max_level = 5, base_cost = 20, cost_per_level = 15,
		icon = "hull",
	},
	"treasury": {
		name = "Imperial Treasury", name_zh = "国库拨款",
		desc = "Start with +15 Gold per level", desc_zh = "每级增加15初始金币",
		max_level = 5, base_cost = 15, cost_per_level = 10,
		icon = "gold",
	},
	"compass_mastery": {
		name = "Compass Mastery", name_zh = "罗盘精通",
		desc = "Start runs with the Compass relic", desc_zh = "开始时携带罗盘遗物",
		max_level = 1, base_cost = 50, cost_per_level = 0,
		icon = "compass",
	},
	"crew_training": {
		name = "Crew Training", name_zh = "水手训练",
		desc = "Draw 1 extra card on turn 1 per level", desc_zh = "每级在第一回合多抽1张牌",
		max_level = 3, base_cost = 30, cost_per_level = 25,
		icon = "crew",
	},
	"shipyard": {
		name = "Shipyard", name_zh = "船坞",
		desc = "Remove 1 card from starter deck per level", desc_zh = "每级从初始牌组移除1张牌",
		max_level = 3, base_cost = 40, cost_per_level = 30,
		icon = "ship",
	},
}

var _buttons: Array[Button] = []
var _info_label: Label
var _gold_label: Label
var _stats_label: Label


func _ready() -> void:
	_build_ui()
	EventBus.base_entered.emit()


func _draw() -> void:
	# Draw base background - harbor scene
	if is_instance_valid(InkWashRenderer):
		InkWashRenderer.draw_base_bg(self)
	else:
		_draw_fallback_bg()


func _draw_fallback_bg() -> void:
	# Parchment background
	draw_rect(Rect2(0, 0, 1280, 720), PARCHMENT)

	# Sky gradient
	for i in range(20):
		var t := float(i) / 20.0
		var sky_color := Color(0.75 + t * 0.15, 0.82 + t * 0.08, 0.88 + t * 0.02, 0.3)
		draw_rect(Rect2(0, i * 15, 1280, 15), sky_color)

	# Mountains
	var mountain_pts := PackedVector2Array([
		Vector2(0, 350), Vector2(100, 200), Vector2(200, 250),
		Vector2(350, 150), Vector2(500, 220), Vector2(650, 180),
		Vector2(800, 240), Vector2(950, 170), Vector2(1100, 230),
		Vector2(1280, 280), Vector2(1280, 350), Vector2(0, 350)
	])
	draw_polygon(mountain_pts, [Color(INK_LIGHT, 0.4)])

	# Water
	draw_rect(Rect2(0, 500, 1280, 220), Color(0.3, 0.45, 0.55, 0.3))

	# Dock
	draw_rect(Rect2(100, 480, 400, 20), WOOD)
	draw_rect(Rect2(100, 480, 10, 60), WOOD)
	draw_rect(Rect2(490, 480, 10, 60), WOOD)

	# Title banner
	draw_rect(Rect2(350, 20, 580, 60), Color(INK_DARK, 0.85))
	draw_rect(Rect2(352, 22, 576, 56), Color(PARCHMENT, 0.9))


func _build_ui() -> void:
	# Title
	var title := Label.new()
	title.text = "刘家港 · Liujiagang Harbor"
	title.position = Vector2(380, 28)
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", INK_DARK)
	add_child(title)

	# Gold display
	_gold_label = Label.new()
	_gold_label.position = Vector2(50, 100)
	_gold_label.add_theme_font_size_override("font_size", 20)
	_gold_label.add_theme_color_override("font_color", GOLD)
	add_child(_gold_label)
	_update_gold_display()

	# Stats display
	_stats_label = Label.new()
	_stats_label.position = Vector2(50, 130)
	_stats_label.add_theme_font_size_override("font_size", 14)
	_stats_label.add_theme_color_override("font_color", INK_MED)
	add_child(_stats_label)
	_update_stats_display()

	# Upgrade buttons - positioned in a grid
	var col := 0
	var row_idx := 0
	for upgrade_id in META_UPGRADES:
		var upgrade: Dictionary = META_UPGRADES[upgrade_id]
		var current_level: int = GameState.meta_upgrades.get(upgrade_id, 0)
		var max_level: int = upgrade.max_level
		var cost := _get_upgrade_cost(upgrade_id)
		var maxed := current_level >= max_level

		var btn := Button.new()
		var level_text := "MAX" if maxed else "Lv.%d" % current_level
		btn.text = "%s\n%s [%s]\n%s" % [upgrade.name_zh, upgrade.name, level_text, "" if maxed else "%d金" % cost]
		btn.position = Vector2(100 + col * 240, 200 + row_idx * 120)
		btn.custom_minimum_size = Vector2(220, 100)
		btn.add_theme_font_size_override("font_size", 14)
		btn.disabled = maxed or GameState.meta_gold < cost
		btn.pressed.connect(_on_upgrade_pressed.bind(upgrade_id))
		add_child(btn)
		_buttons.append(btn)

		col += 1
		if col >= 4:
			col = 0
			row_idx += 1

	# Info label for showing descriptions
	_info_label = Label.new()
	_info_label.position = Vector2(100, 550)
	_info_label.custom_minimum_size = Vector2(700, 60)
	_info_label.add_theme_font_size_override("font_size", 16)
	_info_label.add_theme_color_override("font_color", INK_MED)
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info_label.text = "选择一项升级以查看详情 / Select an upgrade to see details"
	add_child(_info_label)

	# Start Voyage button
	var start_btn := Button.new()
	start_btn.text = "出发远航 / Start Voyage"
	start_btn.position = Vector2(900, 580)
	start_btn.custom_minimum_size = Vector2(300, 70)
	start_btn.add_theme_font_size_override("font_size", 22)
	start_btn.pressed.connect(_on_start_voyage)
	add_child(start_btn)

	# Back to menu button
	var menu_btn := Button.new()
	menu_btn.text = "返回主菜单 / Main Menu"
	menu_btn.position = Vector2(900, 660)
	menu_btn.custom_minimum_size = Vector2(300, 40)
	menu_btn.add_theme_font_size_override("font_size", 14)
	menu_btn.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn"))
	add_child(menu_btn)


func _get_upgrade_cost(upgrade_id: String) -> int:
	var upgrade: Dictionary = META_UPGRADES[upgrade_id]
	var current_level: int = GameState.meta_upgrades.get(upgrade_id, 0)
	return upgrade.base_cost + current_level * upgrade.cost_per_level


func _on_upgrade_pressed(upgrade_id: String) -> void:
	var cost := _get_upgrade_cost(upgrade_id)
	if GameState.purchase_meta_upgrade(upgrade_id, cost):
		_info_label.text = "升级成功！/ Upgrade purchased!"
		_update_gold_display()
		_refresh_buttons()
		EventBus.base_upgrade_purchased.emit(upgrade_id)


func _on_start_voyage() -> void:
	GameState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/map/map_scene.tscn")


func _update_gold_display() -> void:
	_gold_label.text = "航海基金: %d 金 / Fleet Fund: %d Gold" % [GameState.meta_gold, GameState.meta_gold]


func _update_stats_display() -> void:
	_stats_label.text = "总航行: %d次  最远: 第%d幕  同盟国: %d" % [
		GameState.total_runs, GameState.best_act_reached, GameState.nations_allied.size()
	]


func _refresh_buttons() -> void:
	# Remove old buttons and rebuild
	for btn in _buttons:
		btn.queue_free()
	_buttons.clear()

	var col := 0
	var row_idx := 0
	for upgrade_id in META_UPGRADES:
		var upgrade: Dictionary = META_UPGRADES[upgrade_id]
		var current_level: int = GameState.meta_upgrades.get(upgrade_id, 0)
		var max_level: int = upgrade.max_level
		var cost := _get_upgrade_cost(upgrade_id)
		var maxed := current_level >= max_level

		var btn := Button.new()
		var level_text := "MAX" if maxed else "Lv.%d" % current_level
		btn.text = "%s\n%s [%s]\n%s" % [upgrade.name_zh, upgrade.name, level_text, "" if maxed else "%d金" % cost]
		btn.position = Vector2(100 + col * 240, 200 + row_idx * 120)
		btn.custom_minimum_size = Vector2(220, 100)
		btn.add_theme_font_size_override("font_size", 14)
		btn.disabled = maxed or GameState.meta_gold < cost
		btn.pressed.connect(_on_upgrade_pressed.bind(upgrade_id))
		add_child(btn)
		_buttons.append(btn)

		col += 1
		if col >= 4:
			col = 0
			row_idx += 1
