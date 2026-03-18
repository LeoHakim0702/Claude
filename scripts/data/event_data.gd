class_name EventData
extends Resource

enum EventType {
	STORY = 0,
	RANDOM = 1,
	SHOP = 2,
	REST = 3,
	TREASURE = 4,
	DIPLOMACY = 5,
}

@export var id: String = ""
@export var event_name: String = ""
@export var event_name_zh: String = ""
@export var event_type: int = EventType.RANDOM
@export var act: int = 0  # 0 = any act, 1-3 = specific act
@export var description: String = ""
@export var description_zh: String = ""
@export var choices: Array[Dictionary] = []
# Each choice: {
#   text: String, text_zh: String,
#   effects: Array[Dictionary],  # [{type: "heal", value: 10}, {type: "gold", value: -20}, ...]
#   requirements: Dictionary,  # {gold_min: 20, relic: "compass", diplomacy_level: 2}
#   result_text: String, result_text_zh: String
# }
@export var image_hint: String = ""  # Which ink wash scene to suggest drawing


func duplicate_event() -> EventData:
	var copy := EventData.new()
	copy.id = id
	copy.event_name = event_name
	copy.event_name_zh = event_name_zh
	copy.event_type = event_type
	copy.act = act
	copy.description = description
	copy.description_zh = description_zh
	copy.image_hint = image_hint

	var choices_copy: Array[Dictionary] = []
	for choice in choices:
		choices_copy.append(choice.duplicate(true))
	copy.choices = choices_copy

	return copy
