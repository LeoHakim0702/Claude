class_name EnemyData
extends Resource

enum EnemyType {
	NORMAL = 0,
	ELITE = 1,
	BOSS = 2,
}

@export var id: String = ""
@export var enemy_name: String = ""
@export var enemy_name_zh: String = ""
@export var type: int = EnemyType.NORMAL
@export var hp_min: int = 0
@export var hp_max: int = 0
@export var moves: Array[Dictionary] = []
@export var ai_type: String = "CYCLE"
@export var ai_params: Dictionary = {}
