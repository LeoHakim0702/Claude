extends Node

var player_max_hp: int = 80
var player_hp: int = 80
var player_gold: int = 100
var player_block: int = 0
var player_deck: Array = []
var player_relics: Array = []
var player_statuses: Dictionary = {}
var current_act: int = 1
var seed_value: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	pass


func start_new_run() -> void:
	player_max_hp = 80
	player_hp = 80
	player_gold = 100
	player_block = 0
	player_deck = []
	player_relics = []
	player_statuses = {}
	current_act = 1

	seed_value = randi()
	rng.seed = seed_value

	var starter_deck := CardDatabase.get_starter_deck()
	for card in starter_deck:
		player_deck.append(card)


func reset_combat_state() -> void:
	player_block = 0
	player_statuses.clear()


func apply_status(status_id: String, stacks: int) -> void:
	if player_statuses.has(status_id):
		player_statuses[status_id] += stacks
	else:
		player_statuses[status_id] = stacks
	EventBus.status_applied.emit(self, status_id, player_statuses[status_id])


func remove_status(status_id: String) -> void:
	if player_statuses.has(status_id):
		player_statuses.erase(status_id)
		EventBus.status_removed.emit(self, status_id)


func get_status_stacks(status_id: String) -> int:
	if player_statuses.has(status_id):
		return player_statuses[status_id]
	return 0


func modify_hp(amount: int) -> void:
	player_hp = clampi(player_hp + amount, 0, player_max_hp)
	EventBus.hp_changed.emit(self, player_hp, player_max_hp)


func add_block(amount: int) -> void:
	player_block += amount
	EventBus.block_gained.emit(self, player_block)
