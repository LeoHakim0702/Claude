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

	# ---- DIPLOMACY CARDS ----

	# Tribute Offering
	cards.append(_create_card(
		"tribute_offering", "Tribute Offering", "朝贡",
		CardData.CardType.SKILL, CardData.CardRarity.COMMON, 1,
		CardData.TargetMode.SELF,
		[
			{type = "BLOCK", value = 5, target = "SELF", hits = 1},
			{type = "DIPLOMACY", value = 3, target = "SELF", hits = 1},
		] as Array[Dictionary],
		"Gain 5 Block. Gain 3 Diplomacy points.", "获得5点格挡。获得3点外交点数。"
	))

	# Peace Envoy
	cards.append(_create_card(
		"peace_envoy", "Peace Envoy", "和平使者",
		CardData.CardType.SKILL, CardData.CardRarity.COMMON, 0,
		CardData.TargetMode.NONE,
		[
			{type = "DIPLOMACY", value = 2, target = "SELF", hits = 1},
			{type = "DRAW", value = 1, target = "SELF", hits = 1},
			{type = "EXHAUST_SELF", value = 0, target = "SELF", hits = 1},
		] as Array[Dictionary],
		"Gain 2 Diplomacy. Draw 1. Exhaust.", "获得2点外交。抽1张牌。消耗。"
	))

	# Silk Road Trade
	cards.append(_create_card(
		"silk_road_trade", "Silk Road Trade", "丝路贸易",
		CardData.CardType.SKILL, CardData.CardRarity.UNCOMMON, 1,
		CardData.TargetMode.NONE,
		[
			{type = "DIPLOMACY", value = 5, target = "SELF", hits = 1},
			{type = "GAIN_GOLD", value = 10, target = "SELF", hits = 1},
			{type = "EXHAUST_SELF", value = 0, target = "SELF", hits = 1},
		] as Array[Dictionary],
		"Gain 5 Diplomacy. Gain 10 Gold. Exhaust.", "获得5点外交。获得10金币。消耗。"
	))

	# Imperial Decree
	cards.append(_create_card(
		"imperial_decree", "Imperial Decree", "天子诏书",
		CardData.CardType.POWER, CardData.CardRarity.RARE, 2,
		CardData.TargetMode.NONE,
		[{type = "DIPLOMACY_PER_TURN", value = 1, target = "SELF", hits = 1}] as Array[Dictionary],
		"Gain 1 Diplomacy at start of each turn.", "每回合开始获得1点外交点数。"
	))

	# Cultural Exchange
	cards.append(_create_card(
		"cultural_exchange", "Cultural Exchange", "文化交流",
		CardData.CardType.SKILL, CardData.CardRarity.UNCOMMON, 1,
		CardData.TargetMode.SINGLE_ENEMY,
		[
			{type = "DIPLOMACY", value = 3, target = "SELF", hits = 1},
			{type = "APPLY_STATUS", value = 1, target = "TARGET", status_id = "weak", hits = 1},
		] as Array[Dictionary],
		"Gain 3 Diplomacy. Apply 1 Weak.", "获得3点外交。施加1层虚弱。"
	))

	# ---- ACT 2 THEMED CARDS (Indian Ocean) ----

	# Spice Wind
	cards.append(_create_card(
		"spice_wind", "Spice Wind", "香料之风",
		CardData.CardType.SKILL, CardData.CardRarity.COMMON, 1,
		CardData.TargetMode.SELF,
		[
			{type = "BLOCK", value = 8, target = "SELF", hits = 1},
			{type = "DRAW", value = 1, target = "SELF", hits = 1},
		] as Array[Dictionary],
		"Gain 8 Block. Draw 1.", "获得8点格挡。抽1张牌。"
	))

	# Monsoon Sail
	cards.append(_create_card(
		"monsoon_sail", "Monsoon Sail", "乘风破浪",
		CardData.CardType.ATTACK, CardData.CardRarity.COMMON, 1,
		CardData.TargetMode.SINGLE_ENEMY,
		[
			{type = "DAMAGE", value = 9, target = "TARGET", hits = 1},
			{type = "APPLY_STATUS", value = 1, target = "TARGET", status_id = "vulnerable", hits = 1},
		] as Array[Dictionary],
		"Deal 9 damage. Apply 1 Vulnerable.", "造成9点伤害。施加1层易伤。"
	))

	# Treasure Fleet
	cards.append(_create_card(
		"treasure_fleet", "Treasure Fleet", "宝船",
		CardData.CardType.POWER, CardData.CardRarity.RARE, 3,
		CardData.TargetMode.NONE,
		[
			{type = "APPLY_STATUS", value = 2, target = "SELF", status_id = "strength", hits = 1},
			{type = "APPLY_STATUS", value = 2, target = "SELF", status_id = "dexterity", hits = 1},
		] as Array[Dictionary],
		"Gain 2 Strength. Gain 2 Dexterity.", "获得2点力量。获得2点灵巧。"
	))

	# Star Navigation
	cards.append(_create_card(
		"star_navigation", "Star Navigation", "星象导航",
		CardData.CardType.SKILL, CardData.CardRarity.UNCOMMON, 0,
		CardData.TargetMode.NONE,
		[
			{type = "DRAW", value = 3, target = "SELF", hits = 1},
			{type = "EXHAUST_SELF", value = 0, target = "SELF", hits = 1},
		] as Array[Dictionary],
		"Draw 3 cards. Exhaust.", "抽3张牌。消耗。"
	))

	# Anchor Strike
	cards.append(_create_card(
		"anchor_strike", "Anchor Strike", "铁锚重击",
		CardData.CardType.ATTACK, CardData.CardRarity.UNCOMMON, 2,
		CardData.TargetMode.SINGLE_ENEMY,
		[
			{type = "DAMAGE", value = 14, target = "TARGET", hits = 1},
			{type = "APPLY_STATUS", value = 2, target = "TARGET", status_id = "vulnerable", hits = 1},
		] as Array[Dictionary],
		"Deal 14 damage. Apply 2 Vulnerable.", "造成14点伤害。施加2层易伤。"
	))

	# ---- ACT 3 THEMED CARDS (Middle East/Africa) ----

	# Desert Mirage
	cards.append(_create_card(
		"desert_mirage", "Desert Mirage", "海市蜃楼",
		CardData.CardType.SKILL, CardData.CardRarity.UNCOMMON, 1,
		CardData.TargetMode.SELF,
		[
			{type = "BLOCK", value = 6, target = "SELF", hits = 1},
			{type = "BLOCK", value = 6, target = "SELF", hits = 1},
		] as Array[Dictionary],
		"Gain 6 Block twice.", "获得6点格挡，共两次。"
	))

	# African Drums
	cards.append(_create_card(
		"african_drums", "African Drums", "非洲战鼓",
		CardData.CardType.SKILL, CardData.CardRarity.COMMON, 1,
		CardData.TargetMode.NONE,
		[
			{type = "APPLY_STATUS", value = 1, target = "SELF", status_id = "strength", hits = 1},
			{type = "DRAW", value = 1, target = "SELF", hits = 1},
		] as Array[Dictionary],
		"Gain 1 Strength. Draw 1.", "获得1点力量。抽1张牌。"
	))

	# Persian Fire
	cards.append(_create_card(
		"persian_fire", "Persian Fire", "波斯火",
		CardData.CardType.ATTACK, CardData.CardRarity.UNCOMMON, 2,
		CardData.TargetMode.ALL_ENEMIES,
		[
			{type = "DAMAGE_ALL", value = 6, target = "ALL_ENEMIES", hits = 1},
			{type = "APPLY_STATUS", value = 3, target = "ALL_ENEMIES", status_id = "burn", hits = 1},
		] as Array[Dictionary],
		"Deal 6 damage to ALL. Apply 3 Burn to ALL.", "对所有敌人造成6点伤害。施加3层灼烧。"
	))

	# Ivory Shield
	cards.append(_create_card(
		"ivory_shield", "Ivory Shield", "象牙盾",
		CardData.CardType.SKILL, CardData.CardRarity.COMMON, 2,
		CardData.TargetMode.SELF,
		[
			{type = "BLOCK", value = 14, target = "SELF", hits = 1},
			{type = "APPLY_STATUS", value = 1, target = "SELF", status_id = "thorns", hits = 1},
		] as Array[Dictionary],
		"Gain 14 Block. Gain 1 Thorns.", "获得14点格挡。获得1层荆棘。"
	))

	# Qilin Blessing
	cards.append(_create_card(
		"qilin_blessing", "Qilin Blessing", "麒麟祝福",
		CardData.CardType.SKILL, CardData.CardRarity.RARE, 1,
		CardData.TargetMode.NONE,
		[
			{type = "HEAL", value = 8, target = "SELF", hits = 1},
			{type = "DRAW", value = 2, target = "SELF", hits = 1},
			{type = "EXHAUST_SELF", value = 0, target = "SELF", hits = 1},
		] as Array[Dictionary],
		"Heal 8 HP. Draw 2. Exhaust.", "恢复8点生命值。抽2张牌。消耗。"
	))

	# Zheng He's Command
	cards.append(_create_card(
		"zheng_he_command", "Zheng He's Command", "郑和号令",
		CardData.CardType.POWER, CardData.CardRarity.RARE, 3,
		CardData.TargetMode.NONE,
		[
			{type = "APPLY_STATUS", value = 1, target = "SELF", status_id = "strength", hits = 1},
			{type = "APPLY_STATUS", value = 1, target = "SELF", status_id = "dexterity", hits = 1},
			{type = "DRAW", value = 1, target = "SELF", hits = 1},
		] as Array[Dictionary],
		"Gain 1 Str, 1 Dex, draw 1. At start of turn gain 1 Str.",
		"获得1力量，1灵巧，抽1张牌。每回合开始获得1力量。"
	))

	return cards


static func get_card(id: String) -> Resource:
	var all_cards := get_all_cards()
	for card in all_cards:
		if (card as CardData).id == id:
			return card
	return null


static func get_cards_by_rarity(rarity: int) -> Array[Resource]:
	var result: Array[Resource] = []
	for card in get_all_cards():
		if (card as CardData).rarity == rarity:
			result.append(card)
	return result


static func get_cards_for_act(act: int) -> Array[Resource]:
	var result: Array[Resource] = []
	var act2_ids := [
		"spice_wind", "monsoon_sail", "treasure_fleet",
		"star_navigation", "anchor_strike",
	]
	var act3_ids := [
		"desert_mirage", "african_drums", "persian_fire",
		"ivory_shield", "qilin_blessing", "zheng_he_command",
	]
	for card in get_all_cards():
		var cd := card as CardData
		match act:
			1:
				if cd.rarity == CardData.CardRarity.STARTER or cd.rarity == CardData.CardRarity.COMMON:
					result.append(card)
			2:
				if cd.rarity == CardData.CardRarity.STARTER or cd.rarity == CardData.CardRarity.COMMON:
					result.append(card)
				elif cd.rarity == CardData.CardRarity.UNCOMMON and cd.id in act2_ids:
					result.append(card)
			3:
				if cd.rarity == CardData.CardRarity.STARTER or cd.rarity == CardData.CardRarity.COMMON:
					result.append(card)
				elif cd.rarity == CardData.CardRarity.UNCOMMON:
					result.append(card)
				elif cd.rarity == CardData.CardRarity.RARE and cd.id in act3_ids:
					result.append(card)
				elif cd.rarity == CardData.CardRarity.RARE:
					result.append(card)
	return result


static func get_diplomacy_cards() -> Array[Resource]:
	var result: Array[Resource] = []
	for card in get_all_cards():
		var cd := card as CardData
		for effect in cd.effects:
			if effect.type == "DIPLOMACY" or effect.type == "DIPLOMACY_PER_TURN":
				result.append(card)
				break
	return result


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
