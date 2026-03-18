class_name EnemyInstance
extends RefCounted

var data: Resource
var max_hp: int
var current_hp: int
var block: int = 0
var statuses: Dictionary = {}
var death_processed: bool = false
var _current_move_index: int = 0
var _current_intent: Dictionary = {}
var _rng: RandomNumberGenerator
var enemy_name: String
var enemy_name_zh: String


static func create(enemy_data: Resource, rng: RandomNumberGenerator) -> EnemyInstance:
	var instance: EnemyInstance = EnemyInstance.new()
	instance.data = enemy_data
	instance.enemy_name = enemy_data.enemy_name
	instance.enemy_name_zh = enemy_data.enemy_name_zh
	instance.max_hp = rng.randi_range(enemy_data.hp_min, enemy_data.hp_max)
	instance.current_hp = instance.max_hp
	instance._rng = rng
	return instance


func is_alive() -> bool:
	return current_hp > 0


func take_damage(amount: int) -> void:
	var result: Dictionary = DamageCalc.apply_damage_to_target(amount, block, current_hp)
	block = result.remaining_block
	current_hp = result.remaining_hp


func add_block(amount: int) -> void:
	block += amount


func apply_status(status_id: String, stacks: int) -> void:
	statuses[status_id] = statuses.get(status_id, 0) + stacks
	if statuses[status_id] <= 0:
		statuses.erase(status_id)


func get_status_stacks(status_id: String) -> int:
	return statuses.get(status_id, 0)


func decide_next_intent() -> void:
	var ai_type: String = data.ai_type
	var moves: Array = data.moves

	if moves.is_empty():
		_current_intent = {}
		return

	var chosen_move_id: String = ""

	match ai_type:
		"CYCLE":
			var sequence: Array = []
			if data.ai_params.has("sequence"):
				sequence = data.ai_params.sequence
			if sequence.is_empty():
				# Default: cycle through all moves in order
				chosen_move_id = moves[_current_move_index % moves.size()].get("id", "")
				_current_move_index = (_current_move_index + 1) % moves.size()
			else:
				chosen_move_id = sequence[_current_move_index % sequence.size()]
				_current_move_index = (_current_move_index + 1) % sequence.size()

		"RANDOM_WEIGHTED":
			# Weights are defined on each move dict as "weight" field
			var total_weight: float = 0.0
			for move: Dictionary in moves:
				total_weight += move.get("weight", 1.0)
			var roll: float = _rng.randf() * total_weight
			var cumulative: float = 0.0
			for move: Dictionary in moves:
				cumulative += move.get("weight", 1.0)
				if roll <= cumulative:
					chosen_move_id = move.get("id", "")
					break

		"CONDITIONAL":
			var hp_threshold: float = 0.5
			if data.ai_params.has("hp_threshold"):
				hp_threshold = data.ai_params.hp_threshold
			var hp_ratio: float = float(current_hp) / float(max_hp) if max_hp > 0 else 1.0

			if hp_ratio <= hp_threshold:
				# Use second move (enraged/desperate) if available
				if moves.size() > 1:
					chosen_move_id = moves[1].get("id", "")
				else:
					chosen_move_id = moves[0].get("id", "")
			else:
				# Cycle through moves normally when above threshold
				var sequence: Array = []
				if data.ai_params.has("sequence"):
					sequence = data.ai_params.sequence
				if sequence.is_empty():
					chosen_move_id = moves[_current_move_index % moves.size()].get("id", "")
					_current_move_index = (_current_move_index + 1) % moves.size()
				else:
					chosen_move_id = sequence[_current_move_index % sequence.size()]
					_current_move_index = (_current_move_index + 1) % sequence.size()

	# Find the move dict matching the chosen id
	_current_intent = {}
	for move: Dictionary in moves:
		if move.get("id", "") == chosen_move_id:
			_current_intent = move
			break

	# Fallback: if no match found, use first move
	if _current_intent.is_empty() and not moves.is_empty():
		_current_intent = moves[0]


func get_current_intent() -> Dictionary:
	return _current_intent


func get_current_intent_effects() -> Array:
	return _current_intent.get("effects", [])


func get_intent_display() -> Dictionary:
	var display: Dictionary = {
		"type": _current_intent.get("type", "unknown"),
		"damage": 0,
		"block": 0,
		"status": "",
		"hits": 1,
	}

	for effect: Dictionary in get_current_intent_effects():
		var effect_type: String = effect.get("type", "")
		match effect_type:
			"DAMAGE":
				var base: int = effect.get("value", 0)
				var strength: int = get_status_stacks("strength")
				display.damage = base + strength
				display.hits = effect.get("hits", 1)
				display.type = "attack"
			"BLOCK":
				display.block = effect.get("value", 0)
				display.type = "defend"
			"APPLY_STATUS":
				display.status = effect.get("status_id", "")
				if display.type == "unknown":
					display.type = "buff"

	return display
