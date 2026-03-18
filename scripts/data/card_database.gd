class_name CardDatabase


static func _create_card(
	p_id: String,
	p_name: String,
	p_name_zh: String,
	p_type: int,
	p_rarity: int,
	p_cost: int,
	p_target_mode: int,
	p_effects: Array[Dictionary],
	p_description: String = "",
	p_description_zh: String = "",
) -> CardData:
	var card := CardData.new()
	card.id = p_id
	card.card_name = p_name
	card.card_name_zh = p_name_zh
	card.type = p_type
	card.rarity = p_rarity
	card.cost = p_cost
	card.target_mode = p_target_mode
	card.effects = p_effects
	card.description = p_description
	card.description_zh = p_description_zh
	return card


static func get_all_cards() -> Array[Resource]:
	var cards: Array[Resource] = []

	# Strike
	cards.append(_create_card(
		"strike", "Strike", "攻击",
		CardData.CardType.ATTACK, CardData.CardRarity.STARTER, 1,
		CardData.TargetMode.SINGLE_ENEMY,
		[{type = "DAMAGE", value = 6, target = "TARGET", hits = 1}] as Array[Dictionary],
		"Deal 6 damage.", "造成6点伤害。"
	))

	# Defend
	cards.append(_create_card(
		"defend", "Defend", "防御",
		CardData.CardType.SKILL, CardData.CardRarity.STARTER, 1,
		CardData.TargetMode.SELF,
		[{type = "BLOCK", value = 5, target = "SELF", hits = 1}] as Array[Dictionary],
		"Gain 5 Block.", "获得5点格挡。"
	))

	# Cannon Shot
	cards.append(_create_card(
		"cannon_shot", "Cannon Shot", "火炮射击",
		CardData.CardType.ATTACK, CardData.CardRarity.STARTER, 1,
		CardData.TargetMode.SINGLE_ENEMY,
		[{type = "DAMAGE", value = 7, target = "TARGET", hits = 1}] as Array[Dictionary],
		"Deal 7 damage.", "造成7点伤害。"
	))

	# Brace Hull
	cards.append(_create_card(
		"brace_hull", "Brace Hull", "加固船体",
		CardData.CardType.SKILL, CardData.CardRarity.STARTER, 1,
		CardData.TargetMode.SELF,
		[{type = "BLOCK", value = 6, target = "SELF", hits = 1}] as Array[Dictionary],
		"Gain 6 Block.", "获得6点格挡。"
	))

	# Rally Crew
	cards.append(_create_card(
		"rally_crew", "Rally Crew", "集结水手",
		CardData.CardType.SKILL, CardData.CardRarity.STARTER, 0,
		CardData.TargetMode.NONE,
		[{type = "DRAW", value = 1, target = "SELF", hits = 1}] as Array[Dictionary],
		"Draw 1 card.", "抽1张牌。"
	))

	# Broadside
	cards.append(_create_card(
		"broadside", "Broadside", "舷炮齐射",
		CardData.CardType.ATTACK, CardData.CardRarity.COMMON, 2,
		CardData.TargetMode.ALL_ENEMIES,
		[{type = "DAMAGE_ALL", value = 8, target = "ALL_ENEMIES", hits = 1}] as Array[Dictionary],
		"Deal 8 damage to ALL enemies.", "对所有敌人造成8点伤害。"
	))

	# Sea Gale
	cards.append(_create_card(
		"sea_gale", "Sea Gale", "海上狂风",
		CardData.CardType.SKILL, CardData.CardRarity.COMMON, 1,
		CardData.TargetMode.ALL_ENEMIES,
		[{type = "APPLY_STATUS", value = 2, target = "ALL_ENEMIES", status_id = "vulnerable", hits = 1}] as Array[Dictionary],
		"Apply 2 Vulnerable to ALL enemies.", "对所有敌人施加2层易伤。"
	))

	# Monsoon Wind
	cards.append(_create_card(
		"monsoon_wind", "Monsoon Wind", "季风",
		CardData.CardType.SKILL, CardData.CardRarity.UNCOMMON, 1,
		CardData.TargetMode.NONE,
		[
			{type = "GAIN_ENERGY", value = 2, target = "SELF", hits = 1},
			{type = "EXHAUST_SELF", value = 0, target = "SELF", hits = 1},
		] as Array[Dictionary],
		"Gain 2 Energy. Exhaust.", "获得2点能量。消耗。"
	))

	# Iron Volley
	cards.append(_create_card(
		"iron_volley", "Iron Volley", "铁炮齐射",
		CardData.CardType.ATTACK, CardData.CardRarity.UNCOMMON, 2,
		CardData.TargetMode.SINGLE_ENEMY,
		[{type = "DAMAGE", value = 4, target = "TARGET", hits = 3}] as Array[Dictionary],
		"Deal 4 damage 3 times.", "造成4点伤害，共3次。"
	))

	# Reinforced Hull
	cards.append(_create_card(
		"reinforced_hull", "Reinforced Hull", "加固船壳",
		CardData.CardType.SKILL, CardData.CardRarity.UNCOMMON, 2,
		CardData.TargetMode.SELF,
		[{type = "BLOCK", value = 12, target = "SELF", hits = 1}] as Array[Dictionary],
		"Gain 12 Block.", "获得12点格挡。"
	))

	# Silk Trade
	cards.append(_create_card(
		"silk_trade", "Silk Trade", "丝绸贸易",
		CardData.CardType.SKILL, CardData.CardRarity.COMMON, 0,
		CardData.TargetMode.NONE,
		[
			{type = "DRAW", value = 2, target = "SELF", hits = 1},
			{type = "EXHAUST_SELF", value = 0, target = "SELF", hits = 1},
		] as Array[Dictionary],
		"Draw 2 cards. Exhaust.", "抽2张牌。消耗。"
	))

	# Dragon Figurehead
	cards.append(_create_card(
		"dragon_figurehead", "Dragon Figurehead", "龙首雕像",
		CardData.CardType.POWER, CardData.CardRarity.RARE, 2,
		CardData.TargetMode.NONE,
		[{type = "APPLY_STATUS", value = 1, target = "SELF", status_id = "thorns", hits = 1}] as Array[Dictionary],
		"Gain 1 Thorns.", "获得1层荆棘。"
	))

	return cards


static func get_card(id: String) -> Resource:
	var all_cards := get_all_cards()
	for card in all_cards:
		if (card as CardData).id == id:
			return card
	return null


static func get_starter_deck() -> Array[Resource]:
	var deck: Array[Resource] = []

	# 4x Strike
	for i in range(4):
		deck.append((get_card("strike") as CardData).duplicate_card())

	# 3x Defend
	for i in range(3):
		deck.append((get_card("defend") as CardData).duplicate_card())

	# 1x Cannon Shot
	deck.append((get_card("cannon_shot") as CardData).duplicate_card())

	# 1x Brace Hull
	deck.append((get_card("brace_hull") as CardData).duplicate_card())

	# 1x Rally Crew
	deck.append((get_card("rally_crew") as CardData).duplicate_card())

	return deck
