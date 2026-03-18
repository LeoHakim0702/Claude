class_name RelicDatabase


static func _create_relic(
	p_id: String,
	p_name: String,
	p_name_zh: String,
	p_rarity: int,
	p_description: String,
	p_description_zh: String,
	p_trigger_event: String,
	p_effect_type: String,
	p_effect_value: int,
	p_effect_params: Dictionary = {},
) -> RelicData:
	var relic := RelicData.new()
	relic.id = p_id
	relic.relic_name = p_name
	relic.relic_name_zh = p_name_zh
	relic.rarity = p_rarity
	relic.description = p_description
	relic.description_zh = p_description_zh
	relic.trigger_event = p_trigger_event
	relic.effect_type = p_effect_type
	relic.effect_value = p_effect_value
	relic.effect_params = p_effect_params
	return relic


static func get_all_relics() -> Array[Resource]:
	var relics: Array[Resource] = []

	# ========== STARTER ==========

	# Compass - Draw 1 extra card at combat start
	relics.append(_create_relic(
		"compass", "Compass", "罗盘",
		RelicData.RelicRarity.STARTER,
		"At the start of each combat, draw 1 extra card.",
		"每场战斗开始时，额外抽1张牌。",
		"combat_started", "DRAW_EXTRA", 1
	))

	# ========== COMMON ==========

	# Silk Bolt - Gain gold after combat
	relics.append(_create_relic(
		"silk_bolt", "Silk Bolt", "丝绸",
		RelicData.RelicRarity.COMMON,
		"Gain 3 Gold after each combat.",
		"每场战斗胜利后，获得3金币。",
		"combat_won", "GAIN_GOLD", 3
	))

	# Porcelain Vase - Heal after combat
	relics.append(_create_relic(
		"porcelain_vase", "Porcelain Vase", "青花瓷瓶",
		RelicData.RelicRarity.COMMON,
		"Heal 3 HP after each combat.",
		"每场战斗胜利后，恢复3点生命值。",
		"combat_won", "HEAL", 3
	))

	# Spice Pouch - Extra energy on turn 1
	relics.append(_create_relic(
		"spice_pouch", "Spice Pouch", "香料袋",
		RelicData.RelicRarity.COMMON,
		"Gain 1 extra Energy on turn 1 of each combat.",
		"每场战斗第1回合获得1点额外能量。",
		"combat_started", "ENERGY_FIRST_TURN", 1
	))

	# Coral Charm - Start combat with Block
	relics.append(_create_relic(
		"coral_charm", "Coral Charm", "珊瑚护符",
		RelicData.RelicRarity.COMMON,
		"Start each combat with 5 Block.",
		"每场战斗开始时获得5点格挡。",
		"combat_started", "START_BLOCK", 5
	))

	# Jade Pendant - Draw on Power card play
	relics.append(_create_relic(
		"jade_pendant", "Jade Pendant", "玉佩",
		RelicData.RelicRarity.COMMON,
		"Whenever you play a Power card, draw 1 card.",
		"每当你打出一张能力牌，抽1张牌。",
		"card_played", "POWER_DRAW", 1
	))

	# Star Chart - Extra card choice at rewards
	relics.append(_create_relic(
		"star_chart", "Star Chart", "星图",
		RelicData.RelicRarity.COMMON,
		"+1 card choice at card reward screens.",
		"卡牌奖励界面多1个选择。",
		"reward_screen", "EXTRA_CARD_CHOICE", 1
	))

	# ========== UNCOMMON ==========

	# Ambergris - Draw when hand is empty at end of turn
	relics.append(_create_relic(
		"ambergris", "Ambergris", "龙涎香",
		RelicData.RelicRarity.UNCOMMON,
		"At the end of your turn, if you have 0 cards in hand, draw 2.",
		"回合结束时，如果手牌为0，抽2张牌。",
		"player_turn_ended", "EMPTY_HAND_DRAW", 2
	))

	# Ivory Tusk - First Attack each turn deals extra damage
	relics.append(_create_relic(
		"ivory_tusk", "Ivory Tusk", "象牙",
		RelicData.RelicRarity.UNCOMMON,
		"The first Attack you play each turn deals 3 extra damage.",
		"每回合你打出的第一张攻击牌额外造成3点伤害。",
		"card_played", "FIRST_ATTACK_BONUS", 3
	))

	# Rhinoceros Horn - Block when enemy intends to attack
	relics.append(_create_relic(
		"rhinoceros_horn", "Rhinoceros Horn", "犀牛角",
		RelicData.RelicRarity.UNCOMMON,
		"Whenever an enemy intends to attack, gain 2 Block.",
		"每当敌人意图攻击时，获得2点格挡。",
		"enemy_turn_started", "BLOCK_VS_ATTACK", 2
	))

	# Navigation Charts - Extra healing at rest sites
	relics.append(_create_relic(
		"navigation_charts", "Navigation Charts", "郑和航海图",
		RelicData.RelicRarity.UNCOMMON,
		"At rest sites, heal 5 extra HP.",
		"在休息点额外恢复5点生命值。",
		"rest_heal", "EXTRA_REST_HEAL", 5
	))

	# ========== RARE ==========

	# Ceylon Gems - Gain Strength at combat start
	relics.append(_create_relic(
		"ceylon_gems", "Ceylon Gems", "锡兰宝石",
		RelicData.RelicRarity.RARE,
		"Gain 1 Strength at the start of each combat.",
		"每场战斗开始时获得1点力量。",
		"combat_started", "START_STRENGTH", 1
	))

	# Qilin Tribute - Emergency heal when HP drops below 50%
	relics.append(_create_relic(
		"qilin_tribute", "Qilin Tribute", "麒麟贡品",
		RelicData.RelicRarity.RARE,
		"The first time your HP drops below 50% in combat, heal 15 HP.",
		"每场战斗中，生命值首次降至50%以下时，恢复15点生命值。",
		"hp_changed", "EMERGENCY_HEAL", 15
	))

	# ========== BOSS ==========

	# Yongle Sword - All Attacks deal extra damage
	relics.append(_create_relic(
		"yongle_sword", "Yongle Sword", "永乐剑",
		RelicData.RelicRarity.BOSS,
		"All Attacks deal 2 extra damage.",
		"所有攻击牌额外造成2点伤害。",
		"damage_dealt", "FLAT_ATTACK_BONUS", 2
	))

	# Imperial Seal - Extra max energy each combat
	relics.append(_create_relic(
		"imperial_seal", "Imperial Seal", "天子玺印",
		RelicData.RelicRarity.BOSS,
		"Start each combat with 1 extra Energy for the rest of combat.",
		"每场战斗中，最大能量增加1点。",
		"combat_started", "MAX_ENERGY_UP", 1
	))

	# ========== EVENT ==========

	# Golden Silk Robe - Max HP up on pickup
	relics.append(_create_relic(
		"golden_silk_robe", "Golden Silk Robe", "金丝龙袍",
		RelicData.RelicRarity.EVENT,
		"+10 Max HP when obtained.",
		"获得时，最大生命值增加10点。",
		"on_pickup", "MAX_HP_UP", 10
	))

	return relics


static func get_relic(id: String) -> Resource:
	var all_relics := get_all_relics()
	for relic in all_relics:
		if (relic as RelicData).id == id:
			return relic
	return null


static func get_relics_by_rarity(rarity: int) -> Array[Resource]:
	var result: Array[Resource] = []
	var all_relics := get_all_relics()
	for relic in all_relics:
		if (relic as RelicData).rarity == rarity:
			result.append(relic)
	return result


static func get_random_relic(rng: RandomNumberGenerator, rarity: int = -1) -> Resource:
	var pool: Array[Resource] = []

	if rarity == -1:
		# Any rarity except STARTER and BOSS
		var all_relics := get_all_relics()
		for relic in all_relics:
			var r := relic as RelicData
			if r.rarity != RelicData.RelicRarity.STARTER and r.rarity != RelicData.RelicRarity.BOSS:
				pool.append(relic)
	else:
		pool = get_relics_by_rarity(rarity)

	if pool.is_empty():
		return null

	var index := rng.randi_range(0, pool.size() - 1)
	return pool[index]
