extends Control
## 刘家港主基地 - Liujiagang Harbor Base
## Main hub after clicking "Start Game". Players can:
## 1. Build/upgrade ships (造船)
## 2. View historical materials (历史资料)
## 3. Manage meta-progression from relics & tributes (养成系统)
## 4. Start a new voyage

const PARCHMENT := Color(0.95, 0.92, 0.85)
const INK_DARK := Color(0.15, 0.12, 0.1)
const INK_MED := Color(0.35, 0.30, 0.25)
const INK_LIGHT := Color(0.6, 0.55, 0.5)
const GOLD := Color(0.85, 0.7, 0.3)
const RED_SEAL := Color(0.8, 0.15, 0.1)
const JADE := Color(0.4, 0.65, 0.45)
const WOOD := Color(0.55, 0.38, 0.22)
const WATER_BLUE := Color(0.3, 0.5, 0.65)
const PANEL_BG := Color(0.92, 0.88, 0.8)

enum BaseTab { SHIPYARD, HISTORY, UPGRADES }

var _current_tab: int = BaseTab.SHIPYARD
var _tab_buttons: Array[Button] = []
var _content_container: Control
var _scroll: ScrollContainer
var _gold_label: Label
var _stats_label: Label

# Ship upgrade data
const SHIP_UPGRADES := {
	"hull_size": {
		name = "Hull Size", name_zh = "船体规模",
		desc = "Larger hull = more HP. +10 Max HP per level.",
		desc_zh = "更大的船体意味着更多生命值。每级+10最大生命值。",
		max_level = 5, base_cost = 20, cost_per_level = 15,
		stat = "max_hp", bonus_per_level = 10,
	},
	"cargo_hold": {
		name = "Cargo Hold", name_zh = "货舱扩建",
		desc = "Larger cargo = more starting gold. +20 Gold per level.",
		desc_zh = "更大的货舱意味着更多初始金币。每级+20金币。",
		max_level = 5, base_cost = 15, cost_per_level = 10,
		stat = "starting_gold", bonus_per_level = 20,
	},
	"mast_sails": {
		name = "Mast & Sails", name_zh = "桅杆与帆",
		desc = "Better sails = extra card draw on turn 1. +1 draw per level.",
		desc_zh = "更好的帆意味着第一回合额外抽牌。每级多抽1张。",
		max_level = 3, base_cost = 30, cost_per_level = 25,
		stat = "turn1_draw", bonus_per_level = 1,
	},
	"cannon_deck": {
		name = "Cannon Deck", name_zh = "炮台甲板",
		desc = "More cannons = start combat with Strength. +1 Str per level.",
		desc_zh = "更多火炮意味着战斗开始时获得力量。每级+1力量。",
		max_level = 3, base_cost = 40, cost_per_level = 35,
		stat = "start_strength", bonus_per_level = 1,
	},
	"compass_room": {
		name = "Compass Room", name_zh = "罗盘室",
		desc = "Start runs with the Compass relic (extra draw at combat start).",
		desc_zh = "开始航行时携带罗盘遗物（战斗开始时额外抽牌）。",
		max_level = 1, base_cost = 60, cost_per_level = 0,
		stat = "starter_relic", bonus_per_level = 1,
	},
	"shipyard_dock": {
		name = "Shipyard Dock", name_zh = "船坞",
		desc = "Remove 1 starter card from deck per level.",
		desc_zh = "每级从初始牌组移除1张初始牌。",
		max_level = 3, base_cost = 35, cost_per_level = 30,
		stat = "remove_starter", bonus_per_level = 1,
	},
}

# Historical voyage data
const VOYAGE_HISTORY := [
	{
		title = "First Voyage (1405-1407)", title_zh = "第一次下西洋（1405-1407）",
		content = "Emperor Yongle ordered Zheng He to lead a fleet of 317 ships and 27,800 men. The fleet visited Champa, Java, Sumatra, Sri Lanka, and Calicut. At Palembang, Zheng He defeated the pirate Chen Zuyi who had been terrorizing the Strait of Malacca.",
		content_zh = "永乐帝命郑和率领317艘船和27800人的船队。船队访问了占城、爪哇、苏门答腊、锡兰和古里。在旧港，郑和击败了恐吓马六甲海峡的海盗陈祖义。",
	},
	{
		title = "Second Voyage (1407-1409)", title_zh = "第二次下西洋（1407-1409）",
		content = "The fleet revisited many of the same Southeast Asian ports. Zheng He established a Chinese trading post at Malacca and helped install its ruler Parameswara as a recognized sovereign, protecting him from Siamese interference.",
		content_zh = "船队重访了许多相同的东南亚港口。郑和在满剌加建立了中国贸易站，并帮助其统治者拜里迷苏拉获得承认，保护他免受暹罗干扰。",
	},
	{
		title = "Third Voyage (1409-1411)", title_zh = "第三次下西洋（1409-1411）",
		content = "This voyage focused on Southeast Asia and India. At Ceylon (Sri Lanka), the fleet was attacked by King Alakeshvara. Zheng He defeated the king's forces and brought him back to Nanjing, where Emperor Yongle released him and installed a new ruler.",
		content_zh = "这次航行集中在东南亚和印度。在锡兰（斯里兰卡），船队遭到国王阿烈苦奈儿的攻击。郑和击败了国王的军队，将他带回南京，永乐帝释放了他并立了新的统治者。",
	},
	{
		title = "Fourth Voyage (1413-1415)", title_zh = "第四次下西洋（1413-1415）",
		content = "The fleet sailed further west to Hormuz in the Persian Gulf. This was the first time Chinese ships reached the Middle East. The fleet also visited the Maldives, and several ports on the Arabian Peninsula. Exotic goods including ostriches, zebras, and a giraffe were brought back.",
		content_zh = "船队向西航行更远，到达波斯湾的霍尔木兹。这是中国船只首次到达中东。船队还访问了马尔代夫和阿拉伯半岛的几个港口。带回了鸵鸟、斑马和长颈鹿等珍奇物品。",
	},
	{
		title = "Fifth Voyage (1417-1419)", title_zh = "第五次下西洋（1417-1419）",
		content = "Zheng He escorted ambassadors from over 30 states back to their homelands. The fleet reached Aden at the mouth of the Red Sea and sailed down the East African coast to Mogadishu and Malindi. A giraffe from Malindi was presented to the emperor as a 'qilin' (mythical creature).",
		content_zh = "郑和护送30多个国家的使节回国。船队到达红海口的亚丁，并沿东非海岸航行至摩加迪沙和马林迪。来自马林迪的长颈鹿被作为'麒麟'（神话生物）献给皇帝。",
	},
	{
		title = "Sixth Voyage (1421-1422)", title_zh = "第六次下西洋（1421-1422）",
		content = "A shorter voyage focused on returning foreign envoys to their homelands. The fleet visited Southeast Asia, India, the Persian Gulf, and East Africa. This was the last voyage during Emperor Yongle's reign.",
		content_zh = "这是一次较短的航行，重点是送外国使节回国。船队访问了东南亚、印度、波斯湾和东非。这是永乐帝在位期间的最后一次航行。",
	},
	{
		title = "Seventh Voyage (1431-1433)", title_zh = "第七次下西洋（1431-1433）",
		content = "After a 10-year hiatus, Emperor Xuande ordered one final voyage. Now around 60 years old, Zheng He commanded the largest fleet yet. The fleet visited all previous destinations. Zheng He is believed to have died during the return voyage in 1433, marking the end of China's great Age of Exploration.",
		content_zh = "在中断10年后，宣德帝下令进行最后一次航行。此时已约60岁的郑和指挥了有史以来最大的船队。船队访问了所有以前的目的地。据信郑和在1433年返航途中去世，标志着中国伟大的大航海时代的结束。",
	},
]


func _ready() -> void:
	_build_ui()
	EventBus.base_entered.emit()


func _draw() -> void:
	_draw_harbor_bg()


func _draw_harbor_bg() -> void:
	# Parchment background
	draw_rect(Rect2(0, 0, 1280, 720), PARCHMENT)

	# Sky gradient
	for i in range(15):
		var t := float(i) / 15.0
		var sky_color := Color(0.75 + t * 0.12, 0.82 + t * 0.06, 0.9 + t * 0.02, 0.25)
		draw_rect(Rect2(0, i * 10, 1280, 10), sky_color)

	# Distant mountains
	var mountain_pts := PackedVector2Array([
		Vector2(0, 180), Vector2(80, 100), Vector2(180, 130),
		Vector2(300, 70), Vector2(420, 120), Vector2(550, 85),
		Vector2(700, 110), Vector2(850, 75), Vector2(1000, 115),
		Vector2(1150, 90), Vector2(1280, 130), Vector2(1280, 180), Vector2(0, 180)
	])
	draw_polygon(mountain_pts, [Color(INK_LIGHT, 0.3)])

	# Harbor water
	draw_rect(Rect2(0, 560, 1280, 160), Color(WATER_BLUE, 0.25))
	# Water ripples
	for i in range(8):
		var wave_y := 570.0 + i * 18
		draw_line(Vector2(0, wave_y), Vector2(1280, wave_y), Color(WATER_BLUE, 0.1), 1.0)

	# Dock structure
	draw_rect(Rect2(50, 530, 350, 16), WOOD)
	draw_rect(Rect2(50, 530, 8, 50), WOOD)
	draw_rect(Rect2(392, 530, 8, 50), WOOD)
	draw_rect(Rect2(200, 530, 8, 50), WOOD)

	# Ship silhouette on water
	var ship_pts := PackedVector2Array([
		Vector2(480, 570), Vector2(520, 555), Vector2(620, 545),
		Vector2(720, 555), Vector2(740, 570),
		Vector2(730, 585), Vector2(490, 585),
	])
	draw_polygon(ship_pts, [Color(WOOD, 0.6)])
	# Mast
	draw_line(Vector2(600, 545), Vector2(600, 470), Color(WOOD, 0.5), 3.0)
	draw_line(Vector2(560, 490), Vector2(640, 490), Color(WOOD, 0.4), 2.0)

	# Title banner area
	draw_rect(Rect2(300, 12, 680, 55), Color(INK_DARK, 0.85))
	draw_rect(Rect2(302, 14, 676, 51), Color(PARCHMENT, 0.95))

	# Red seal stamp
	draw_circle(Vector2(1220, 660), 28, Color(RED_SEAL, 0.25))


func _build_ui() -> void:
	# Title
	var title := Label.new()
	title.text = Locale.t("Liujiagang Harbor", "刘家港")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(340, 18)
	title.custom_minimum_size = Vector2(600, 45)
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", INK_DARK)
	add_child(title)

	# Gold & stats bar
	var info_bar := ColorRect.new()
	info_bar.color = Color(INK_DARK, 0.7)
	info_bar.position = Vector2(0, 70)
	info_bar.size = Vector2(1280, 35)
	add_child(info_bar)

	_gold_label = Label.new()
	_gold_label.position = Vector2(30, 74)
	_gold_label.add_theme_font_size_override("font_size", 16)
	_gold_label.add_theme_color_override("font_color", GOLD)
	add_child(_gold_label)

	_stats_label = Label.new()
	_stats_label.position = Vector2(350, 74)
	_stats_label.add_theme_font_size_override("font_size", 14)
	_stats_label.add_theme_color_override("font_color", Color(PARCHMENT, 0.8))
	add_child(_stats_label)

	_update_info_display()

	# Tab buttons
	var tab_names := [
		Locale.t("Shipyard", "造船厂"),
		Locale.t("Historical Records", "历史资料"),
		Locale.t("Fleet Upgrades", "舰队养成"),
	]
	_tab_buttons.clear()
	for i in range(tab_names.size()):
		var btn := Button.new()
		btn.text = tab_names[i]
		btn.position = Vector2(50 + i * 300, 112)
		btn.custom_minimum_size = Vector2(280, 36)
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(_on_tab_pressed.bind(i))
		add_child(btn)
		_tab_buttons.append(btn)

	# Content area
	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(30, 155)
	_scroll.size = Vector2(900, 370)
	add_child(_scroll)

	_content_container = VBoxContainer.new()
	_content_container.custom_minimum_size = Vector2(880, 0)
	_scroll.add_child(_content_container)

	# Right side panel - action buttons
	var action_panel := ColorRect.new()
	action_panel.color = Color(INK_DARK, 0.08)
	action_panel.position = Vector2(950, 155)
	action_panel.size = Vector2(310, 370)
	add_child(action_panel)

	var action_title := Label.new()
	action_title.text = Locale.t("Fleet Status", "舰队状态")
	action_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_title.position = Vector2(960, 162)
	action_title.custom_minimum_size = Vector2(290, 30)
	action_title.add_theme_font_size_override("font_size", 18)
	action_title.add_theme_color_override("font_color", INK_DARK)
	add_child(action_title)

	# Fleet status summary
	_build_fleet_status()

	# Start Voyage button
	var start_btn := Button.new()
	start_btn.text = Locale.t("Set Sail!", "扬帆起航！")
	start_btn.position = Vector2(440, 545)
	start_btn.custom_minimum_size = Vector2(400, 65)
	start_btn.add_theme_font_size_override("font_size", 24)
	start_btn.pressed.connect(_on_start_voyage)
	add_child(start_btn)

	# Back to menu button
	var menu_btn := Button.new()
	menu_btn.text = Locale.t("Main Menu", "返回主菜单")
	menu_btn.position = Vector2(540, 620)
	menu_btn.custom_minimum_size = Vector2(200, 36)
	menu_btn.add_theme_font_size_override("font_size", 14)
	menu_btn.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn"))
	add_child(menu_btn)

	_update_tab_styles()
	_show_tab_content()


func _build_fleet_status() -> void:
	var y := 200
	var ship_stats := [
		[Locale.t("Hull", "船体"), "hull_size"],
		[Locale.t("Cargo", "货舱"), "cargo_hold"],
		[Locale.t("Sails", "帆"), "mast_sails"],
		[Locale.t("Cannons", "火炮"), "cannon_deck"],
		[Locale.t("Compass", "罗盘"), "compass_room"],
		[Locale.t("Dock", "船坞"), "shipyard_dock"],
	]
	for stat_info in ship_stats:
		var stat_name: String = stat_info[0]
		var upgrade_id: String = stat_info[1]
		var current_level: int = GameState.meta_upgrades.get(upgrade_id, 0)
		var max_level: int = SHIP_UPGRADES[upgrade_id].max_level

		var label := Label.new()
		label.text = "%s: " % stat_name
		label.position = Vector2(970, y)
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", INK_MED)
		add_child(label)

		# Level indicator (filled/empty blocks)
		for j in range(max_level):
			var block := ColorRect.new()
			block.position = Vector2(1080 + j * 28, y + 3)
			block.size = Vector2(22, 16)
			if j < current_level:
				block.color = GOLD
			else:
				block.color = Color(INK_LIGHT, 0.3)
			add_child(block)

		y += 26


func _update_info_display() -> void:
	_gold_label.text = Locale.t(
		"Fleet Fund: %d Gold" % GameState.meta_gold,
		"航海基金: %d 金" % GameState.meta_gold
	)
	_stats_label.text = Locale.t(
		"Voyages: %d | Best: Act %d | Allies: %d" % [GameState.total_runs, GameState.best_act_reached, GameState.nations_allied.size()],
		"总航行: %d次 | 最远: 第%d幕 | 同盟国: %d" % [GameState.total_runs, GameState.best_act_reached, GameState.nations_allied.size()]
	)


func _update_tab_styles() -> void:
	for i in range(_tab_buttons.size()):
		if i == _current_tab:
			_tab_buttons[i].add_theme_color_override("font_color", RED_SEAL)
		else:
			_tab_buttons[i].remove_theme_color_override("font_color")


func _on_tab_pressed(tab_index: int) -> void:
	_current_tab = tab_index
	_update_tab_styles()
	_show_tab_content()


func _clear_content() -> void:
	for child in _content_container.get_children():
		child.queue_free()


func _show_tab_content() -> void:
	_clear_content()
	match _current_tab:
		BaseTab.SHIPYARD:
			_show_shipyard()
		BaseTab.HISTORY:
			_show_history()
		BaseTab.UPGRADES:
			_show_upgrades()


# ─── SHIPYARD TAB ────────────────────────────────────────────────────────────

func _show_shipyard() -> void:
	_add_section_header(Locale.t("Build & Upgrade Your Ships", "建造与升级你的船只"))
	_add_desc_label(Locale.t(
		"Strengthen your treasure fleet before each voyage. Upgrades persist across all runs.",
		"在每次航行前加强你的宝船舰队。升级在所有航行中永久保留。"
	))

	for upgrade_id in SHIP_UPGRADES:
		var upgrade: Dictionary = SHIP_UPGRADES[upgrade_id]
		var current_level: int = GameState.meta_upgrades.get(upgrade_id, 0)
		var max_level: int = upgrade.max_level
		var cost := _get_ship_cost(upgrade_id)
		var maxed := current_level >= max_level

		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(860, 85)
		var stylebox := StyleBoxFlat.new()
		stylebox.bg_color = Color(PANEL_BG, 0.6)
		stylebox.border_width_left = 4
		stylebox.border_color = GOLD if not maxed else JADE
		stylebox.corner_radius_top_left = 4
		stylebox.corner_radius_top_right = 4
		stylebox.corner_radius_bottom_left = 4
		stylebox.corner_radius_bottom_right = 4
		stylebox.content_margin_left = 14
		stylebox.content_margin_right = 10
		stylebox.content_margin_top = 8
		stylebox.content_margin_bottom = 8
		panel.add_theme_stylebox_override("panel", stylebox)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 15)
		panel.add_child(hbox)

		var info_vbox := VBoxContainer.new()
		info_vbox.custom_minimum_size = Vector2(580, 0)
		hbox.add_child(info_vbox)

		var name_label := Label.new()
		var uname: String = Locale.t(upgrade.name, upgrade.name_zh)
		var level_text := "MAX" if maxed else "Lv.%d/%d" % [current_level, max_level]
		name_label.text = "%s [%s]" % [uname, level_text]
		name_label.add_theme_font_size_override("font_size", 17)
		name_label.add_theme_color_override("font_color", INK_DARK)
		info_vbox.add_child(name_label)

		var desc_label := Label.new()
		desc_label.text = Locale.t(upgrade.desc, upgrade.desc_zh)
		desc_label.add_theme_font_size_override("font_size", 13)
		desc_label.add_theme_color_override("font_color", INK_MED)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.custom_minimum_size = Vector2(560, 0)
		info_vbox.add_child(desc_label)

		# Buy button
		var btn := Button.new()
		if maxed:
			btn.text = Locale.t("MAX", "已满")
			btn.disabled = true
		else:
			var cost_str := Locale.t("%d Gold" % cost, "%d金" % cost)
			btn.text = cost_str
			btn.disabled = GameState.meta_gold < cost
		btn.custom_minimum_size = Vector2(140, 55)
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(_on_ship_upgrade.bind(upgrade_id))
		hbox.add_child(btn)

		_content_container.add_child(panel)
		_add_spacer(6)


func _get_ship_cost(upgrade_id: String) -> int:
	var upgrade: Dictionary = SHIP_UPGRADES[upgrade_id]
	var current_level: int = GameState.meta_upgrades.get(upgrade_id, 0)
	return upgrade.base_cost + current_level * upgrade.cost_per_level


func _on_ship_upgrade(upgrade_id: String) -> void:
	var cost := _get_ship_cost(upgrade_id)
	if GameState.purchase_meta_upgrade(upgrade_id, cost):
		_update_info_display()
		_show_tab_content()
		# Rebuild fleet status
		_rebuild_fleet_status()
		EventBus.base_upgrade_purchased.emit(upgrade_id)


func _rebuild_fleet_status() -> void:
	# Remove old status labels and rebuild
	# This is a simplified rebuild - just refresh the whole scene
	for child in get_children():
		child.queue_free()
	_tab_buttons.clear()
	_build_ui()


# ─── HISTORY TAB ─────────────────────────────────────────────────────────────

func _show_history() -> void:
	_add_section_header(Locale.t("The Seven Voyages of Zheng He", "郑和七次下西洋"))
	_add_desc_label(Locale.t(
		"From 1405 to 1433, Admiral Zheng He led seven great maritime expeditions, commanding the largest wooden fleet ever assembled.",
		"从1405年到1433年，郑和率领有史以来最大的木制舰队，进行了七次伟大的远洋航行。"
	))

	for i in range(VOYAGE_HISTORY.size()):
		var voyage: Dictionary = VOYAGE_HISTORY[i]
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(860, 0)
		var stylebox := StyleBoxFlat.new()
		stylebox.bg_color = Color(PANEL_BG, 0.5)
		stylebox.border_width_left = 4
		stylebox.border_color = RED_SEAL if i == 0 or i == 6 else GOLD
		stylebox.corner_radius_top_left = 4
		stylebox.corner_radius_top_right = 4
		stylebox.corner_radius_bottom_left = 4
		stylebox.corner_radius_bottom_right = 4
		stylebox.content_margin_left = 14
		stylebox.content_margin_right = 14
		stylebox.content_margin_top = 10
		stylebox.content_margin_bottom = 10
		panel.add_theme_stylebox_override("panel", stylebox)

		var vbox := VBoxContainer.new()
		panel.add_child(vbox)

		var title_label := Label.new()
		title_label.text = Locale.t(voyage.title, voyage.title_zh)
		title_label.add_theme_font_size_override("font_size", 17)
		title_label.add_theme_color_override("font_color", INK_DARK)
		vbox.add_child(title_label)

		var content_label := Label.new()
		content_label.text = Locale.t(voyage.content, voyage.content_zh)
		content_label.add_theme_font_size_override("font_size", 13)
		content_label.add_theme_color_override("font_color", INK_MED)
		content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content_label.custom_minimum_size = Vector2(820, 0)
		vbox.add_child(content_label)

		_content_container.add_child(panel)
		_add_spacer(8)


# ─── UPGRADES TAB (Progression from relics & tributes) ───────────────────────

func _show_upgrades() -> void:
	_add_section_header(Locale.t("Tribute & Relic Progression", "朝贡与遗物养成"))
	_add_desc_label(Locale.t(
		"Relics collected and diplomatic tributes earned during voyages contribute to permanent fleet bonuses. Spend Fleet Fund gold to unlock progression tiers.",
		"航行中收集的遗物和获得的外交朝贡将贡献永久舰队加成。花费航海基金金币解锁养成等级。"
	))

	# Diplomacy achievements
	_add_subsection_header(Locale.t("Diplomatic Relations", "外交关系"))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 8)
	_content_container.add_child(grid)

	for nation_id in DiplomacyData.NATION_INFO:
		var info: Dictionary = DiplomacyData.NATION_INFO[nation_id]
		var is_allied: bool = GameState.nations_allied.has(nation_id)

		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(425, 55)
		var stylebox := StyleBoxFlat.new()
		stylebox.bg_color = Color(PANEL_BG, 0.4)
		stylebox.border_width_left = 3
		stylebox.border_color = JADE if is_allied else INK_LIGHT
		stylebox.corner_radius_top_left = 4
		stylebox.corner_radius_top_right = 4
		stylebox.corner_radius_bottom_left = 4
		stylebox.corner_radius_bottom_right = 4
		stylebox.content_margin_left = 10
		stylebox.content_margin_top = 6
		stylebox.content_margin_bottom = 6
		panel.add_theme_stylebox_override("panel", stylebox)

		var vbox := VBoxContainer.new()
		panel.add_child(vbox)

		var name_label := Label.new()
		var nation_name: String = Locale.t(info.name, info.name_zh)
		var status_text: String = Locale.t("Allied", "同盟") if is_allied else Locale.t("Not Allied", "未结盟")
		name_label.text = "%s - %s" % [nation_name, status_text]
		name_label.add_theme_font_size_override("font_size", 14)
		name_label.add_theme_color_override("font_color", JADE if is_allied else INK_MED)
		vbox.add_child(name_label)

		grid.add_child(panel)

	_add_spacer(15)

	# Relic collection summary
	_add_subsection_header(Locale.t("Collected Relics (This Run)", "已收集遗物（本次航行）"))
	if GameState.player_relics.is_empty():
		var empty_label := Label.new()
		empty_label.text = Locale.t("No relics collected yet. Start a voyage to find relics!", "尚未收集遗物。开始航行以寻找遗物！")
		empty_label.add_theme_font_size_override("font_size", 14)
		empty_label.add_theme_color_override("font_color", INK_LIGHT)
		_content_container.add_child(empty_label)
	else:
		var relic_grid := GridContainer.new()
		relic_grid.columns = 3
		relic_grid.add_theme_constant_override("h_separation", 8)
		relic_grid.add_theme_constant_override("v_separation", 6)
		_content_container.add_child(relic_grid)
		for relic_id in GameState.player_relics:
			var relic := RelicDatabase.get_relic(relic_id)
			if relic:
				var rd := relic as RelicData
				var label := Label.new()
				label.text = Locale.t(rd.relic_name, rd.relic_name_zh)
				label.add_theme_font_size_override("font_size", 14)
				label.add_theme_color_override("font_color", GOLD)
				relic_grid.add_child(label)


# ─── HELPERS ─────────────────────────────────────────────────────────────────

func _add_section_header(text: String) -> void:
	var header := Label.new()
	header.text = text
	header.add_theme_font_size_override("font_size", 20)
	header.add_theme_color_override("font_color", INK_DARK)
	header.custom_minimum_size = Vector2(860, 32)
	_content_container.add_child(header)


func _add_subsection_header(text: String) -> void:
	var header := Label.new()
	header.text = text
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", RED_SEAL)
	header.custom_minimum_size = Vector2(860, 28)
	_content_container.add_child(header)


func _add_desc_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", INK_MED)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(860, 0)
	_content_container.add_child(label)
	_add_spacer(8)


func _add_spacer(height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	_content_container.add_child(spacer)


func _on_start_voyage() -> void:
	GameState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/map/map_scene.tscn")
