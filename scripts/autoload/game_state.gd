extends Node

# === Player Combat Stats ===
var player_max_hp: int = 80
var player_hp: int = 80
var player_gold: int = 100
var player_block: int = 0
var player_deck: Array = []
var player_relics: Array = []  # Array of relic_id strings
var player_statuses: Dictionary = {}

# === Run Progression ===
var current_act: int = 1
var current_map: Dictionary = {}  # Generated map data
var current_node_id: int = -1  # Current position on map
var acts_completed: Array[int] = []
var is_run_active: bool = false

# === Diplomacy State ===
var diplomacy_points: Dictionary = {}  # {nation_enum -> int}
var diplomacy_levels: Dictionary = {}  # {nation_enum -> level_enum}

# === Meta-Progression (persists between runs) ===
var meta_gold: int = 0  # Currency earned across runs
var meta_upgrades: Dictionary = {}  # {upgrade_id -> level}
var total_runs: int = 0
var best_act_reached: int = 0
var nations_allied: Array[int] = []  # Nations ever reached ALLIED status

# === RNG ===
var seed_value: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_load_meta_progress()


# === Run Management ===

func start_new_run() -> void:
	player_max_hp = 80 + _get_meta_bonus("max_hp")
	player_hp = player_max_hp
	player_gold = 100 + _get_meta_bonus("starting_gold")
	player_block = 0
	player_deck = []
	player_relics = []
	player_statuses = {}
	current_act = 1
	current_map = {}
	current_node_id = -1
	acts_completed = []
	is_run_active = true

	# Initialize diplomacy
	diplomacy_points = {}
	diplomacy_levels = {}
	for nation_id in range(8):  # 8 nations in DiplomacyData.Nation
		diplomacy_points[nation_id] = 0
		diplomacy_levels[nation_id] = 1  # UNKNOWN

	seed_value = randi()
	rng.seed = seed_value

	var starter_deck := CardDatabase.get_starter_deck()
	for card in starter_deck:
		player_deck.append(card)

	# Apply meta-progression unlocks
	if _get_meta_bonus("starter_relic") > 0:
		add_relic("compass")

	total_runs += 1
	EventBus.run_started.emit()


func end_run(victory: bool) -> void:
	is_run_active = false
	if current_act > best_act_reached:
		best_act_reached = current_act

	# Award meta-gold based on progress
	var earned: int = current_act * 10
	if victory:
		earned += 50
	meta_gold += earned

	_save_meta_progress()
	EventBus.run_ended.emit(victory)


func advance_act() -> void:
	acts_completed.append(current_act)
	current_act += 1
	current_map = {}
	current_node_id = -1
	EventBus.act_started.emit(current_act)


# === Combat State ===

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


# === Gold ===

func modify_gold(amount: int) -> void:
	player_gold = maxi(0, player_gold + amount)


# === Relic Management ===

func add_relic(relic_id: String) -> void:
	if not has_relic(relic_id):
		player_relics.append(relic_id)
		EventBus.relic_obtained.emit(relic_id)


func remove_relic(relic_id: String) -> void:
	var idx := player_relics.find(relic_id)
	if idx >= 0:
		player_relics.remove_at(idx)
		EventBus.relic_removed.emit(relic_id)


func has_relic(relic_id: String) -> bool:
	return player_relics.has(relic_id)


# === Diplomacy ===

func add_diplomacy_points(nation: int, amount: int) -> void:
	if not diplomacy_points.has(nation):
		diplomacy_points[nation] = 0
		diplomacy_levels[nation] = 1  # UNKNOWN

	diplomacy_points[nation] += amount

	# Check for level up using thresholds: HOSTILE<0, UNKNOWN=0, CONTACTED=10, FRIENDLY=30, ALLIED=60
	var pts: int = diplomacy_points[nation]
	var new_level: int = 1  # UNKNOWN
	if pts < 0:
		new_level = 0  # HOSTILE
	elif pts >= 60:
		new_level = 4  # ALLIED
	elif pts >= 30:
		new_level = 3  # FRIENDLY
	elif pts >= 10:
		new_level = 2  # CONTACTED

	var old_level: int = diplomacy_levels.get(nation, 1)
	diplomacy_levels[nation] = new_level

	EventBus.diplomacy_changed.emit(nation, pts, new_level)

	if new_level > old_level:
		EventBus.diplomacy_level_up.emit(nation, new_level)
		if new_level == 4 and not nations_allied.has(nation):
			nations_allied.append(nation)


func get_diplomacy_points(nation: int) -> int:
	return diplomacy_points.get(nation, 0)


func get_diplomacy_level(nation: int) -> int:
	return diplomacy_levels.get(nation, 1)


# === Meta-Progression ===

func purchase_meta_upgrade(upgrade_id: String, cost: int) -> bool:
	if meta_gold < cost:
		return false
	meta_gold -= cost
	if meta_upgrades.has(upgrade_id):
		meta_upgrades[upgrade_id] += 1
	else:
		meta_upgrades[upgrade_id] = 1
	_save_meta_progress()
	return true


func _get_meta_bonus(bonus_type: String) -> int:
	match bonus_type:
		"max_hp":
			return meta_upgrades.get("hull_upgrade", 0) * 5
		"starting_gold":
			return meta_upgrades.get("treasury", 0) * 15
		"starter_relic":
			return meta_upgrades.get("compass_mastery", 0)
		_:
			return 0


func _save_meta_progress() -> void:
	var save_data := {
		"meta_gold": meta_gold,
		"meta_upgrades": meta_upgrades,
		"total_runs": total_runs,
		"best_act_reached": best_act_reached,
		"nations_allied": nations_allied,
	}
	var save_file := FileAccess.open("user://meta_progress.save", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()


func _load_meta_progress() -> void:
	if not FileAccess.file_exists("user://meta_progress.save"):
		return
	var save_file := FileAccess.open("user://meta_progress.save", FileAccess.READ)
	if not save_file:
		return
	var json := JSON.new()
	var result := json.parse(save_file.get_as_text())
	save_file.close()
	if result != OK:
		return
	var data: Dictionary = json.data
	meta_gold = data.get("meta_gold", 0)
	meta_upgrades = data.get("meta_upgrades", {})
	total_runs = data.get("total_runs", 0)
	best_act_reached = data.get("best_act_reached", 0)
	var allied_arr = data.get("nations_allied", [])
	nations_allied = []
	for n in allied_arr:
		nations_allied.append(int(n))
