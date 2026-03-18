class_name CardData
extends Resource

enum CardType {
	ATTACK = 0,
	SKILL = 1,
	POWER = 2,
	CURSE = 3,
	STATUS = 4,
}

enum CardRarity {
	STARTER = 0,
	COMMON = 1,
	UNCOMMON = 2,
	RARE = 3,
	SPECIAL = 4,
}

enum TargetMode {
	SINGLE_ENEMY = 0,
	ALL_ENEMIES = 1,
	SELF = 2,
	NONE = 3,
}

@export var id: String = ""
@export var card_name: String = ""
@export var card_name_zh: String = ""
@export var type: int = CardType.ATTACK
@export var rarity: int = CardRarity.STARTER
@export var cost: int = 1
@export var description: String = ""
@export var description_zh: String = ""
@export var effects: Array[Dictionary] = []
@export var target_mode: int = TargetMode.SINGLE_ENEMY
@export var tags: PackedStringArray = PackedStringArray()
@export var upgraded: bool = false
@export var upgrade_changes: Dictionary = {}


func duplicate_card() -> CardData:
	var copy := CardData.new()
	copy.id = id
	copy.card_name = card_name
	copy.card_name_zh = card_name_zh
	copy.type = type
	copy.rarity = rarity
	copy.cost = cost
	copy.description = description
	copy.description_zh = description_zh
	copy.target_mode = target_mode
	copy.tags = tags.duplicate()
	copy.upgraded = upgraded
	copy.upgrade_changes = upgrade_changes.duplicate(true)

	var effects_copy: Array[Dictionary] = []
	for effect in effects:
		effects_copy.append(effect.duplicate(true))
	copy.effects = effects_copy

	return copy
