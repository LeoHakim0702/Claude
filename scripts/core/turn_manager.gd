class_name TurnManager
extends RefCounted

var _deck_manager: DeckManager
var _energy_manager: EnergyManager
var _effect_resolver: EffectResolver
var _enemies: Array[EnemyInstance] = []
var _turn_number: int = 0
var _is_player_turn: bool = false
var combat_active: bool = false


func init_combat(deck: Array[Resource], enemies: Array[EnemyInstance], rng: RandomNumberGenerator) -> void:
	_deck_manager = DeckManager.new()
	_energy_manager = EnergyManager.new()
	_effect_resolver = EffectResolver.new()
	_effect_resolver.init_resolver(_deck_manager, _energy_manager)
	_deck_manager.init_combat(deck, rng)
	_enemies = enemies
	_turn_number = 0
	combat_active = true
	GameState.reset_combat_state()

	for enemy in _enemies:
		enemy.decide_next_intent()

	start_player_turn()


func start_player_turn() -> void:
	_turn_number += 1
	_is_player_turn = true
	GameState.player_block = 0
	_energy_manager.start_turn()
	_deck_manager.draw_cards(5)
	_process_player_start_of_turn_statuses()
	EventBus.player_turn_started.emit()
	EventBus.turn_started.emit(_turn_number)


func end_player_turn() -> void:
	_is_player_turn = false
	_process_player_end_of_turn_statuses()
	_deck_manager.discard_hand()
	EventBus.player_turn_ended.emit()
	execute_enemy_turn()


func execute_enemy_turn() -> void:
	EventBus.enemy_turn_started.emit()

	for enemy in _enemies:
		if enemy.is_alive():
			_effect_resolver.resolve_enemy_effects(
				enemy.get_current_intent_effects(), enemy, true
			)
			enemy.decide_next_intent()

			if GameState.player_hp <= 0:
				combat_active = false
				EventBus.combat_lost.emit()
				return

	EventBus.enemy_turn_ended.emit()

	if _all_enemies_dead():
		combat_active = false
		EventBus.combat_won.emit()
		return

	start_player_turn()


func try_play_card(card_data: Resource, targets: Array) -> bool:
	if not _is_player_turn:
		return false
	if not _energy_manager.can_play_card(card_data):
		return false

	var actual_cost: int = card_data.cost if card_data.cost >= 0 else _energy_manager.get_x_cost()
	_energy_manager.spend_energy(actual_cost)
	_effect_resolver.resolve_card(card_data, targets, _enemies)
	EventBus.card_played.emit(card_data, targets)

	var should_exhaust: bool = false
	for effect: Dictionary in card_data.effects:
		if effect.type == "EXHAUST_SELF":
			should_exhaust = true

	if should_exhaust:
		_deck_manager.exhaust_card(card_data)
	else:
		_deck_manager.discard_card(card_data)

	_check_enemy_deaths()

	if _all_enemies_dead():
		combat_active = false
		EventBus.combat_won.emit()

	return true


func _all_enemies_dead() -> bool:
	for enemy in _enemies:
		if enemy.is_alive():
			return false
	return true


func _check_enemy_deaths() -> void:
	for enemy in _enemies:
		if not enemy.is_alive() and not enemy.death_processed:
			enemy.death_processed = true
			EventBus.enemy_died.emit(enemy)


func _process_player_start_of_turn_statuses() -> void:
	pass


func _process_player_end_of_turn_statuses() -> void:
	var burn: int = GameState.get_status_stacks("burn")
	if burn > 0:
		GameState.modify_hp(-burn)
		GameState.remove_status("burn")

	_decay_status("vulnerable")
	_decay_status("weak")


func _decay_status(status_id: String) -> void:
	var stacks: int = GameState.get_status_stacks(status_id)
	if stacks > 0:
		if stacks <= 1:
			GameState.remove_status(status_id)
		else:
			GameState.player_statuses[status_id] = stacks - 1


func get_deck_manager() -> DeckManager:
	return _deck_manager


func get_energy_manager() -> EnergyManager:
	return _energy_manager


func get_hand() -> Array[Resource]:
	return _deck_manager.hand


func is_player_turn() -> bool:
	return _is_player_turn


func get_enemies() -> Array[EnemyInstance]:
	return _enemies
