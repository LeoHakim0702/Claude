class_name EnemyDatabase


static func get_all_enemies() -> Array[Resource]:
	var enemies: Array[Resource] = []
	# Act 1
	enemies.append(_create_pirate_skiff())
	enemies.append(_create_jellyfish_swarm())
	enemies.append(_create_sea_serpent())
	enemies.append(_create_pirate_captain())
	enemies.append(_create_chen_zuyi())
	# Act 2
	enemies.append(_create_monsoon_wave())
	enemies.append(_create_arabian_corsair())
	enemies.append(_create_malabar_warrior())
	enemies.append(_create_ceylon_guardian())
	enemies.append(_create_calicut_armada())
	# Act 3
	enemies.append(_create_desert_raider())
	enemies.append(_create_persian_warship())
	enemies.append(_create_african_beast())
	enemies.append(_create_sultan_guard())
	enemies.append(_create_sea_dragon())
	return enemies


static func get_enemy(id: String) -> Resource:
	var all_enemies := get_all_enemies()
	for enemy in all_enemies:
		if (enemy as EnemyData).id == id:
			return enemy
	return null


static func get_act1_normal_pool() -> Array[Resource]:
	var pool: Array[Resource] = []
	pool.append(get_enemy("pirate_skiff"))
	pool.append(get_enemy("jellyfish_swarm"))
	pool.append(get_enemy("sea_serpent"))
	return pool


static func get_act1_elite_pool() -> Array[Resource]:
	var pool: Array[Resource] = []
	pool.append(get_enemy("pirate_captain"))
	return pool


static func get_act1_boss() -> Resource:
	return get_enemy("chen_zuyi")


static func get_act2_normal_pool() -> Array[Resource]:
	var pool: Array[Resource] = []
	pool.append(get_enemy("monsoon_wave"))
	pool.append(get_enemy("arabian_corsair"))
	pool.append(get_enemy("malabar_warrior"))
	return pool


static func get_act2_elite_pool() -> Array[Resource]:
	var pool: Array[Resource] = []
	pool.append(get_enemy("ceylon_guardian"))
	return pool


static func get_act2_boss() -> Resource:
	return get_enemy("calicut_armada")


static func get_act3_normal_pool() -> Array[Resource]:
	var pool: Array[Resource] = []
	pool.append(get_enemy("desert_raider"))
	pool.append(get_enemy("persian_warship"))
	pool.append(get_enemy("african_beast"))
	return pool


static func get_act3_elite_pool() -> Array[Resource]:
	var pool: Array[Resource] = []
	pool.append(get_enemy("sultan_guard"))
	return pool


static func get_act3_boss() -> Resource:
	return get_enemy("sea_dragon")


static func get_normal_pool_for_act(act: int) -> Array[Resource]:
	match act:
		1: return get_act1_normal_pool()
		2: return get_act2_normal_pool()
		3: return get_act3_normal_pool()
		_: return []


static func get_elite_pool_for_act(act: int) -> Array[Resource]:
	match act:
		1: return get_act1_elite_pool()
		2: return get_act2_elite_pool()
		3: return get_act3_elite_pool()
		_: return []


static func get_boss_for_act(act: int) -> Resource:
	match act:
		1: return get_act1_boss()
		2: return get_act2_boss()
		3: return get_act3_boss()
		_: return null


static func _create_pirate_skiff() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "pirate_skiff"
	enemy.enemy_name = "Pirate Skiff"
	enemy.enemy_name_zh = "海盗小船"
	enemy.type = EnemyData.EnemyType.NORMAL
	enemy.hp_min = 18
	enemy.hp_max = 22
	enemy.ai_type = "CYCLE"
	enemy.ai_params = {sequence = ["attack_slash", "attack_weak"]}
	enemy.moves = [
		{
			id = "attack_slash",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 7, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "attack_weak",
			intent_type = "ATTACK_DEFEND",
			effects = [
				{type = "DAMAGE", value = 5, target = "TARGET", hits = 1},
				{type = "APPLY_STATUS", value = 1, target = "TARGET", status_id = "weak"},
			] as Array[Dictionary],
			weight = 1.0,
		},
	] as Array[Dictionary]
	return enemy


static func _create_jellyfish_swarm() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "jellyfish_swarm"
	enemy.enemy_name = "Jellyfish Swarm"
	enemy.enemy_name_zh = "水母群"
	enemy.type = EnemyData.EnemyType.NORMAL
	enemy.hp_min = 25
	enemy.hp_max = 30
	enemy.ai_type = "RANDOM_WEIGHTED"
	enemy.ai_params = {}
	enemy.moves = [
		{
			id = "sting",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 3, target = "TARGET", hits = 3}] as Array[Dictionary],
			weight = 0.6,
		},
		{
			id = "venom",
			intent_type = "DEBUFF",
			effects = [{type = "APPLY_STATUS", value = 2, target = "TARGET", status_id = "burn"}] as Array[Dictionary],
			weight = 0.4,
		},
	] as Array[Dictionary]
	return enemy


static func _create_sea_serpent() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "sea_serpent"
	enemy.enemy_name = "Sea Serpent"
	enemy.enemy_name_zh = "海蛇"
	enemy.type = EnemyData.EnemyType.NORMAL
	enemy.hp_min = 30
	enemy.hp_max = 36
	enemy.ai_type = "CYCLE"
	enemy.ai_params = {sequence = ["bite", "coil", "lunge"]}
	enemy.moves = [
		{
			id = "bite",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 10, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "coil",
			intent_type = "DEFEND",
			effects = [{type = "BLOCK", value = 8, target = "SELF", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "lunge",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 14, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
	] as Array[Dictionary]
	return enemy


static func _create_pirate_captain() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "pirate_captain"
	enemy.enemy_name = "Pirate Captain"
	enemy.enemy_name_zh = "海盗头目"
	enemy.type = EnemyData.EnemyType.ELITE
	enemy.hp_min = 50
	enemy.hp_max = 60
	enemy.ai_type = "CYCLE"
	enemy.ai_params = {sequence = ["rally", "heavy_slash", "cannon_barrage"]}
	enemy.moves = [
		{
			id = "rally",
			intent_type = "BUFF",
			effects = [{type = "APPLY_STATUS", value = 2, target = "SELF", status_id = "strength"}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "heavy_slash",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 14, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "cannon_barrage",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 6, target = "TARGET", hits = 2}] as Array[Dictionary],
			weight = 1.0,
		},
	] as Array[Dictionary]
	return enemy


static func _create_chen_zuyi() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "chen_zuyi"
	enemy.enemy_name = "Chen Zuyi"
	enemy.enemy_name_zh = "陈祖义"
	enemy.type = EnemyData.EnemyType.BOSS
	enemy.hp_min = 90
	enemy.hp_max = 100
	enemy.ai_type = "CYCLE"
	enemy.ai_params = {sequence = ["taunt", "devastating_blow", "pirate_fleet", "plunder"]}
	enemy.moves = [
		{
			id = "taunt",
			intent_type = "BUFF",
			effects = [
				{type = "APPLY_STATUS", value = 1, target = "SELF", status_id = "strength"},
				{type = "BLOCK", value = 10, target = "SELF", hits = 1},
			] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "devastating_blow",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 20, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "pirate_fleet",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 5, target = "TARGET", hits = 4}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "plunder",
			intent_type = "ATTACK_DEFEND",
			effects = [
				{type = "DAMAGE", value = 12, target = "TARGET", hits = 1},
				{type = "APPLY_STATUS", value = 2, target = "TARGET", status_id = "weak"},
			] as Array[Dictionary],
			weight = 1.0,
		},
	] as Array[Dictionary]
	return enemy


# =============================================================================
# ACT 2 - Indian Ocean (印度洋)
# =============================================================================


static func _create_monsoon_wave() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "monsoon_wave"
	enemy.enemy_name = "Monsoon Wave"
	enemy.enemy_name_zh = "季风巨浪"
	enemy.type = EnemyData.EnemyType.NORMAL
	enemy.hp_min = 28
	enemy.hp_max = 34
	enemy.ai_type = "CYCLE"
	enemy.ai_params = {sequence = ["surge", "retreat", "surge", "crash"]}
	enemy.moves = [
		{
			id = "surge",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 9, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "retreat",
			intent_type = "DEFEND",
			effects = [{type = "BLOCK", value = 10, target = "SELF", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "crash",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 6, target = "TARGET", hits = 2}] as Array[Dictionary],
			weight = 1.0,
		},
	] as Array[Dictionary]
	return enemy


static func _create_arabian_corsair() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "arabian_corsair"
	enemy.enemy_name = "Arabian Corsair"
	enemy.enemy_name_zh = "阿拉伯海盗"
	enemy.type = EnemyData.EnemyType.NORMAL
	enemy.hp_min = 32
	enemy.hp_max = 38
	enemy.ai_type = "CYCLE"
	enemy.ai_params = {sequence = ["slash", "poison_dart", "rally"]}
	enemy.moves = [
		{
			id = "slash",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 11, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "poison_dart",
			intent_type = "DEBUFF",
			effects = [{type = "APPLY_STATUS", value = 3, target = "TARGET", status_id = "burn"}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "rally",
			intent_type = "BUFF",
			effects = [{type = "APPLY_STATUS", value = 2, target = "SELF", status_id = "strength"}] as Array[Dictionary],
			weight = 1.0,
		},
	] as Array[Dictionary]
	return enemy


static func _create_malabar_warrior() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "malabar_warrior"
	enemy.enemy_name = "Malabar Warrior"
	enemy.enemy_name_zh = "马拉巴尔战士"
	enemy.type = EnemyData.EnemyType.NORMAL
	enemy.hp_min = 35
	enemy.hp_max = 42
	enemy.ai_type = "RANDOM_WEIGHTED"
	enemy.ai_params = {}
	enemy.moves = [
		{
			id = "shield_bash",
			intent_type = "ATTACK_DEFEND",
			effects = [
				{type = "DAMAGE", value = 8, target = "TARGET", hits = 1},
				{type = "BLOCK", value = 6, target = "SELF", hits = 1},
			] as Array[Dictionary],
			weight = 0.4,
		},
		{
			id = "spear_thrust",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 13, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 0.35,
		},
		{
			id = "war_cry",
			intent_type = "BUFF",
			effects = [
				{type = "APPLY_STATUS", value = 1, target = "SELF", status_id = "strength"},
				{type = "APPLY_STATUS", value = 1, target = "TARGET", status_id = "weak"},
			] as Array[Dictionary],
			weight = 0.25,
		},
	] as Array[Dictionary]
	return enemy


static func _create_ceylon_guardian() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "ceylon_guardian"
	enemy.enemy_name = "Ceylon Guardian"
	enemy.enemy_name_zh = "锡兰守护者"
	enemy.type = EnemyData.EnemyType.ELITE
	enemy.hp_min = 65
	enemy.hp_max = 75
	enemy.ai_type = "CYCLE"
	enemy.ai_params = {sequence = ["gem_shield", "radiant_strike", "gem_shield", "divine_wrath"]}
	enemy.moves = [
		{
			id = "gem_shield",
			intent_type = "DEFEND",
			effects = [
				{type = "BLOCK", value = 15, target = "SELF", hits = 1},
				{type = "APPLY_STATUS", value = 1, target = "SELF", status_id = "thorns"},
			] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "radiant_strike",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 16, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "divine_wrath",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 8, target = "TARGET", hits = 3}] as Array[Dictionary],
			weight = 1.0,
		},
	] as Array[Dictionary]
	return enemy


static func _create_calicut_armada() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "calicut_armada"
	enemy.enemy_name = "Calicut Armada"
	enemy.enemy_name_zh = "古里舰队"
	enemy.type = EnemyData.EnemyType.BOSS
	enemy.hp_min = 120
	enemy.hp_max = 140
	enemy.ai_type = "CYCLE"
	enemy.ai_params = {sequence = ["formation", "broadside_volley", "ram", "formation", "arrow_rain", "trade_blockade"]}
	enemy.moves = [
		{
			id = "formation",
			intent_type = "BUFF",
			effects = [
				{type = "APPLY_STATUS", value = 2, target = "SELF", status_id = "strength"},
				{type = "BLOCK", value = 12, target = "SELF", hits = 1},
			] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "broadside_volley",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 7, target = "TARGET", hits = 3}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "ram",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 22, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "arrow_rain",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 4, target = "TARGET", hits = 5}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "trade_blockade",
			intent_type = "DEBUFF",
			effects = [
				{type = "APPLY_STATUS", value = 2, target = "TARGET", status_id = "weak"},
				{type = "APPLY_STATUS", value = 2, target = "TARGET", status_id = "vulnerable"},
			] as Array[Dictionary],
			weight = 1.0,
		},
	] as Array[Dictionary]
	return enemy


# =============================================================================
# ACT 3 - Middle East & Africa (西域非洲)
# =============================================================================


static func _create_desert_raider() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "desert_raider"
	enemy.enemy_name = "Desert Raider"
	enemy.enemy_name_zh = "沙漠劫匪"
	enemy.type = EnemyData.EnemyType.NORMAL
	enemy.hp_min = 38
	enemy.hp_max = 45
	enemy.ai_type = "CYCLE"
	enemy.ai_params = {sequence = ["ambush", "sandstorm", "strike", "flee"]}
	enemy.moves = [
		{
			id = "ambush",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 14, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "sandstorm",
			intent_type = "DEBUFF",
			effects = [
				{type = "APPLY_STATUS", value = 2, target = "TARGET", status_id = "weak"},
				{type = "APPLY_STATUS", value = 1, target = "TARGET", status_id = "vulnerable"},
			] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "strike",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 10, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "flee",
			intent_type = "DEFEND",
			effects = [{type = "BLOCK", value = 8, target = "SELF", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
	] as Array[Dictionary]
	return enemy


static func _create_persian_warship() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "persian_warship"
	enemy.enemy_name = "Persian Warship"
	enemy.enemy_name_zh = "波斯战舰"
	enemy.type = EnemyData.EnemyType.NORMAL
	enemy.hp_min = 42
	enemy.hp_max = 50
	enemy.ai_type = "CYCLE"
	enemy.ai_params = {sequence = ["cannon", "reinforce", "cannon", "ram"]}
	enemy.moves = [
		{
			id = "cannon",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 12, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "reinforce",
			intent_type = "DEFEND",
			effects = [{type = "BLOCK", value = 14, target = "SELF", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "ram",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 18, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
	] as Array[Dictionary]
	return enemy


static func _create_african_beast() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "african_beast"
	enemy.enemy_name = "African Beast"
	enemy.enemy_name_zh = "非洲猛兽"
	enemy.type = EnemyData.EnemyType.NORMAL
	enemy.hp_min = 45
	enemy.hp_max = 52
	enemy.ai_type = "RANDOM_WEIGHTED"
	enemy.ai_params = {}
	enemy.moves = [
		{
			id = "charge",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 16, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 0.4,
		},
		{
			id = "roar",
			intent_type = "BUFF",
			effects = [{type = "APPLY_STATUS", value = 2, target = "SELF", status_id = "strength"}] as Array[Dictionary],
			weight = 0.3,
		},
		{
			id = "trample",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 6, target = "TARGET", hits = 3}] as Array[Dictionary],
			weight = 0.3,
		},
	] as Array[Dictionary]
	return enemy


static func _create_sultan_guard() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "sultan_guard"
	enemy.enemy_name = "Sultan's Guard"
	enemy.enemy_name_zh = "苏丹禁卫军"
	enemy.type = EnemyData.EnemyType.ELITE
	enemy.hp_min = 80
	enemy.hp_max = 90
	enemy.ai_type = "CYCLE"
	enemy.ai_params = {sequence = ["rally_troops", "scimitar_dance", "shield_wall", "execute"]}
	enemy.moves = [
		{
			id = "rally_troops",
			intent_type = "BUFF",
			effects = [{type = "APPLY_STATUS", value = 3, target = "SELF", status_id = "strength"}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "scimitar_dance",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 8, target = "TARGET", hits = 3}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "shield_wall",
			intent_type = "DEFEND",
			effects = [
				{type = "BLOCK", value = 20, target = "SELF", hits = 1},
				{type = "APPLY_STATUS", value = 1, target = "SELF", status_id = "thorns"},
			] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "execute",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 25, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
	] as Array[Dictionary]
	return enemy


static func _create_sea_dragon() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = "sea_dragon"
	enemy.enemy_name = "Sea Dragon"
	enemy.enemy_name_zh = "海龙"
	enemy.type = EnemyData.EnemyType.BOSS
	enemy.hp_min = 160
	enemy.hp_max = 180
	enemy.ai_type = "CYCLE"
	enemy.ai_params = {sequence = ["tsunami", "coil", "devour", "tsunami", "breath", "submerge"]}
	enemy.moves = [
		{
			id = "tsunami",
			intent_type = "ATTACK",
			effects = [
				{type = "DAMAGE", value = 10, target = "TARGET", hits = 2},
				{type = "APPLY_STATUS", value = 1, target = "TARGET", status_id = "vulnerable"},
			] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "coil",
			intent_type = "DEFEND",
			effects = [
				{type = "BLOCK", value = 18, target = "SELF", hits = 1},
				{type = "APPLY_STATUS", value = 2, target = "SELF", status_id = "strength"},
			] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "devour",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 30, target = "TARGET", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "breath",
			intent_type = "ATTACK",
			effects = [{type = "DAMAGE", value = 6, target = "TARGET", hits = 4}] as Array[Dictionary],
			weight = 1.0,
		},
		{
			id = "submerge",
			intent_type = "DEFEND",
			effects = [{type = "BLOCK", value = 25, target = "SELF", hits = 1}] as Array[Dictionary],
			weight = 1.0,
		},
	] as Array[Dictionary]
	return enemy
