extends Control

## Encyclopedia (百科大全) - Browse all cards, relics, characters, bosses, and enemies.

const BG_COLOR := Color(0.02, 0.06, 0.12)
const PANEL_BG := Color(0.06, 0.08, 0.14)
const TAB_ACTIVE := Color(0.85, 0.7, 0.3)
const TAB_INACTIVE := Color(0.4, 0.38, 0.35)
const TITLE_COLOR := Color(0.9, 0.75, 0.3)
const TEXT_COLOR := Color(0.85, 0.82, 0.75)
const SUBTEXT_COLOR := Color(0.6, 0.58, 0.52)
const CARD_ATTACK := Color(0.75, 0.25, 0.2)
const CARD_SKILL := Color(0.2, 0.45, 0.75)
const CARD_POWER := Color(0.7, 0.6, 0.15)
const ENEMY_NORMAL := Color(0.45, 0.35, 0.25)
const ENEMY_ELITE := Color(0.65, 0.45, 0.15)
const ENEMY_BOSS := Color(0.7, 0.15, 0.1)
const RELIC_COLORS := {
	0: Color(0.5, 0.5, 0.5),  # STARTER
	1: Color(0.4, 0.6, 0.4),  # COMMON
	2: Color(0.3, 0.45, 0.7), # UNCOMMON
	3: Color(0.7, 0.55, 0.15),# RARE
	4: Color(0.7, 0.15, 0.1), # BOSS
	5: Color(0.5, 0.3, 0.6),  # EVENT
}

enum Tab { CARDS, RELICS, CHARACTERS, BOSSES, ENEMIES }

var _current_tab: int = Tab.CARDS
var _tab_buttons: Array[Button] = []
var _content_container: Control
var _scroll_container: ScrollContainer
var _back_btn: Button
var _detail_panel: Control


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.color = BG_COLOR
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Title
	var title := Label.new()
	title.text = Locale.t("Encyclopedia", "百科大全")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(340, 10)
	title.custom_minimum_size = Vector2(600, 40)
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", TITLE_COLOR)
	add_child(title)

	# Tab bar
	var tab_names := [
		Locale.t("Cards", "卡牌"),
		Locale.t("Relics", "遗物"),
		Locale.t("Characters", "角色"),
		Locale.t("Bosses", "首领"),
		Locale.t("Enemies", "敌人"),
	]
	_tab_buttons.clear()
	for i in range(tab_names.size()):
		var btn := Button.new()
		btn.text = tab_names[i]
		btn.position = Vector2(60 + i * 235, 55)
		btn.custom_minimum_size = Vector2(220, 38)
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(_on_tab_pressed.bind(i))
		add_child(btn)
		_tab_buttons.append(btn)

	# Scroll container for content
	_scroll_container = ScrollContainer.new()
	_scroll_container.position = Vector2(30, 100)
	_scroll_container.size = Vector2(1220, 560)
	add_child(_scroll_container)

	_content_container = VBoxContainer.new()
	_content_container.custom_minimum_size = Vector2(1200, 0)
	_scroll_container.add_child(_content_container)

	# Back button
	_back_btn = Button.new()
	_back_btn.text = Locale.t("Back", "返回")
	_back_btn.position = Vector2(560, 670)
	_back_btn.custom_minimum_size = Vector2(160, 40)
	_back_btn.add_theme_font_size_override("font_size", 18)
	_back_btn.pressed.connect(_on_back)
	add_child(_back_btn)

	_update_tab_styles()
	_show_tab_content()


func _update_tab_styles() -> void:
	for i in range(_tab_buttons.size()):
		var btn := _tab_buttons[i]
		if i == _current_tab:
			btn.add_theme_color_override("font_color", TAB_ACTIVE)
		else:
			btn.add_theme_color_override("font_color", TAB_INACTIVE)


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
		Tab.CARDS:
			_show_cards()
		Tab.RELICS:
			_show_relics()
		Tab.CHARACTERS:
			_show_characters()
		Tab.BOSSES:
			_show_bosses()
		Tab.ENEMIES:
			_show_enemies()


# ─── CARDS TAB ───────────────────────────────────────────────────────────────

func _show_cards() -> void:
	var all_cards := CardDatabase.get_all_cards()

	# Group by rarity
	var groups := {
		CardData.CardRarity.STARTER: [],
		CardData.CardRarity.COMMON: [],
		CardData.CardRarity.UNCOMMON: [],
		CardData.CardRarity.RARE: [],
	}
	for card in all_cards:
		var cd := card as CardData
		if groups.has(cd.rarity):
			groups[cd.rarity].append(cd)

	var rarity_names := {
		CardData.CardRarity.STARTER: Locale.t("Starter Cards", "初始卡牌"),
		CardData.CardRarity.COMMON: Locale.t("Common Cards", "普通卡牌"),
		CardData.CardRarity.UNCOMMON: Locale.t("Uncommon Cards", "稀有卡牌"),
		CardData.CardRarity.RARE: Locale.t("Rare Cards", "传说卡牌"),
	}

	for rarity in [CardData.CardRarity.STARTER, CardData.CardRarity.COMMON, CardData.CardRarity.UNCOMMON, CardData.CardRarity.RARE]:
		if groups[rarity].is_empty():
			continue
		_add_section_header(rarity_names[rarity])
		var grid := _create_grid(4, 8)
		_content_container.add_child(grid)
		for cd: CardData in groups[rarity]:
			var card_panel := _create_card_entry(cd)
			grid.add_child(card_panel)
		_add_spacer(10)


func _create_card_entry(cd: CardData) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(280, 120)
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = PANEL_BG
	stylebox.border_width_bottom = 3
	match cd.type:
		CardData.CardType.ATTACK:
			stylebox.border_color = CARD_ATTACK
		CardData.CardType.SKILL:
			stylebox.border_color = CARD_SKILL
		CardData.CardType.POWER:
			stylebox.border_color = CARD_POWER
		_:
			stylebox.border_color = Color(0.4, 0.4, 0.4)
	stylebox.corner_radius_top_left = 6
	stylebox.corner_radius_top_right = 6
	stylebox.corner_radius_bottom_left = 6
	stylebox.corner_radius_bottom_right = 6
	stylebox.content_margin_left = 12
	stylebox.content_margin_right = 12
	stylebox.content_margin_top = 8
	stylebox.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", stylebox)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# Card name + cost
	var name_label := Label.new()
	var card_name: String = Locale.t(cd.card_name, cd.card_name_zh)
	var cost_text := "[%d]" % cd.cost if cd.cost >= 0 else "[X]"
	name_label.text = "%s %s" % [cost_text, card_name]
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", TEXT_COLOR)
	vbox.add_child(name_label)

	# Type label
	var type_names := {
		CardData.CardType.ATTACK: Locale.t("Attack", "攻击"),
		CardData.CardType.SKILL: Locale.t("Skill", "技能"),
		CardData.CardType.POWER: Locale.t("Power", "能力"),
		CardData.CardType.CURSE: Locale.t("Curse", "诅咒"),
		CardData.CardType.STATUS: Locale.t("Status", "状态"),
	}
	var type_label := Label.new()
	type_label.text = type_names.get(cd.type, "???")
	type_label.add_theme_font_size_override("font_size", 12)
	type_label.add_theme_color_override("font_color", SUBTEXT_COLOR)
	vbox.add_child(type_label)

	# Description
	var desc := Label.new()
	desc.text = Locale.t(cd.description, cd.description_zh)
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", TEXT_COLOR)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(250, 0)
	vbox.add_child(desc)

	return panel


# ─── RELICS TAB ──────────────────────────────────────────────────────────────

func _show_relics() -> void:
	var all_relics := RelicDatabase.get_all_relics()

	var rarity_order := [
		RelicData.RelicRarity.STARTER,
		RelicData.RelicRarity.COMMON,
		RelicData.RelicRarity.UNCOMMON,
		RelicData.RelicRarity.RARE,
		RelicData.RelicRarity.BOSS,
		RelicData.RelicRarity.EVENT,
	]
	var rarity_names := {
		RelicData.RelicRarity.STARTER: Locale.t("Starter", "初始"),
		RelicData.RelicRarity.COMMON: Locale.t("Common", "普通"),
		RelicData.RelicRarity.UNCOMMON: Locale.t("Uncommon", "稀有"),
		RelicData.RelicRarity.RARE: Locale.t("Rare", "传说"),
		RelicData.RelicRarity.BOSS: Locale.t("Boss", "首领"),
		RelicData.RelicRarity.EVENT: Locale.t("Event", "事件"),
	}

	var groups := {}
	for r in rarity_order:
		groups[r] = []
	for relic in all_relics:
		var rd := relic as RelicData
		if groups.has(rd.rarity):
			groups[rd.rarity].append(rd)

	for rarity in rarity_order:
		if groups[rarity].is_empty():
			continue
		_add_section_header(rarity_names[rarity])
		var grid := _create_grid(3, 10)
		_content_container.add_child(grid)
		for rd: RelicData in groups[rarity]:
			var relic_panel := _create_relic_entry(rd)
			grid.add_child(relic_panel)
		_add_spacer(10)


func _create_relic_entry(rd: RelicData) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(380, 90)
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = PANEL_BG
	stylebox.border_width_left = 4
	stylebox.border_color = RELIC_COLORS.get(rd.rarity, Color(0.5, 0.5, 0.5))
	stylebox.corner_radius_top_left = 4
	stylebox.corner_radius_top_right = 4
	stylebox.corner_radius_bottom_left = 4
	stylebox.corner_radius_bottom_right = 4
	stylebox.content_margin_left = 14
	stylebox.content_margin_right = 10
	stylebox.content_margin_top = 8
	stylebox.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", stylebox)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var name_label := Label.new()
	name_label.text = Locale.t(rd.relic_name, rd.relic_name_zh)
	name_label.add_theme_font_size_override("font_size", 17)
	name_label.add_theme_color_override("font_color", RELIC_COLORS.get(rd.rarity, TEXT_COLOR))
	vbox.add_child(name_label)

	var desc := Label.new()
	desc.text = Locale.t(rd.description, rd.description_zh)
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", TEXT_COLOR)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(350, 0)
	vbox.add_child(desc)

	return panel


# ─── CHARACTERS TAB ─────────────────────────────────────────────────────────

func _show_characters() -> void:
	_add_section_header(Locale.t("Playable Characters", "可用角色"))

	# Zheng He
	var zheng_he_panel := _create_character_entry(
		Locale.t("Zheng He", "郑和"),
		Locale.t("Admiral of the Treasure Fleet", "宝船舰队统帅"),
		Locale.t(
			"Zheng He (1371-1433), born Ma He, was a Chinese mariner, explorer, diplomat, and fleet admiral during China's Ming dynasty. He commanded expeditionary treasure voyages to Southeast Asia, South Asia, Western Asia, and East Africa from 1405 to 1433. His fleet comprised of massive treasure ships (宝船), the largest wooden ships ever built, carrying silk, porcelain, and precious goods for trade and diplomacy.\n\nAs a military commander, Zheng He defeated the pirate Chen Zuyi at Palembang, established diplomatic relations with over 30 nations, and brought back exotic gifts including a giraffe (believed to be a qilin) from Africa.",
			"郑和（1371-1433），原名马和，是中国明朝的航海家、探险家、外交家和舰队统帅。1405年至1433年间，他率领远洋宝船队前往东南亚、南亚、西亚和东非。他的舰队由巨大的宝船组成，这是有史以来建造的最大木制船只，装载着丝绸、瓷器和珍贵商品用于贸易和外交。\n\n作为军事统帅，郑和在旧港击败了海盗陈祖义，与30多个国家建立了外交关系，并从非洲带回了长颈鹿（被认为是麒麟）等珍奇贡品。"
		),
		Locale.t("Base HP: 80 | Starting Gold: 100 | Energy: 3/turn", "基础生命: 80 | 初始金币: 100 | 能量: 3/回合")
	)
	_content_container.add_child(zheng_he_panel)
	_add_spacer(15)

	# Nations section
	_add_section_header(Locale.t("Nations & Kingdoms", "国家与王国"))
	var grid := _create_grid(2, 12)
	_content_container.add_child(grid)

	for nation_id in DiplomacyData.NATION_INFO:
		var info: Dictionary = DiplomacyData.NATION_INFO[nation_id]
		var nation_panel := _create_nation_entry(info)
		grid.add_child(nation_panel)


func _create_character_entry(char_name: String, char_title: String, bio: String, stats: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1180, 0)
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = PANEL_BG
	stylebox.border_width_top = 3
	stylebox.border_color = TITLE_COLOR
	stylebox.corner_radius_top_left = 8
	stylebox.corner_radius_top_right = 8
	stylebox.corner_radius_bottom_left = 8
	stylebox.corner_radius_bottom_right = 8
	stylebox.content_margin_left = 20
	stylebox.content_margin_right = 20
	stylebox.content_margin_top = 15
	stylebox.content_margin_bottom = 15
	panel.add_theme_stylebox_override("panel", stylebox)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var name_label := Label.new()
	name_label.text = char_name
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", TITLE_COLOR)
	vbox.add_child(name_label)

	var title_label := Label.new()
	title_label.text = char_title
	title_label.add_theme_font_size_override("font_size", 15)
	title_label.add_theme_color_override("font_color", SUBTEXT_COLOR)
	vbox.add_child(title_label)

	_add_spacer_to(vbox, 8)

	var bio_label := Label.new()
	bio_label.text = bio
	bio_label.add_theme_font_size_override("font_size", 14)
	bio_label.add_theme_color_override("font_color", TEXT_COLOR)
	bio_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bio_label.custom_minimum_size = Vector2(1130, 0)
	vbox.add_child(bio_label)

	_add_spacer_to(vbox, 8)

	var stats_label := Label.new()
	stats_label.text = stats
	stats_label.add_theme_font_size_override("font_size", 14)
	stats_label.add_theme_color_override("font_color", TITLE_COLOR)
	vbox.add_child(stats_label)

	return panel


func _create_nation_entry(info: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(580, 80)
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = PANEL_BG
	stylebox.border_width_left = 3
	stylebox.border_color = Color(0.45, 0.55, 0.7)
	stylebox.corner_radius_top_left = 4
	stylebox.corner_radius_top_right = 4
	stylebox.corner_radius_bottom_left = 4
	stylebox.corner_radius_bottom_right = 4
	stylebox.content_margin_left = 14
	stylebox.content_margin_right = 10
	stylebox.content_margin_top = 8
	stylebox.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", stylebox)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var name_label := Label.new()
	name_label.text = Locale.t(info.name, info.name_zh) + " (Act %d)" % info.act
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", TEXT_COLOR)
	vbox.add_child(name_label)

	var desc := Label.new()
	desc.text = Locale.t(info.description, info.description_zh)
	desc.add_theme_font_size_override("font_size", 12)
	desc.add_theme_color_override("font_color", SUBTEXT_COLOR)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(550, 0)
	vbox.add_child(desc)

	return panel


# ─── BOSSES TAB ──────────────────────────────────────────────────────────────

func _show_bosses() -> void:
	var all_enemies := EnemyDatabase.get_all_enemies()
	_add_section_header(Locale.t("Act Bosses", "幕间首领"))

	for enemy in all_enemies:
		var ed := enemy as EnemyData
		if ed.type == EnemyData.EnemyType.BOSS:
			var panel := _create_enemy_detail_entry(ed, true)
			_content_container.add_child(panel)
			_add_spacer(8)

	_add_section_header(Locale.t("Elite Enemies", "精英敌人"))
	for enemy in all_enemies:
		var ed := enemy as EnemyData
		if ed.type == EnemyData.EnemyType.ELITE:
			var panel := _create_enemy_detail_entry(ed, false)
			_content_container.add_child(panel)
			_add_spacer(8)


# ─── ENEMIES TAB ─────────────────────────────────────────────────────────────

func _show_enemies() -> void:
	var act_names := {
		1: Locale.t("Act 1 - Southeast Asia", "第一幕 - 南洋"),
		2: Locale.t("Act 2 - Indian Ocean", "第二幕 - 印度洋"),
		3: Locale.t("Act 3 - Middle East & Africa", "第三幕 - 西域非洲"),
	}

	for act in [1, 2, 3]:
		_add_section_header(act_names[act])
		var normal_pool := EnemyDatabase.get_normal_pool_for_act(act)
		var grid := _create_grid(3, 10)
		_content_container.add_child(grid)
		for enemy in normal_pool:
			var ed := enemy as EnemyData
			var panel := _create_enemy_entry(ed)
			grid.add_child(panel)
		_add_spacer(10)


func _create_enemy_entry(ed: EnemyData) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(380, 100)
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = PANEL_BG
	stylebox.border_width_bottom = 3
	match ed.type:
		EnemyData.EnemyType.NORMAL:
			stylebox.border_color = ENEMY_NORMAL
		EnemyData.EnemyType.ELITE:
			stylebox.border_color = ENEMY_ELITE
		EnemyData.EnemyType.BOSS:
			stylebox.border_color = ENEMY_BOSS
	stylebox.corner_radius_top_left = 4
	stylebox.corner_radius_top_right = 4
	stylebox.corner_radius_bottom_left = 4
	stylebox.corner_radius_bottom_right = 4
	stylebox.content_margin_left = 12
	stylebox.content_margin_right = 10
	stylebox.content_margin_top = 8
	stylebox.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", stylebox)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var name_label := Label.new()
	name_label.text = Locale.t(ed.enemy_name, ed.enemy_name_zh)
	name_label.add_theme_font_size_override("font_size", 17)
	name_label.add_theme_color_override("font_color", TEXT_COLOR)
	vbox.add_child(name_label)

	var hp_label := Label.new()
	hp_label.text = "HP: %d-%d" % [ed.hp_min, ed.hp_max]
	hp_label.add_theme_font_size_override("font_size", 13)
	hp_label.add_theme_color_override("font_color", Color(0.8, 0.3, 0.3))
	vbox.add_child(hp_label)

	# Moves summary
	var moves_text := ""
	for move in ed.moves:
		var intent: String = move.get("intent_type", "???")
		moves_text += "%s  " % intent
	var moves_label := Label.new()
	moves_label.text = Locale.t("Moves: ", "招式: ") + moves_text.strip_edges()
	moves_label.add_theme_font_size_override("font_size", 11)
	moves_label.add_theme_color_override("font_color", SUBTEXT_COLOR)
	moves_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	moves_label.custom_minimum_size = Vector2(350, 0)
	vbox.add_child(moves_label)

	return panel


func _create_enemy_detail_entry(ed: EnemyData, is_boss: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1180, 0)
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = PANEL_BG
	stylebox.border_width_left = 5
	stylebox.border_color = ENEMY_BOSS if is_boss else ENEMY_ELITE
	stylebox.corner_radius_top_left = 6
	stylebox.corner_radius_top_right = 6
	stylebox.corner_radius_bottom_left = 6
	stylebox.corner_radius_bottom_right = 6
	stylebox.content_margin_left = 18
	stylebox.content_margin_right = 14
	stylebox.content_margin_top = 12
	stylebox.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", stylebox)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# Name and HP
	var name_label := Label.new()
	var type_str := "BOSS" if is_boss else "ELITE"
	name_label.text = "[%s] %s" % [type_str, Locale.t(ed.enemy_name, ed.enemy_name_zh)]
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", ENEMY_BOSS if is_boss else ENEMY_ELITE)
	vbox.add_child(name_label)

	var hp_label := Label.new()
	hp_label.text = "HP: %d-%d  |  AI: %s" % [ed.hp_min, ed.hp_max, ed.ai_type]
	hp_label.add_theme_font_size_override("font_size", 14)
	hp_label.add_theme_color_override("font_color", Color(0.8, 0.3, 0.3))
	vbox.add_child(hp_label)

	_add_spacer_to(vbox, 6)

	# Detailed moves
	for move in ed.moves:
		var move_label := Label.new()
		var move_name: String = move.get("id", "???")
		var intent: String = move.get("intent_type", "???")
		var effects_text := ""
		var effects: Array = move.get("effects", [])
		for effect in effects:
			var etype: String = effect.get("type", "")
			var evalue: int = effect.get("value", 0)
			var hits: int = effect.get("hits", 1)
			match etype:
				"DAMAGE":
					effects_text += "%d DMG" % evalue
					if hits > 1:
						effects_text += " x%d" % hits
				"BLOCK":
					effects_text += "%d Block" % evalue
				"APPLY_STATUS":
					var sid: String = effect.get("status_id", "")
					effects_text += "%d %s" % [evalue, sid]
				_:
					effects_text += "%s %d" % [etype, evalue]
			effects_text += ", "
		effects_text = effects_text.trim_suffix(", ")
		move_label.text = "  %s (%s): %s" % [move_name, intent, effects_text]
		move_label.add_theme_font_size_override("font_size", 13)
		move_label.add_theme_color_override("font_color", TEXT_COLOR)
		vbox.add_child(move_label)

	return panel


# ─── HELPERS ─────────────────────────────────────────────────────────────────

func _add_section_header(text: String) -> void:
	var header := Label.new()
	header.text = text
	header.add_theme_font_size_override("font_size", 20)
	header.add_theme_color_override("font_color", TITLE_COLOR)
	header.custom_minimum_size = Vector2(1180, 35)
	_content_container.add_child(header)


func _add_spacer(height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	_content_container.add_child(spacer)


func _add_spacer_to(parent: Control, height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	parent.add_child(spacer)


func _create_grid(columns: int, h_sep: int) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", h_sep)
	grid.add_theme_constant_override("v_separation", 8)
	return grid


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
