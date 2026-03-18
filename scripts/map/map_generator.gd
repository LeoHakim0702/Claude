class_name MapGenerator
extends RefCounted
## Generates Slay-the-Spire-style voyage maps for each act of Zheng He's journey.
##
## The map is a directed acyclic graph with 15 rows and up to 7 columns.
## Row 0 contains start nodes, row 14 contains the boss, and rows 1-13
## contain a mix of combat, events, elites, rest sites, shops, and treasure.

const ROWS: int = 15
const COLS: int = 7
const MIN_START_NODES: int = 2
const MAX_START_NODES: int = 3
const MIN_NODES_PER_ROW: int = 2
const MAX_NODES_PER_ROW: int = 5

# Node type distribution weights (approximate percentages)
const TYPE_WEIGHTS := {
	MapData.NodeType.COMBAT: 45,
	MapData.NodeType.EVENT: 22,
	MapData.NodeType.ELITE: 8,
	MapData.NodeType.REST: 12,
	MapData.NodeType.SHOP: 8,
	MapData.NodeType.TREASURE: 5,
}

# Historical port names organized by act
const PORT_NAMES_BY_ACT := {
	1: {  # Southeast Asia 南洋
		"names": [
			"Liujiagang", "Taicang", "Champa", "Chenla", "Siam",
			"Java", "Palembang", "Sumatra", "Pahang",
			"Dragon's Teeth Gate", "Majapahit", "Temasek",
		],
		"names_zh": [
			"刘家港", "太仓", "占城", "真腊", "暹罗",
			"爪哇", "旧港", "苏门答腊", "彭亨",
			"龙牙门", "满者伯夷", "淡马锡",
		],
	},
	2: {  # Indian Ocean 印度洋
		"names": [
			"Malacca", "Ceylon", "Calicut", "Cochin", "Kambay",
			"Quilon", "Abobatan", "Maldives", "Galle", "Beruwala",
		],
		"names_zh": [
			"满剌加", "锡兰", "古里", "柯枝", "甘巴里",
			"小葛兰", "阿拨把丹", "溜山", "加异勒", "别罗里",
		],
	},
	3: {  # Middle East & Africa 西域非洲
		"names": [
			"Hormuz", "Aden", "Mecca", "Mogadishu", "Mogadishu",
			"Brava", "Malindi", "Beira", "Mombasa", "Dhofar",
		],
		"names_zh": [
			"霍尔木兹", "阿丹", "天方", "摩加迪沙", "木骨都束",
			"卜剌哇", "麻林", "比剌", "慢八撒", "祖法儿",
		],
	},
}


## Generates a complete map for the given act.
## Returns a Dictionary with keys: nodes (Array of MapNode), rows (int), cols (int).
func generate_map(act: int, rng: RandomNumberGenerator) -> Dictionary:
	var nodes: Array = []
	var next_id: int = 0

	# --- Step 1: Place nodes in the grid ---
	# Row 0: START nodes
	var num_starts := rng.randi_range(MIN_START_NODES, MAX_START_NODES)
	var start_cols := _pick_random_columns(num_starts, rng)
	for col in start_cols:
		var node := MapData.MapNode.new()
		node.id = next_id
		next_id += 1
		node.row = 0
		node.col = col
		node.type = MapData.NodeType.START
		nodes.append(node)

	# Rows 1-13: Mixed nodes
	for row in range(1, ROWS - 1):
		var num_nodes := rng.randi_range(MIN_NODES_PER_ROW, MAX_NODES_PER_ROW)
		var cols := _pick_random_columns(num_nodes, rng)
		for col in cols:
			var node := MapData.MapNode.new()
			node.id = next_id
			next_id += 1
			node.row = row
			node.col = col
			node.type = MapData.NodeType.COMBAT  # Placeholder, assigned later
			nodes.append(node)

	# Row 14: BOSS node (centered)
	var boss_node := MapData.MapNode.new()
	boss_node.id = next_id
	next_id += 1
	boss_node.row = ROWS - 1
	boss_node.col = COLS / 2
	boss_node.type = MapData.NodeType.BOSS
	nodes.append(boss_node)

	# --- Step 2: Generate connections ---
	_generate_paths(nodes, rng)

	# --- Step 3: Prune unreachable nodes ---
	_prune_unreachable_nodes(nodes)

	# --- Step 4: Assign node types ---
	_assign_node_types(nodes, rng)

	# --- Step 5: Enforce constraints ---
	_ensure_elite_constraints(nodes)
	_ensure_rest_before_boss(nodes)

	# --- Step 6: Assign port names ---
	_assign_port_names(nodes, act, rng)

	# --- Step 7: Calculate screen positions ---
	_calculate_positions(nodes)

	# --- Step 8: Mark starting nodes as available ---
	for node in nodes:
		if node.type == MapData.NodeType.START:
			node.available = true

	return {"nodes": nodes, "rows": ROWS, "cols": COLS}


## Pick `count` distinct random columns from the available range, returned sorted.
func _pick_random_columns(count: int, rng: RandomNumberGenerator) -> Array[int]:
	var available: Array[int] = []
	for i in range(COLS):
		available.append(i)

	var picked: Array[int] = []
	for i in range(mini(count, COLS)):
		var idx := rng.randi_range(0, available.size() - 1)
		picked.append(available[idx])
		available.remove_at(idx)

	picked.sort()
	return picked


## Create connections between rows, ensuring no crossing paths.
func _generate_paths(nodes: Array, rng: RandomNumberGenerator) -> void:
	# Build a row-indexed lookup
	var rows_map: Dictionary = {}  # row -> Array of MapNode sorted by col
	for node in nodes:
		if not rows_map.has(node.row):
			rows_map[node.row] = []
		rows_map[node.row].append(node)

	# Sort each row by column
	for row_key in rows_map:
		var row_nodes: Array = rows_map[row_key]
		row_nodes.sort_custom(func(a, b): return a.col < b.col)

	# Connect each row to the next
	for row in range(ROWS - 1):
		if not rows_map.has(row) or not rows_map.has(row + 1):
			continue

		var current_row: Array = rows_map[row]
		var next_row: Array = rows_map[row + 1]

		if current_row.is_empty() or next_row.is_empty():
			continue

		# Track the rightmost connection target column for crossing prevention
		var last_max_target_col: int = -1

		for i in range(current_row.size()):
			var node: MapData.MapNode = current_row[i]
			var is_start := (node.type == MapData.NodeType.START)
			var min_connections := 2 if is_start else 1
			var max_connections := 3 if is_start else mini(3, next_row.size())

			# Determine valid target range to avoid crossings
			# The minimum target col must be >= last_max_target_col to prevent crossing
			var min_target_idx := 0
			for j in range(next_row.size()):
				if next_row[j].col >= last_max_target_col:
					min_target_idx = j
					break
				min_target_idx = j

			# The maximum target index: for non-last nodes, limit to prevent
			# blocking the next node from connecting.
			var max_target_idx := next_row.size() - 1
			if i < current_row.size() - 1:
				# Leave at least one node for remaining current row nodes
				var remaining_current := current_row.size() - 1 - i
				max_target_idx = mini(max_target_idx, next_row.size() - remaining_current)

			# Ensure valid range
			min_target_idx = mini(min_target_idx, max_target_idx)

			# Pick number of connections
			var available_targets := max_target_idx - min_target_idx + 1
			var num_connections := rng.randi_range(
				mini(min_connections, available_targets),
				mini(max_connections, available_targets)
			)
			num_connections = maxi(num_connections, 1)

			# Pick consecutive targets starting from min_target_idx
			# (consecutive ensures no crossing)
			var start_idx := min_target_idx
			if available_targets > num_connections:
				start_idx = rng.randi_range(
					min_target_idx,
					min_target_idx + available_targets - num_connections
				)

			for j in range(num_connections):
				var target_idx := start_idx + j
				if target_idx >= 0 and target_idx < next_row.size():
					var target: MapData.MapNode = next_row[target_idx]
					if not node.connections.has(target.id):
						node.connections.append(target.id)
					last_max_target_col = target.col

		# Ensure every next-row node has at least one incoming connection
		for target in next_row:
			var has_incoming := false
			for source in current_row:
				if source.connections.has(target.id):
					has_incoming = true
					break
			if not has_incoming:
				# Connect from nearest source node
				var best_source: MapData.MapNode = null
				var best_dist := 999
				for source in current_row:
					var dist := absi(source.col - target.col)
					if dist < best_dist:
						best_dist = dist
						best_source = source
				if best_source:
					best_source.connections.append(target.id)

	# Ensure all second-to-last row nodes connect to boss
	if rows_map.has(ROWS - 2) and rows_map.has(ROWS - 1):
		var boss: MapData.MapNode = rows_map[ROWS - 1][0]
		for node in rows_map[ROWS - 2]:
			if not node.connections.has(boss.id):
				node.connections.append(boss.id)


## Remove nodes that cannot be reached from any start node or cannot reach the boss.
func _prune_unreachable_nodes(nodes: Array) -> void:
	var id_map: Dictionary = {}
	for node in nodes:
		id_map[node.id] = node

	# Forward pass: find all reachable from start
	var reachable_from_start: Dictionary = {}
	var queue: Array = []
	for node in nodes:
		if node.type == MapData.NodeType.START:
			queue.append(node.id)
			reachable_from_start[node.id] = true

	while not queue.is_empty():
		var current_id: int = queue.pop_front()
		var current: MapData.MapNode = id_map[current_id]
		for conn_id in current.connections:
			if not reachable_from_start.has(conn_id):
				reachable_from_start[conn_id] = true
				queue.append(conn_id)

	# Backward pass: find all nodes that can reach the boss
	var reaches_boss: Dictionary = {}
	var boss_id: int = -1
	for node in nodes:
		if node.type == MapData.NodeType.BOSS:
			boss_id = node.id
			break

	if boss_id >= 0:
		reaches_boss[boss_id] = true
		# Build reverse adjacency
		var reverse_adj: Dictionary = {}
		for node in nodes:
			for conn_id in node.connections:
				if not reverse_adj.has(conn_id):
					reverse_adj[conn_id] = []
				reverse_adj[conn_id].append(node.id)

		queue = [boss_id]
		while not queue.is_empty():
			var current_id: int = queue.pop_front()
			if reverse_adj.has(current_id):
				for parent_id in reverse_adj[current_id]:
					if not reaches_boss.has(parent_id):
						reaches_boss[parent_id] = true
						queue.append(parent_id)

	# Remove nodes not in both sets
	var to_remove: Array = []
	for node in nodes:
		if not reachable_from_start.has(node.id) or not reaches_boss.has(node.id):
			to_remove.append(node)

	for node in to_remove:
		# Remove connections pointing to this node
		for other in nodes:
			other.connections.erase(node.id)
		nodes.erase(node)


## Assign node types based on distribution weights and row constraints.
func _assign_node_types(nodes: Array, rng: RandomNumberGenerator) -> void:
	# Build weighted type pool
	var type_pool: Array[int] = []
	for node_type in TYPE_WEIGHTS:
		for j in range(TYPE_WEIGHTS[node_type]):
			type_pool.append(node_type)

	for node in nodes:
		# Skip fixed types
		if node.type == MapData.NodeType.START or node.type == MapData.NodeType.BOSS:
			continue

		var assigned := false
		# Try up to 20 times to get a valid type
		for _attempt in range(20):
			var candidate: int = type_pool[rng.randi_range(0, type_pool.size() - 1)]

			# Row constraints
			if candidate == MapData.NodeType.ELITE and node.row <= 3:
				continue
			if candidate == MapData.NodeType.REST and node.row <= 2:
				continue
			if candidate == MapData.NodeType.SHOP and node.row <= 2:
				continue

			node.type = candidate
			assigned = true
			break

		if not assigned:
			node.type = MapData.NodeType.COMBAT


## Ensure elite nodes meet placement constraints:
## - None in rows 0-3
## - Guaranteed 2-3 per map
func _ensure_elite_constraints(nodes: Array) -> void:
	var elite_count := 0
	var elite_candidates: Array = []  # Non-elite nodes in valid rows for potential conversion

	for node in nodes:
		if node.type == MapData.NodeType.ELITE:
			if node.row <= 3:
				# Invalid placement, convert to combat
				node.type = MapData.NodeType.COMBAT
			else:
				elite_count += 1
		elif node.row > 3 and node.type == MapData.NodeType.COMBAT:
			elite_candidates.append(node)

	# Ensure at least 2 elites
	while elite_count < 2 and not elite_candidates.is_empty():
		var idx := elite_candidates.size() / 2  # Pick from middle rows
		elite_candidates[idx].type = MapData.NodeType.ELITE
		elite_candidates.remove_at(idx)
		elite_count += 1

	# Cap at 3 elites
	if elite_count > 3:
		var elites: Array = []
		for node in nodes:
			if node.type == MapData.NodeType.ELITE:
				elites.append(node)
		# Remove excess elites (keep the first 3)
		for i in range(3, elites.size()):
			elites[i].type = MapData.NodeType.COMBAT


## Guarantee at least one rest site in rows 12-13 (before the boss).
func _ensure_rest_before_boss(nodes: Array) -> void:
	var has_rest_before_boss := false
	var candidates: Array = []

	for node in nodes:
		if node.row in [12, 13]:
			if node.type == MapData.NodeType.REST:
				has_rest_before_boss = true
				break
			elif node.type != MapData.NodeType.BOSS and node.type != MapData.NodeType.START:
				candidates.append(node)

	if not has_rest_before_boss and not candidates.is_empty():
		candidates[0].type = MapData.NodeType.REST


## Assign historical port names to each node based on the act.
func _assign_port_names(nodes: Array, act: int, rng: RandomNumberGenerator) -> void:
	var clamped_act := clampi(act, 1, 3)
	var port_data: Dictionary = PORT_NAMES_BY_ACT[clamped_act]
	var names: Array = port_data["names"].duplicate()
	var names_zh: Array = port_data["names_zh"].duplicate()

	# Shuffle the names
	for i in range(names.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp_name = names[i]
		names[i] = names[j]
		names[j] = tmp_name
		var tmp_zh = names_zh[i]
		names_zh[i] = names_zh[j]
		names_zh[j] = tmp_zh

	var name_idx := 0
	for node in nodes:
		if name_idx < names.size():
			node.port_name = names[name_idx]
			node.port_name_zh = names_zh[name_idx]
			name_idx += 1
		else:
			# Wrap around if we have more nodes than names
			var wrapped := name_idx % names.size()
			node.port_name = names[wrapped]
			node.port_name_zh = names_zh[wrapped]
			name_idx += 1


## Calculate screen positions for each node for rendering.
func _calculate_positions(nodes: Array) -> void:
	var row_height := 120.0
	var col_width := 140.0
	var margin := Vector2(100.0, 80.0)

	for node in nodes:
		# Invert row so start is at the bottom and boss at the top
		var visual_row := (ROWS - 1) - node.row
		node.position = Vector2(
			margin.x + node.col * col_width,
			margin.y + visual_row * row_height
		)


## Validate the generated map. Returns true if all constraints are satisfied.
func _validate_map(nodes: Array) -> bool:
	if nodes.is_empty():
		return false

	var id_map: Dictionary = {}
	for node in nodes:
		id_map[node.id] = node

	# Check: at least one start and exactly one boss
	var start_count := 0
	var boss_count := 0
	for node in nodes:
		if node.type == MapData.NodeType.START:
			start_count += 1
		elif node.type == MapData.NodeType.BOSS:
			boss_count += 1

	if start_count < 1 or boss_count != 1:
		return false

	# Check: every non-boss node has at least one connection forward
	for node in nodes:
		if node.type != MapData.NodeType.BOSS and node.connections.is_empty():
			return false

	# Check: all nodes reachable from start
	var visited: Dictionary = {}
	var queue: Array = []
	for node in nodes:
		if node.type == MapData.NodeType.START:
			queue.append(node.id)
			visited[node.id] = true

	while not queue.is_empty():
		var current_id: int = queue.pop_front()
		if id_map.has(current_id):
			for conn_id in id_map[current_id].connections:
				if not visited.has(conn_id):
					visited[conn_id] = true
					queue.append(conn_id)

	if visited.size() != nodes.size():
		return false

	# Check: elite constraints
	for node in nodes:
		if node.type == MapData.NodeType.ELITE and node.row <= 3:
			return false

	return true
