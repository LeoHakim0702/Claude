extends Control
class_name EnemyDisplay

var _enemy: EnemyInstance = null
var _is_hovered: bool = false
var display_index: int = 0

signal enemy_clicked(enemy_display)


func setup(enemy_instance: EnemyInstance, index: int = 0) -> void:
	_enemy = enemy_instance
	display_index = index
	custom_minimum_size = Vector2(140, 200)
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()


func _draw():
	if _enemy == null:
		return
	var rect = Rect2(Vector2.ZERO, Vector2(140, 200))

	# Enemy body (colored rectangle based on type)
	var body_color: Color
	match _enemy.data.type:
		0:
			body_color = Color(0.6, 0.3, 0.3)  # NORMAL
		1:
			body_color = Color(0.8, 0.5, 0.1)  # ELITE
		2:
			body_color = Color(0.6, 0.1, 0.1)  # BOSS
		_:
			body_color = Color(0.5, 0.4, 0.4)
	draw_rect(Rect2(20, 40, 100, 100), body_color)
	draw_rect(Rect2(20, 40, 100, 100), Color.BLACK, false, 2.0)

	# Name
	var font = ThemeDB.fallback_font
	var font_size = 14
	var display_name: String = Locale.pick(_enemy.enemy_name, _enemy.enemy_name_zh)
	draw_string(font, Vector2(10, 25), display_name, HORIZONTAL_ALIGNMENT_CENTER, 130, font_size, Color.WHITE)

	# HP bar
	var hp_ratio = float(_enemy.current_hp) / float(_enemy.max_hp)
	var bar_width = 100.0
	draw_rect(Rect2(20, 150, bar_width, 12), Color(0.3, 0.0, 0.0))
	draw_rect(Rect2(20, 150, bar_width * hp_ratio, 12), Color(0.8, 0.1, 0.1))
	draw_rect(Rect2(20, 150, bar_width, 12), Color.BLACK, false, 1.0)
	var hp_text = "%d/%d" % [_enemy.current_hp, _enemy.max_hp]
	draw_string(font, Vector2(30, 161), hp_text, HORIZONTAL_ALIGNMENT_LEFT, 80, 10, Color.WHITE)

	# Block (if any)
	if _enemy.block > 0:
		draw_circle(Vector2(120, 60), 15, Color(0.2, 0.4, 0.8))
		draw_string(font, Vector2(112, 65), str(_enemy.block), HORIZONTAL_ALIGNMENT_LEFT, 30, 12, Color.WHITE)

	# Intent display
	var intent = _enemy.get_intent_display()
	if intent.size() > 0:
		var intent_y = 175
		var intent_type: String = intent.get("type", "unknown")
		var intent_color: Color
		var intent_text: String
		match intent_type:
			"attack":
				intent_color = Color(1.0, 0.3, 0.3)
				var dmg: int = intent.get("damage", 0)
				var hits: int = intent.get("hits", 1)
				if hits > 1:
					intent_text = "Atk %dx%d" % [dmg, hits]
				else:
					intent_text = "Atk %d" % dmg
			"defend":
				intent_color = Color(0.3, 0.6, 1.0)
				intent_text = "Def %d" % intent.get("block", 0)
			"buff":
				intent_color = Color(0.3, 0.9, 0.3)
				intent_text = "Buff"
			_:
				intent_color = Color(0.7, 0.7, 0.7)
				intent_text = "..."
		draw_string(font, Vector2(20, intent_y + 12), intent_text, HORIZONTAL_ALIGNMENT_LEFT, 120, 12, intent_color)

	# Status effects
	var status_x = 20
	for status_id in _enemy.statuses:
		var stacks = _enemy.statuses[status_id]
		var s_color: Color
		if status_id in ["vulnerable", "weak", "burn"]:
			s_color = Color(0.8, 0.2, 0.2)
		else:
			s_color = Color(0.2, 0.8, 0.2)
		draw_circle(Vector2(status_x + 6, 145), 6, s_color)
		draw_string(font, Vector2(status_x, 148), str(stacks), HORIZONTAL_ALIGNMENT_LEFT, 15, 8, Color.WHITE)
		status_x += 16

	# Highlight if hovered
	if _is_hovered:
		draw_rect(rect, Color(1, 1, 1, 0.15))


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		enemy_clicked.emit(self)


func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER:
		_is_hovered = true
		queue_redraw()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_is_hovered = false
		queue_redraw()


func update_display() -> void:
	queue_redraw()


func get_enemy() -> EnemyInstance:
	return _enemy if _enemy else null
