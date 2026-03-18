class_name EnergyManager
extends RefCounted

var current_energy: int = 0
var max_energy: int = 3
var base_energy: int = 3


func start_turn() -> void:
	current_energy = max_energy
	EventBus.energy_changed.emit(current_energy, max_energy)


func spend_energy(amount: int) -> bool:
	if amount > current_energy:
		return false
	current_energy -= amount
	EventBus.energy_changed.emit(current_energy, max_energy)
	return true


func gain_energy(amount: int) -> void:
	current_energy += amount
	EventBus.energy_changed.emit(current_energy, max_energy)


func can_play_card(card) -> bool:
	if card.cost == -1:
		return current_energy > 0
	return card.cost <= current_energy


func get_x_cost() -> int:
	return current_energy


func reset() -> void:
	max_energy = base_energy
	current_energy = 0
