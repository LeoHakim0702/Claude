extends Control
class_name PlayerHUD

var _hp_label: Label
var _block_label: Label
var _energy_label: Label
var _draw_count_label: Label
var _discard_count_label: Label


func _ready() -> void:
	# Build UI programmatically
	# HP section (left side)
	_hp_label = Label.new()
	_hp_label.position = Vector2(20, 10)
	_hp_label.add_theme_font_size_override("font_size", 18)
	_hp_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	add_child(_hp_label)

	_block_label = Label.new()
	_block_label.position = Vector2(20, 35)
	_block_label.add_theme_font_size_override("font_size", 16)
	_block_label.add_theme_color_override("font_color", Color(0.3, 0.5, 0.9))
	add_child(_block_label)

	# Energy (center-left)
	_energy_label = Label.new()
	_energy_label.position = Vector2(200, 10)
	_energy_label.add_theme_font_size_override("font_size", 22)
	_energy_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	add_child(_energy_label)

	# Deck counts (right side)
	_draw_count_label = Label.new()
	_draw_count_label.position = Vector2(400, 10)
	_draw_count_label.add_theme_font_size_override("font_size", 14)
	_draw_count_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	add_child(_draw_count_label)

	_discard_count_label = Label.new()
	_discard_count_label.position = Vector2(400, 30)
	_discard_count_label.add_theme_font_size_override("font_size", 14)
	_discard_count_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	add_child(_discard_count_label)


func update_hud(hp: int, max_hp: int, block: int, energy: int, max_energy: int, draw_count: int, discard_count: int) -> void:
	_hp_label.text = Locale.t("HP: %d / %d" % [hp, max_hp], "生命: %d / %d" % [hp, max_hp])
	_block_label.text = Locale.t("Block: %d" % block, "格挡: %d" % block)
	_energy_label.text = Locale.t("Energy: %d / %d" % [energy, max_energy], "能量: %d / %d" % [energy, max_energy])
	_draw_count_label.text = Locale.t("Draw Pile: %d" % draw_count, "抽牌堆: %d" % draw_count)
	_discard_count_label.text = Locale.t("Discard: %d" % discard_count, "弃牌堆: %d" % discard_count)
