extends Control
## Renders the voyage map in an ink wash (水墨) style.
##
## Displays map nodes as styled icons connected by brush-stroke lines.
## Supports scrolling, click interaction, and visual states for
## visited, available, and locked nodes.

signal node_selected(node_id: int)

## The generated map dictionary from MapGenerator (keys: nodes, rows, cols).
var map_data: Dictionary = {}

## The ID of the node the player currently occupies.
var current_node_id: int = -1

## Vertical scroll offset for navigating the tall map.
var scroll_offset: float = 0.0

## Total map height calculated from node positions.
var _map_height: float = 0.0

## Cached ID-to-node lookup.
var _id_map: Dictionary = {}

# --- Visual constants ---
const NODE_RADIUS := 22.0
const NODE_RADIUS_BOSS := 34.0
const HIT_RADIUS := 28.0
const LINE_WIDTH_NORMAL := 2.0
const LINE_WIDTH_VISITED := 3.0
const PORT_NAME_OFFSET := Vector2(0.0, 30.0)
const SCROLL_SPEED := 30.0

# Colors
const COLOR_VISITED := Color(0.55, 0.53, 0.50)        # Gray ink
const COLOR_AVAILABLE := Color(0.85, 0.70, 0.25)       # Golden highlight
const COLOR_LOCKED := Color(0.25, 0.23, 0.22, 0.6)     # Dark, faded
const COLOR_CURRENT := Color(0.95, 0.85, 0.35)         # Bright gold
const COLOR_LINE_NORMAL := Color(0.30, 0.28, 0.26, 0.5)
const COLOR_LINE_VISITED := Color(0.15, 0.13, 0.12, 0.8)
const COLOR_BOSS := Color(0.7, 0.15, 0.15)             # Deep red
const COLOR_ELITE := Color(0.6, 0.2, 0.5)              # Purple
const COLOR_REST := Color(0.2, 0.6, 0.35)              # Green
const COLOR_SHOP := Color(0.8, 0.65, 0.1)              # Gold
const COLOR_TREASURE := Color(0.75, 0.6, 0.15)         # Amber
const COLOR_EVENT := Color(0.3, 0.5, 0.7)              # Blue
const COLOR_INK := Color(0.12, 0.10, 0.09)             # Near-black ink
const COLOR_PORT_TEXT := Color(0.4, 0.38, 0.35)        # Muted text


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP


## Set the map data and refresh the display.
func set_map(data: Dictionary) -> void:
	map_data = data
	_id_map.clear()

	if map_data.has("nodes"):
		for node in map_data["nodes"]:
			_id_map[node.id] = node

		# Calculate total map height
		_map_height = 0.0
		for node in map_data["nodes"]:
			_map_height = maxf(_map_height, node.position.y + 100.0)

	# Start scrolled to the bottom (where the START nodes are)
	scroll_offset = maxf(0.0, _map_height - size.y)
	queue_redraw()


## Main draw callback. Renders background, connections, and nodes.
func _draw() -> void:
	# Draw background via ink wash renderer if available
	if Engine.has_singleton("InkWashRenderer"):
		# Use the global InkWashRenderer if it exists
		pass
	elif has_method("_draw_map_background"):
		_draw_map_background()
	else:
		_draw_default_background()

	if not map_data.has("nodes"):
		return

	_draw_connections()

	for node in map_data["nodes"]:
		_draw_node(node)


## Draw a simple parchment-like background.
func _draw_default_background() -> void:
	var bg_color := Color(0.92, 0.88, 0.82)  # Aged parchment
	draw_rect(Rect2(Vector2.ZERO, size), bg_color)

	# Subtle vertical wash lines for ink-wash feel
	var wash_color := Color(0.85, 0.80, 0.73, 0.3)
	for i in range(0, int(size.x), 80):
		var x := float(i) + 20.0
		draw_line(Vector2(x, 0), Vector2(x, size.y), wash_color, 1.0)


## Draw all connections between nodes.
func _draw_connections() -> void:
	for node in map_data["nodes"]:
		for conn_id in node.connections:
			if not _id_map.has(conn_id):
				continue
			var target: MapData.MapNode = _id_map[conn_id]

			var from_pos := node.position - Vector2(0, scroll_offset)
			var to_pos := target.position - Vector2(0, scroll_offset)

			# Skip if both endpoints are off-screen
			if from_pos.y < -50 and to_pos.y < -50:
				continue
			if from_pos.y > size.y + 50 and to_pos.y > size.y + 50:
				continue

			# Determine line style
			var line_color := COLOR_LINE_NORMAL
			var line_width := LINE_WIDTH_NORMAL

			if node.visited and target.visited:
				line_color = COLOR_LINE_VISITED
				line_width = LINE_WIDTH_VISITED

			# Draw a slightly curved ink-brush line using a midpoint offset
			var mid := (from_pos + to_pos) / 2.0
			mid.x += (to_pos.x - from_pos.x) * 0.1  # Subtle curve

			# Approximate curve with 3 segments
			var p0 := from_pos
			var p1 := from_pos.lerp(mid, 0.5)
			var p2 := mid.lerp(to_pos, 0.5)
			var p3 := to_pos

			draw_line(p0, p1, line_color, line_width, true)
			draw_line(p1, p2, line_color, line_width, true)
			draw_line(p2, p3, line_color, line_width, true)


## Draw a single map node with its type-specific icon.
func _draw_node(node: MapData.MapNode) -> void:
	var pos := node.position - Vector2(0, scroll_offset)

	# Cull off-screen nodes
	if pos.y < -60 or pos.y > size.y + 60:
		return

	# Determine node color based on state
	var node_color := _get_node_color(node)
	var outline_color := COLOR_INK

	if node.id == current_node_id:
		node_color = COLOR_CURRENT
	elif node.available:
		node_color = COLOR_AVAILABLE
		outline_color = COLOR_AVAILABLE
	elif node.visited:
		node_color = COLOR_VISITED

	# Draw type-specific icon
	match node.type:
		MapData.NodeType.COMBAT:
			_draw_combat_icon(pos, node_color, outline_color)
		MapData.NodeType.ELITE:
			_draw_elite_icon(pos, node_color, outline_color)
		MapData.NodeType.EVENT:
			_draw_event_icon(pos, node_color, outline_color)
		MapData.NodeType.REST:
			_draw_rest_icon(pos, node_color, outline_color)
		MapData.NodeType.SHOP:
			_draw_shop_icon(pos, node_color, outline_color)
		MapData.NodeType.TREASURE:
			_draw_treasure_icon(pos, node_color, outline_color)
		MapData.NodeType.BOSS:
			_draw_boss_icon(pos, node_color, outline_color)
		MapData.NodeType.START:
			_draw_start_icon(pos, node_color, outline_color)

	# Draw port name below node
	var port_label: String = Locale.pick(node.port_name, node.port_name_zh)
	if port_label != "":
		var font := ThemeDB.fallback_font
		var font_size := 11
		var text_size := font.get_string_size(port_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var text_pos := pos + PORT_NAME_OFFSET - Vector2(text_size.x / 2.0, 0)
		draw_string(font, text_pos, port_label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, COLOR_PORT_TEXT)

	# Pulsing indicator for available nodes
	if node.available and node.id != current_node_id:
		draw_arc(pos, NODE_RADIUS + 6.0, 0, TAU, 24, COLOR_AVAILABLE.lerp(Color.TRANSPARENT, 0.5), 1.5)


## Get the base color for a node based on its type.
func _get_node_color(node: MapData.MapNode) -> Color:
	match node.type:
		MapData.NodeType.BOSS:
			return COLOR_BOSS
		MapData.NodeType.ELITE:
			return COLOR_ELITE
		MapData.NodeType.REST:
			return COLOR_REST
		MapData.NodeType.SHOP:
			return COLOR_SHOP
		MapData.NodeType.TREASURE:
			return COLOR_TREASURE
		MapData.NodeType.EVENT:
			return COLOR_EVENT
		_:
			return COLOR_INK


# --- Icon drawing methods ---

## COMBAT: Crossed swords (X shape)
func _draw_combat_icon(pos: Vector2, color: Color, outline: Color) -> void:
	var r := NODE_RADIUS * 0.6
	draw_circle(pos, NODE_RADIUS, Color(0.92, 0.88, 0.82))
	draw_arc(pos, NODE_RADIUS, 0, TAU, 24, outline, 2.0)
	# X shape for crossed swords
	draw_line(pos + Vector2(-r, -r), pos + Vector2(r, r), color, 2.5, true)
	draw_line(pos + Vector2(r, -r), pos + Vector2(-r, r), color, 2.5, true)
	# Sword guards (small perpendicular lines)
	draw_line(pos + Vector2(-2, -2), pos + Vector2(2, -6), color, 1.5)
	draw_line(pos + Vector2(-2, -2), pos + Vector2(-6, 2), color, 1.5)


## ELITE: Skull-like circle with dots for eyes
func _draw_elite_icon(pos: Vector2, color: Color, outline: Color) -> void:
	draw_circle(pos, NODE_RADIUS, Color(0.92, 0.88, 0.82))
	draw_arc(pos, NODE_RADIUS, 0, TAU, 24, outline, 2.5)
	# Inner skull circle
	draw_arc(pos - Vector2(0, 2), NODE_RADIUS * 0.55, 0, TAU, 16, color, 2.0)
	# Eyes
	draw_circle(pos + Vector2(-6, -4), 3.0, color)
	draw_circle(pos + Vector2(6, -4), 3.0, color)
	# Jaw line
	draw_line(pos + Vector2(-5, 5), pos + Vector2(5, 5), color, 1.5)


## EVENT: Circle with question mark
func _draw_event_icon(pos: Vector2, color: Color, outline: Color) -> void:
	draw_circle(pos, NODE_RADIUS, Color(0.92, 0.88, 0.82))
	draw_arc(pos, NODE_RADIUS, 0, TAU, 24, outline, 2.0)
	# Question mark (?)
	var font := ThemeDB.fallback_font
	var text_size := font.get_string_size("?", HORIZONTAL_ALIGNMENT_CENTER, -1, 22)
	draw_string(font, pos - Vector2(text_size.x / 2.0, -8), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, color)


## REST: Campfire triangle
func _draw_rest_icon(pos: Vector2, color: Color, outline: Color) -> void:
	draw_circle(pos, NODE_RADIUS, Color(0.92, 0.88, 0.82))
	draw_arc(pos, NODE_RADIUS, 0, TAU, 24, outline, 2.0)
	# Fire triangle
	var fire_points := PackedVector2Array([
		pos + Vector2(0, -12),   # Top
		pos + Vector2(-10, 10),  # Bottom-left
		pos + Vector2(10, 10),   # Bottom-right
	])
	draw_colored_polygon(fire_points, color)
	# Inner flame
	var inner_points := PackedVector2Array([
		pos + Vector2(0, -5),
		pos + Vector2(-4, 6),
		pos + Vector2(4, 6),
	])
	draw_colored_polygon(inner_points, Color(0.95, 0.85, 0.3))


## SHOP: Circle with coin/dollar sign
func _draw_shop_icon(pos: Vector2, color: Color, outline: Color) -> void:
	draw_circle(pos, NODE_RADIUS, Color(0.92, 0.88, 0.82))
	draw_arc(pos, NODE_RADIUS, 0, TAU, 24, outline, 2.0)
	# Dollar sign ($)
	var font := ThemeDB.fallback_font
	var text_size := font.get_string_size("$", HORIZONTAL_ALIGNMENT_CENTER, -1, 22)
	draw_string(font, pos - Vector2(text_size.x / 2.0, -8), "$", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, color)


## TREASURE: Chest rectangle
func _draw_treasure_icon(pos: Vector2, color: Color, outline: Color) -> void:
	draw_circle(pos, NODE_RADIUS, Color(0.92, 0.88, 0.82))
	draw_arc(pos, NODE_RADIUS, 0, TAU, 24, outline, 2.0)
	# Chest body
	var chest_rect := Rect2(pos + Vector2(-10, -6), Vector2(20, 14))
	draw_rect(chest_rect, color, false, 2.0)
	# Chest lid (arc)
	draw_line(pos + Vector2(-10, -6), pos + Vector2(-10, -10), color, 2.0)
	draw_line(pos + Vector2(10, -6), pos + Vector2(10, -10), color, 2.0)
	draw_line(pos + Vector2(-10, -10), pos + Vector2(10, -10), color, 2.0)
	# Lock
	draw_circle(pos + Vector2(0, 2), 2.5, color)


## BOSS: Large decorated circle with star
func _draw_boss_icon(pos: Vector2, color: Color, outline: Color) -> void:
	# Outer glow
	draw_circle(pos, NODE_RADIUS_BOSS + 4.0, Color(color.r, color.g, color.b, 0.15))
	# Main circle
	draw_circle(pos, NODE_RADIUS_BOSS, Color(0.92, 0.88, 0.82))
	draw_arc(pos, NODE_RADIUS_BOSS, 0, TAU, 32, color, 3.0)
	# Inner decorative ring
	draw_arc(pos, NODE_RADIUS_BOSS * 0.7, 0, TAU, 24, color, 1.5)
	# Star/crown shape in center
	var star_size := 12.0
	for i in range(5):
		var angle := -PI / 2.0 + i * TAU / 5.0
		var point := pos + Vector2(cos(angle), sin(angle)) * star_size
		var next_angle := angle + TAU / 10.0
		var inner_point := pos + Vector2(cos(next_angle), sin(next_angle)) * (star_size * 0.4)
		draw_line(point, inner_point, color, 2.0)
		var next_outer_angle := angle + TAU / 5.0
		var next_outer := pos + Vector2(cos(next_outer_angle), sin(next_outer_angle)) * star_size
		draw_line(inner_point, next_outer, color, 2.0)


## START: Flag triangle
func _draw_start_icon(pos: Vector2, color: Color, outline: Color) -> void:
	draw_circle(pos, NODE_RADIUS, Color(0.92, 0.88, 0.82))
	draw_arc(pos, NODE_RADIUS, 0, TAU, 24, outline, 2.0)
	# Flag pole
	draw_line(pos + Vector2(-6, 12), pos + Vector2(-6, -12), color, 2.0)
	# Flag
	var flag_points := PackedVector2Array([
		pos + Vector2(-6, -12),
		pos + Vector2(10, -6),
		pos + Vector2(-6, 0),
	])
	draw_colored_polygon(flag_points, color)


## Handle input: node clicks and scroll.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			match mb.button_index:
				MOUSE_BUTTON_LEFT:
					var clicked_node := _get_node_at_position(mb.position)
					if clicked_node and clicked_node.available:
						node_selected.emit(clicked_node.id)
				MOUSE_BUTTON_WHEEL_UP:
					scroll_offset = maxf(0.0, scroll_offset - SCROLL_SPEED)
					queue_redraw()
				MOUSE_BUTTON_WHEEL_DOWN:
					var max_scroll := maxf(0.0, _map_height - size.y)
					scroll_offset = minf(max_scroll, scroll_offset + SCROLL_SPEED)
					queue_redraw()

	elif event is InputEventMouseMotion:
		# Could add hover effects here
		pass


## Find which node (if any) is at the given screen position.
func _get_node_at_position(pos: Vector2) -> MapData.MapNode:
	if not map_data.has("nodes"):
		return null

	var best_node: MapData.MapNode = null
	var best_dist := HIT_RADIUS

	for node in map_data["nodes"]:
		var node_screen_pos := node.position - Vector2(0, scroll_offset)
		var dist := pos.distance_to(node_screen_pos)
		var radius := NODE_RADIUS_BOSS if node.type == MapData.NodeType.BOSS else NODE_RADIUS
		if dist < radius + 6.0 and dist < best_dist:
			best_dist = dist
			best_node = node

	return best_node


## Update node states after the player moves to a new node.
## Call this from game logic when a node is selected.
func move_to_node(node_id: int) -> void:
	if not _id_map.has(node_id):
		return

	# Mark old available nodes as no longer available
	for node in map_data["nodes"]:
		node.available = false

	# Update current node
	current_node_id = node_id
	var current: MapData.MapNode = _id_map[node_id]
	current.visited = true

	# Mark connected nodes as available
	for conn_id in current.connections:
		if _id_map.has(conn_id):
			_id_map[conn_id].available = true

	# Scroll to show current node area
	var target_scroll := current.position.y - size.y * 0.6
	scroll_offset = clampf(target_scroll, 0.0, maxf(0.0, _map_height - size.y))

	queue_redraw()
