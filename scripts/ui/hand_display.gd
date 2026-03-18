extends Control
class_name HandDisplay

var _card_displays: Array[CardDisplay] = []
var _card_scene: PackedScene  # Not used - we create cards programmatically
var card_spacing: float = 130.0
var hand_y: float = 500.0  # Y position of hand
var hand_center_x: float = 640.0  # Center of screen

signal card_selected(card_data, card_display)


func update_hand(hand_cards: Array[Resource]) -> void:
	# Remove old card displays
	for child in _card_displays:
		child.queue_free()
	_card_displays.clear()

	# Create new card displays
	for i in hand_cards.size():
		var card_display = CardDisplay.new()
		card_display.setup(hand_cards[i])
		card_display.card_index = i
		add_child(card_display)
		_card_displays.append(card_display)
		# Connect signals
		card_display.card_drag_ended.connect(_on_card_drag_ended)
		card_display.card_hovered.connect(_on_card_hovered)
		card_display.card_unhovered.connect(_on_card_unhovered)

	_arrange_cards()


func _arrange_cards() -> void:
	var count := _card_displays.size()
	if count == 0:
		return
	var total_width = (count - 1) * card_spacing
	var start_x = hand_center_x - total_width / 2.0
	for i in count:
		var pos = Vector2(start_x + i * card_spacing - 60, hand_y)
		_card_displays[i].set_original_pos(pos)


func _on_card_drag_ended(card_display: CardDisplay, end_pos: Vector2):
	# If dragged to upper half of screen (y < 350), consider it played
	if end_pos.y < 350:
		card_selected.emit(card_display.card_data, card_display)
	else:
		card_display.return_to_hand()


func _on_card_hovered(_card_display: CardDisplay):
	pass


func _on_card_unhovered(_card_display: CardDisplay):
	pass


func get_card_displays() -> Array[CardDisplay]:
	return _card_displays
