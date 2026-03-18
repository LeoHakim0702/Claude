extends Node
class_name CombatManager

var turn_manager: TurnManager
var enemy_instances: Array[EnemyInstance] = []
var _awaiting_target: bool = false
var _pending_card: Resource = null

signal request_target_selection(card_data)
signal combat_state_changed()
signal combat_ended(won: bool)


func start_combat(enemy_ids: Array) -> void:
	enemy_instances.clear()
	var rng = GameState.rng
	for eid in enemy_ids:
		var edata = EnemyDatabase.get_enemy(eid)
		if edata:
			var inst = EnemyInstance.create(edata, rng)
			enemy_instances.append(inst)

	turn_manager = TurnManager.new()
	turn_manager.init_combat(GameState.player_deck, enemy_instances, rng)

	# Connect signals
	EventBus.combat_won.connect(_on_combat_won)
	EventBus.combat_lost.connect(_on_combat_lost)

	combat_state_changed.emit()


func attempt_play_card(card_data: Resource, target_enemy: Variant = null) -> void:
	if not turn_manager.is_player_turn():
		return

	# Determine targets based on target_mode
	var targets: Array = []
	match card_data.target_mode:
		0:  # SINGLE_ENEMY
			if target_enemy == null:
				# Need to select target
				_awaiting_target = true
				_pending_card = card_data
				request_target_selection.emit(card_data)
				return
			targets = [target_enemy]
		1:  # ALL_ENEMIES
			targets = enemy_instances.filter(func(e): return e.is_alive())
		2, 3:  # SELF, NONE
			targets = []

	var success = turn_manager.try_play_card(card_data, targets)
	if success:
		combat_state_changed.emit()


func select_target(enemy_instance: EnemyInstance) -> void:
	if _awaiting_target and _pending_card:
		_awaiting_target = false
		var card = _pending_card
		_pending_card = null
		attempt_play_card(card, enemy_instance)


func end_turn() -> void:
	if turn_manager.is_player_turn():
		turn_manager.end_player_turn()
		combat_state_changed.emit()


func _on_combat_won() -> void:
	combat_ended.emit(true)


func _on_combat_lost() -> void:
	combat_ended.emit(false)


func get_hand() -> Array:
	if turn_manager:
		return turn_manager.get_deck_manager().hand
	return []


func get_energy() -> int:
	if turn_manager:
		return turn_manager.get_energy_manager().current_energy
	return 0


func get_max_energy() -> int:
	if turn_manager:
		return turn_manager.get_energy_manager().max_energy
	return 3


func get_draw_count() -> int:
	if turn_manager:
		return turn_manager.get_deck_manager().get_draw_count()
	return 0


func get_discard_count() -> int:
	if turn_manager:
		return turn_manager.get_deck_manager().get_discard_count()
	return 0


func is_awaiting_target() -> bool:
	return _awaiting_target


func cancel_target_selection() -> void:
	_awaiting_target = false
	_pending_card = null


func cleanup() -> void:
	if EventBus.combat_won.is_connected(_on_combat_won):
		EventBus.combat_won.disconnect(_on_combat_won)
	if EventBus.combat_lost.is_connected(_on_combat_lost):
		EventBus.combat_lost.disconnect(_on_combat_lost)
