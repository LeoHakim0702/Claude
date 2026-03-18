class_name DiplomacyManager
extends RefCounted

## Manages diplomatic relationships with nations during a run.
## Tracks points, levels, and bonuses for each nation Zheng He visits.

# ── Diplomacy Cards ─────────────────────────────────────────────────────────────
# Cards to add to CardDatabase:
#
# "tribute_offering" / 朝贡
#   Cost 1 | SKILL | Target: SELF
#   Gain 5 block. Gain 3 diplomacy points to current act's primary nation.
#   Effects: [{type: "block", value: 5}, {type: "diplomacy_points", value: 3, target: "act_primary"}]
#   Tags: ["diplomacy"]
#
# "peace_envoy" / 和平使者
#   Cost 0 | SKILL | Target: NONE | Exhaust
#   Gain 2 diplomacy points to current act's primary nation. Draw 1 card.
#   Effects: [{type: "diplomacy_points", value: 2, target: "act_primary"}, {type: "draw", value: 1}]
#   Tags: ["diplomacy", "exhaust"]
#
# "silk_road_trade" / 丝路贸易
#   Cost 1 | SKILL | Target: NONE | Exhaust
#   Gain 5 diplomacy points to current act's primary nation. Gain 10 gold.
#   Effects: [{type: "diplomacy_points", value: 5, target: "act_primary"}, {type: "gold", value: 10}]
#   Tags: ["diplomacy", "exhaust"]
#
# "imperial_decree" / 天子诏书
#   Cost 2 | POWER | Target: SELF
#   Gain 1 diplomacy point to current act's primary nation at the start of each turn.
#   Effects: [{type: "diplomacy_points_per_turn", value: 1, target: "act_primary"}]
#   Tags: ["diplomacy"]
#
# "cultural_exchange" / 文化交流
#   Cost 1 | SKILL | Target: SINGLE_ENEMY
#   Gain 3 diplomacy points to current act's primary nation. Enemy loses 1 strength.
#   Effects: [{type: "diplomacy_points", value: 3, target: "act_primary"}, {type: "apply_status", status: "strength", value: -1}]
#   Tags: ["diplomacy"]
# ────────────────────────────────────────────────────────────────────────────────

const DIPLOMACY_CARD_DEFINITIONS: Array[Dictionary] = [
	{
		"id": "tribute_offering",
		"card_name": "Tribute Offering",
		"card_name_zh": "朝贡",
		"type": CardData.CardType.SKILL,
		"rarity": CardData.CardRarity.COMMON,
		"cost": 1,
		"description": "Gain 5 Block. Gain 3 diplomacy points with the current act's primary nation.",
		"description_zh": "获得5格挡。获得当前章节主要国家3点外交点数。",
		"effects": [
			{"type": "block", "value": 5},
			{"type": "diplomacy_points", "value": 3, "target": "act_primary"},
		],
		"target_mode": CardData.TargetMode.SELF,
		"tags": ["diplomacy"],
	},
	{
		"id": "peace_envoy",
		"card_name": "Peace Envoy",
		"card_name_zh": "和平使者",
		"type": CardData.CardType.SKILL,
		"rarity": CardData.CardRarity.UNCOMMON,
		"cost": 0,
		"description": "Gain 2 diplomacy points. Draw 1 card. Exhaust.",
		"description_zh": "获得2点外交点数。抽1张牌。消耗。",
		"effects": [
			{"type": "diplomacy_points", "value": 2, "target": "act_primary"},
			{"type": "draw", "value": 1},
		],
		"target_mode": CardData.TargetMode.NONE,
		"tags": ["diplomacy", "exhaust"],
	},
	{
		"id": "silk_road_trade",
		"card_name": "Silk Road Trade",
		"card_name_zh": "丝路贸易",
		"type": CardData.CardType.SKILL,
		"rarity": CardData.CardRarity.UNCOMMON,
		"cost": 1,
		"description": "Gain 5 diplomacy points. Gain 10 gold. Exhaust.",
		"description_zh": "获得5点外交点数。获得10金币。消耗。",
		"effects": [
			{"type": "diplomacy_points", "value": 5, "target": "act_primary"},
			{"type": "gold", "value": 10},
		],
		"target_mode": CardData.TargetMode.NONE,
		"tags": ["diplomacy", "exhaust"],
	},
	{
		"id": "imperial_decree",
		"card_name": "Imperial Decree",
		"card_name_zh": "天子诏书",
		"type": CardData.CardType.POWER,
		"rarity": CardData.CardRarity.RARE,
		"cost": 2,
		"description": "Gain 1 diplomacy point to the current act's primary nation at the start of each turn.",
		"description_zh": "每回合开始时获得当前章节主要国家1点外交点数。",
		"effects": [
			{"type": "diplomacy_points_per_turn", "value": 1, "target": "act_primary"},
		],
		"target_mode": CardData.TargetMode.SELF,
		"tags": ["diplomacy"],
	},
	{
		"id": "cultural_exchange",
		"card_name": "Cultural Exchange",
		"card_name_zh": "文化交流",
		"type": CardData.CardType.SKILL,
		"rarity": CardData.CardRarity.COMMON,
		"cost": 1,
		"description": "Gain 3 diplomacy points. Enemy loses 1 Strength.",
		"description_zh": "获得3点外交点数。敌人失去1点力量。",
		"effects": [
			{"type": "diplomacy_points", "value": 3, "target": "act_primary"},
			{"type": "apply_status", "status": "strength", "value": -1},
		],
		"target_mode": CardData.TargetMode.SINGLE_ENEMY,
		"tags": ["diplomacy"],
	},
]

# ── State ───────────────────────────────────────────────────────────────────────

var nation_points: Dictionary = {}   # {Nation enum -> int}
var nation_levels: Dictionary = {}   # {Nation enum -> RelationLevel enum}


func _init() -> void:
	for nation_value in DiplomacyData.Nation.values():
		nation_points[nation_value] = 0
		nation_levels[nation_value] = DiplomacyData.RelationLevel.UNKNOWN


# ── Points & Levels ─────────────────────────────────────────────────────────────

## Adds diplomacy points to a nation. Checks for level changes and emits signals.
func add_points(nation: int, amount: int) -> void:
	if not nation_points.has(nation):
		return
	var old_level: int = nation_levels[nation]
	nation_points[nation] += amount
	var new_level: int = DiplomacyData.get_level_for_points(nation_points[nation])
	nation_levels[nation] = new_level

	_emit_diplomacy_changed(nation, nation_points[nation], new_level)

	if new_level != old_level:
		_emit_diplomacy_level_up(nation, old_level, new_level)


## Returns the current diplomacy points for a nation.
func get_points(nation: int) -> int:
	if nation_points.has(nation):
		return nation_points[nation]
	return 0


## Returns the current RelationLevel for a nation.
func get_level(nation: int) -> int:
	if nation_levels.has(nation):
		return nation_levels[nation]
	return DiplomacyData.RelationLevel.UNKNOWN


## Returns the Chinese name for a RelationLevel.
func get_level_name(level: int) -> String:
	if DiplomacyData.RELATION_LEVEL_NAMES.has(level):
		return DiplomacyData.RELATION_LEVEL_NAMES[level]
	return "未知"


## Returns the Chinese name for a Nation.
func get_nation_name(nation: int) -> String:
	if DiplomacyData.NATION_INFO.has(nation):
		return DiplomacyData.NATION_INFO[nation]["name_zh"]
	return "未知"


# ── Bonuses ─────────────────────────────────────────────────────────────────────

## Returns the active bonuses for a single nation based on its current level.
func get_active_bonuses(nation: int) -> Array[Dictionary]:
	var level: int = get_level(nation)
	var bonuses: Array[Dictionary] = []
	if DiplomacyData.RELATION_BONUSES.has(level):
		for bonus in DiplomacyData.RELATION_BONUSES[level]:
			var entry: Dictionary = bonus.duplicate()
			entry["nation"] = nation
			bonuses.append(entry)
	return bonuses


## Returns all active bonuses combined from every nation.
func get_all_active_bonuses() -> Array[Dictionary]:
	var all_bonuses: Array[Dictionary] = []
	for nation_value in DiplomacyData.Nation.values():
		var bonuses := get_active_bonuses(nation_value)
		all_bonuses.append_array(bonuses)
	return all_bonuses


## Returns true if any nation currently provides the specified bonus type.
func has_bonus(bonus_type: String) -> bool:
	var all_bonuses := get_all_active_bonuses()
	for bonus in all_bonuses:
		if bonus["type"] == bonus_type:
			return true
	return false


## Returns the sum of a specific bonus type across all nations.
func get_total_bonus_value(bonus_type: String) -> float:
	var total: float = 0.0
	var all_bonuses := get_all_active_bonuses()
	for bonus in all_bonuses:
		if bonus["type"] == bonus_type:
			total += float(bonus["value"])
	return total


# ── Act Queries ─────────────────────────────────────────────────────────────────

## Returns the nations that belong to a given act number.
func get_nations_for_act(act: int) -> Array[int]:
	var result: Array[int] = []
	for nation_value in DiplomacyData.Nation.values():
		if DiplomacyData.NATION_INFO.has(nation_value):
			if DiplomacyData.NATION_INFO[nation_value]["act"] == act:
				result.append(nation_value)
	return result


## Returns the nation with the highest relation, as {nation, level, points}.
func get_highest_relation() -> Dictionary:
	var best_nation: int = DiplomacyData.Nation.CHAMPA
	var best_points: int = -999
	for nation_value in DiplomacyData.Nation.values():
		var pts: int = nation_points.get(nation_value, 0)
		if pts > best_points:
			best_points = pts
			best_nation = nation_value
	return {
		"nation": best_nation,
		"level": nation_levels.get(best_nation, DiplomacyData.RelationLevel.UNKNOWN),
		"points": best_points,
	}


# ── Serialization ──────────────────────────────────────────────────────────────

## Serializes the diplomacy state into a plain Dictionary for saving.
func serialize() -> Dictionary:
	var points_data: Dictionary = {}
	var levels_data: Dictionary = {}
	for nation_value in DiplomacyData.Nation.values():
		var key := str(nation_value)
		points_data[key] = nation_points.get(nation_value, 0)
		levels_data[key] = nation_levels.get(nation_value, DiplomacyData.RelationLevel.UNKNOWN)
	return {
		"nation_points": points_data,
		"nation_levels": levels_data,
	}


## Restores the diplomacy state from a previously serialized Dictionary.
func deserialize(data: Dictionary) -> void:
	if data.has("nation_points"):
		for key in data["nation_points"]:
			var nation_value: int = int(key)
			nation_points[nation_value] = int(data["nation_points"][key])
	if data.has("nation_levels"):
		for key in data["nation_levels"]:
			var nation_value: int = int(key)
			nation_levels[nation_value] = int(data["nation_levels"][key])


# ── EventBus Integration ───────────────────────────────────────────────────────

func _emit_diplomacy_changed(nation: int, points: int, level: int) -> void:
	EventBus.diplomacy_changed.emit(nation, points, level)


func _emit_diplomacy_level_up(nation: int, _old_level: int, new_level: int) -> void:
	EventBus.diplomacy_level_up.emit(nation, new_level)
