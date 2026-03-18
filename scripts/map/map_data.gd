class_name MapData
extends RefCounted
## Data structures for the roguelike voyage map.
## Represents nodes (ports) and their connections across Zheng He's maritime routes.

enum NodeType {
	COMBAT,     # 战斗 - Naval battle or pirate encounter
	ELITE,      # 精英 - Powerful enemy fleet
	EVENT,      # 事件 - Story event or diplomatic encounter
	REST,       # 休息 - Safe harbor for repairs
	SHOP,       # 商店 - Trading post
	TREASURE,   # 宝箱 - Treasure discovery
	BOSS,       # Boss - Act boss battle
	START,      # 起点 - Departure port
}


## A single map node representing a port or encounter along the voyage.
class MapNode:
	var id: int = 0
	var row: int = 0
	var col: int = 0
	var type: int = NodeType.COMBAT
	var connections: Array[int] = []  # IDs of nodes this connects to
	var visited: bool = false
	var available: bool = false  # Can the player move here?
	var position: Vector2 = Vector2.ZERO  # Screen position for rendering
	var port_name: String = ""  # Historical port name (English)
	var port_name_zh: String = ""  # Historical port name (Chinese)

	func _init() -> void:
		connections = []

	func _to_string() -> String:
		return "MapNode(id=%d, row=%d, col=%d, type=%s, port=%s)" % [
			id, row, col, NodeType.keys()[type], port_name
		]
