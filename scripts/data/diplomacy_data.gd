class_name DiplomacyData
extends RefCounted

## Static data for the diplomacy system.
## Defines nations Zheng He visited, relationship levels, thresholds, and bonuses.

# Each nation/kingdom Zheng He visited
enum Nation {
	CHAMPA,       # 占城 (Vietnam)
	MAJAPAHIT,    # 满者伯夷 (Java)
	PALEMBANG,    # 旧港 (Sumatra)
	MALACCA,      # 满剌加 (Malacca)
	CALICUT,      # 古里 (India)
	HORMUZ,       # 霍尔木兹 (Persia)
	MOGADISHU,    # 摩加迪沙 (East Africa)
	ADEN,         # 亚丁 (Arabia)
}

# Relationship levels
enum RelationLevel {
	HOSTILE,      # 敌对: combat penalties
	UNKNOWN,      # 未知: neutral default
	CONTACTED,    # 接触: basic trade
	FRIENDLY,     # 友好: discounts, extra events
	ALLIED,       # 同盟: powerful bonuses, skip combats
}

# ── Nation Info ──────────────────────────────────────────────────────────────────

const NATION_INFO: Dictionary = {
	Nation.CHAMPA: {
		"name": "Champa",
		"name_zh": "占城",
		"description": "A coastal kingdom in central Vietnam, known for its maritime trade and Hindu-Buddhist culture. One of the first ports Zheng He's fleet visited.",
		"description_zh": "位于越南中部的沿海王国，以海上贸易和印度教佛教文化闻名。郑和船队最先到达的港口之一。",
		"act": 1,
	},
	Nation.MAJAPAHIT: {
		"name": "Majapahit",
		"name_zh": "满者伯夷",
		"description": "The great Javanese empire controlling much of the Indonesian archipelago. A center of spice trade and naval power.",
		"description_zh": "控制印度尼西亚群岛大部分地区的爪哇大帝国。香料贸易和海军力量的中心。",
		"act": 1,
	},
	Nation.PALEMBANG: {
		"name": "Palembang",
		"name_zh": "旧港",
		"description": "A Sumatran port city and former Srivijaya capital. Zheng He helped establish order here by defeating the pirate Chen Zuyi.",
		"description_zh": "苏门答腊港口城市，前三佛齐首都。郑和在此击败海盗陈祖义，帮助恢复秩序。",
		"act": 1,
	},
	Nation.MALACCA: {
		"name": "Malacca",
		"name_zh": "满剌加",
		"description": "Strategic sultanate controlling the strait between Sumatra and the Malay Peninsula. A crucial trade hub for East-West commerce.",
		"description_zh": "控制苏门答腊和马来半岛之间海峡的战略苏丹国。东西方贸易的重要枢纽。",
		"act": 2,
	},
	Nation.CALICUT: {
		"name": "Calicut",
		"name_zh": "古里",
		"description": "A prosperous port city on India's Malabar Coast, ruled by the Zamorin. Famous for its pepper trade and cosmopolitan markets.",
		"description_zh": "印度马拉巴尔海岸繁荣的港口城市，由扎莫林统治。以胡椒贸易和国际化市场闻名。",
		"act": 2,
	},
	Nation.HORMUZ: {
		"name": "Hormuz",
		"name_zh": "霍尔木兹",
		"description": "An island kingdom at the entrance of the Persian Gulf. A wealthy entrepot for pearls, horses, and precious goods.",
		"description_zh": "位于波斯湾入口的岛屿王国。珍珠、马匹和珍贵商品的富裕贸易中心。",
		"act": 3,
	},
	Nation.MOGADISHU: {
		"name": "Mogadishu",
		"name_zh": "摩加迪沙",
		"description": "A Somali coastal city-state and key port on the East African trade network. Known for its textiles and connection to inland trade routes.",
		"description_zh": "索马里沿海城邦，东非贸易网络的重要港口。以纺织品和内陆贸易路线闻名。",
		"act": 3,
	},
	Nation.ADEN: {
		"name": "Aden",
		"name_zh": "亚丁",
		"description": "A vital Arabian port city at the mouth of the Red Sea. Gateway to Egypt and the Mediterranean trade routes.",
		"description_zh": "位于红海入口的重要阿拉伯港口城市。通往埃及和地中海贸易路线的门户。",
		"act": 3,
	},
}

# ── Relationship Thresholds ─────────────────────────────────────────────────────

const RELATION_THRESHOLDS: Dictionary = {
	RelationLevel.HOSTILE: -999,
	RelationLevel.UNKNOWN: 0,
	RelationLevel.CONTACTED: 10,
	RelationLevel.FRIENDLY: 30,
	RelationLevel.ALLIED: 60,
}

# ── Relationship Bonuses ────────────────────────────────────────────────────────

const RELATION_BONUSES: Dictionary = {
	RelationLevel.HOSTILE: [],
	RelationLevel.UNKNOWN: [],
	RelationLevel.CONTACTED: [
		{"type": "shop_discount", "value": 10},
	],
	RelationLevel.FRIENDLY: [
		{"type": "shop_discount", "value": 20},
		{"type": "extra_event_option", "value": 1},
		{"type": "diplomacy_card_reward", "value": 1},
	],
	RelationLevel.ALLIED: [
		{"type": "shop_discount", "value": 30},
		{"type": "skip_combat_chance", "value": 0.2},
		{"type": "bonus_gold_per_combat", "value": 5},
		{"type": "special_relic_unlock", "value": 1},
	],
}

# ── Relation Level Names ────────────────────────────────────────────────────────

const RELATION_LEVEL_NAMES: Dictionary = {
	RelationLevel.HOSTILE: "敌对",
	RelationLevel.UNKNOWN: "未知",
	RelationLevel.CONTACTED: "接触",
	RelationLevel.FRIENDLY: "友好",
	RelationLevel.ALLIED: "同盟",
}

const RELATION_LEVEL_NAMES_EN: Dictionary = {
	RelationLevel.HOSTILE: "Hostile",
	RelationLevel.UNKNOWN: "Unknown",
	RelationLevel.CONTACTED: "Contacted",
	RelationLevel.FRIENDLY: "Friendly",
	RelationLevel.ALLIED: "Allied",
}


## Returns the ordered list of RelationLevel values from lowest to highest threshold.
static func get_sorted_levels() -> Array[int]:
	return [
		RelationLevel.HOSTILE,
		RelationLevel.UNKNOWN,
		RelationLevel.CONTACTED,
		RelationLevel.FRIENDLY,
		RelationLevel.ALLIED,
	]


## Returns the RelationLevel that corresponds to the given point total.
static func get_level_for_points(points: int) -> int:
	var result: int = RelationLevel.UNKNOWN
	var sorted_levels := get_sorted_levels()
	for level in sorted_levels:
		if points >= RELATION_THRESHOLDS[level]:
			result = level
	return result
