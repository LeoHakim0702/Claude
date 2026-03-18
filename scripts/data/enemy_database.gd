class_name EnemyDatabase


static func get_all_enemies() -> Array[Resource]:
	var enemies: Array[Resource] = []
	enemies.append(_create_pirate_skiff())
	enemies.append(_create_jellyfish_swarm())
	enemies.append(_create_sea_serpent())
	enemies.append(_create_pirate_captain())
	enemies.append(_create_chen_zuyi())
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
