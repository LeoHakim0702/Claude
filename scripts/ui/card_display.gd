extends Control
class_name CardDisplay

var card_data = null
var _is_hovered: bool = false
var _is_dragging: bool = false
var _drag_offset: Vector2
var _original_position: Vector2
var card_index: int = -1

signal card_clicked(card_display)
signal card_drag_started(card_display)
signal card_drag_ended(card_display, position: Vector2)
signal card_hovered(card_display)
signal card_unhovered(card_display)


func _ready():
	custom_minimum_size = Vector2(120, 170)
	mouse_filter = Control.MOUSE_FILTER_STOP


func setup(data) -> void:
	card_data = data
	queue_redraw()


func _draw():
	if card_data == null:
		return

	var font = ThemeDB.fallback_font
	var font_size = ThemeDB.fallback_font_size
	var rect = Rect2(Vector2.ZERO, Vector2(120, 170))

	# Background color based on card type
	var bg_color: Color
	match card_data.type:
		0:  # ATTACK
			bg_color = Color(0.8, 0.2, 0.2)
		1:  # SKILL
			bg_color = Color(0.2, 0.5, 0.8)
		2:  # POWER
			bg_color = Color(0.7, 0.6, 0.1)
		_:  # CURSE or other
			bg_color = Color(0.4, 0.1, 0.4)

	# Card body rounded rect
	draw_rect(rect, bg_color)

	# Border (darker shade)
	var border_color = bg_color.darkened(0.4)
	draw_rect(rect, border_color, false, 2.0)

	# Cost circle in top-left
	var cost_center = Vector2(18, 18)
	draw_circle(cost_center, 14, Color(0.1, 0.1, 0.4))
	draw_circle(cost_center, 14, Color(0.05, 0.05, 0.2), false, 2.0)
	var cost_str = str(card_data.cost)
	draw_string(font, Vector2(12, 23), cost_str, HORIZONTAL_ALIGNMENT_LEFT, 20, font_size, Color.WHITE)

	# Card name centered near top
	var name_str: String = Locale.pick(
		card_data.card_name if card_data.card_name else "",
		card_data.card_name_zh if card_data.card_name_zh else ""
	)
	draw_string(font, Vector2(5, 48), name_str, HORIZONTAL_ALIGNMENT_CENTER, 110, font_size, Color.WHITE)

	var small_size = maxi(font_size - 4, 8)

	# Description text in middle area
	var desc_size = maxi(font_size - 4, 8)
	var desc_text: String = Locale.pick(
		card_data.description if card_data.description else "...",
		card_data.description_zh if card_data.description_zh else card_data.description if card_data.description else "..."
	)
	draw_string(font, Vector2(8, 78), desc_text, HORIZONTAL_ALIGNMENT_CENTER, 104, desc_size, Color(0.95, 0.95, 0.9))

	# Type label at bottom
	var type_str: String
	match card_data.type:
		0:
			type_str = Locale.tr("Attack", "攻击")
		1:
			type_str = Locale.tr("Skill", "技能")
		2:
			type_str = Locale.tr("Power", "能力")
		_:
			type_str = Locale.tr("Curse", "诅咒")
	draw_string(font, Vector2(5, 160), type_str, HORIZONTAL_ALIGNMENT_CENTER, 110, small_size, Color(0.8, 0.8, 0.8))


func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging = true
				_drag_offset = global_position - get_global_mouse_position()
				card_drag_started.emit(self)
			else:
				if _is_dragging:
					_is_dragging = false
					card_drag_ended.emit(self, get_global_mouse_position())
	elif event is InputEventMouseMotion:
		if _is_dragging:
			global_position = get_global_mouse_position() + _drag_offset


func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER:
		_is_hovered = true
		card_hovered.emit(self)
		position.y -= 30
		z_index = 10
	elif what == NOTIFICATION_MOUSE_EXIT:
		_is_hovered = false
		card_unhovered.emit(self)
		position = _original_position
		z_index = 0


func set_original_pos(pos: Vector2):
	_original_position = pos
	position = pos


func return_to_hand():
	position = _original_position
	_is_dragging = false
