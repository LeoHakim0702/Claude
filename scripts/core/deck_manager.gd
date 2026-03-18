class_name DeckManager
extends RefCounted

var draw_pile: Array = []
var hand: Array = []
var discard_pile: Array = []
var exhaust_pile: Array = []
var max_hand_size: int = 10
var _rng: RandomNumberGenerator


func init_combat(deck: Array, rng: RandomNumberGenerator) -> void:
	_rng = rng
	draw_pile = deck.duplicate()
	hand = []
	discard_pile = []
	exhaust_pile = []
	shuffle_draw_pile()


func shuffle_draw_pile() -> void:
	var n: int = draw_pile.size()
	for i in range(n - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var temp = draw_pile[i]
		draw_pile[i] = draw_pile[j]
		draw_pile[j] = temp


func draw_cards(count: int) -> void:
	for i in range(count):
		if hand.size() >= max_hand_size:
			break
		if draw_pile.is_empty():
			_reshuffle()
		if draw_pile.is_empty():
			break
		var card = draw_pile.pop_back()
		hand.append(card)
		EventBus.card_drawn.emit(card)


func discard_card(card) -> void:
	var idx: int = hand.find(card)
	if idx >= 0:
		hand.remove_at(idx)
	discard_pile.append(card)
	EventBus.card_discarded.emit(card)


func discard_hand() -> void:
	while not hand.is_empty():
		var card = hand.pop_back()
		discard_pile.append(card)
		EventBus.card_discarded.emit(card)


func exhaust_card(card) -> void:
	var idx: int = hand.find(card)
	if idx >= 0:
		hand.remove_at(idx)
	else:
		idx = discard_pile.find(card)
		if idx >= 0:
			discard_pile.remove_at(idx)
		else:
			idx = draw_pile.find(card)
			if idx >= 0:
				draw_pile.remove_at(idx)
	exhaust_pile.append(card)
	EventBus.card_exhausted.emit(card)


func add_to_hand(card) -> void:
	if hand.size() < max_hand_size:
		hand.append(card)


func add_to_discard(card) -> void:
	discard_pile.append(card)


func get_draw_count() -> int:
	return draw_pile.size()


func get_discard_count() -> int:
	return discard_pile.size()


func _reshuffle() -> void:
	draw_pile.append_array(discard_pile)
	discard_pile.clear()
	shuffle_draw_pile()
