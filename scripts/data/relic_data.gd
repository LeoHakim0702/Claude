class_name RelicData
extends Resource

enum RelicRarity {
	STARTER = 0,
	COMMON = 1,
	UNCOMMON = 2,
	RARE = 3,
	BOSS = 4,
	EVENT = 5,
}

@export var id: String = ""
@export var relic_name: String = ""
@export var relic_name_zh: String = ""
@export var rarity: int = RelicRarity.COMMON
@export var description: String = ""
@export var description_zh: String = ""
@export var trigger_event: String = ""  # EventBus signal name to listen on
@export var effect_type: String = ""  # What the relic does
@export var effect_value: int = 0
@export var effect_params: Dictionary = {}


func duplicate_relic() -> RelicData:
	var copy := RelicData.new()
	copy.id = id
	copy.relic_name = relic_name
	copy.relic_name_zh = relic_name_zh
	copy.rarity = rarity
	copy.description = description
	copy.description_zh = description_zh
	copy.trigger_event = trigger_event
	copy.effect_type = effect_type
	copy.effect_value = effect_value
	copy.effect_params = effect_params.duplicate(true)
	return copy
