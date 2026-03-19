extends Control

const BG_COLOR := Color(0.02, 0.06, 0.12)
const TITLE_GOLD := Color(0.9, 0.75, 0.3)
const SUBTITLE_COLOR := Color(0.7, 0.7, 0.8)
const TAGLINE_COLOR := Color(0.5, 0.5, 0.6)
const BTN_NORMAL := Color(0.12, 0.15, 0.22)
const BTN_HOVER := Color(0.18, 0.22, 0.32)
const BTN_TEXT := Color(0.9, 0.85, 0.7)
const BTN_DISABLED_TEXT := Color(0.4, 0.4, 0.45)
const ACCENT_RED := Color(0.8, 0.2, 0.15)
const ACCENT_GOLD := Color(0.85, 0.7, 0.3)

var _title: Label
var _subtitle: Label
var _tagline: Label
var _start_btn: Button
var _continue_btn: Button
var _settings_btn: Button
var _encyclopedia_btn: Button
var _quit_btn: Button
var _lang_btn: Button
var _ver: Label


func _ready():
	# Background
	var bg = ColorRect.new()
	bg.color = BG_COLOR
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Decorative top bar
	var top_bar = ColorRect.new()
	top_bar.color = ACCENT_RED
	top_bar.position = Vector2(0, 0)
	top_bar.size = Vector2(1280, 4)
	add_child(top_bar)

	# Title
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.position = Vector2(240, 100)
	_title.custom_minimum_size = Vector2(800, 60)
	_title.add_theme_font_size_override("font_size", 52)
	_title.add_theme_color_override("font_color", TITLE_GOLD)
	add_child(_title)

	_subtitle = Label.new()
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.position = Vector2(240, 170)
	_subtitle.custom_minimum_size = Vector2(800, 40)
	_subtitle.add_theme_font_size_override("font_size", 22)
	_subtitle.add_theme_color_override("font_color", SUBTITLE_COLOR)
	add_child(_subtitle)

	_tagline = Label.new()
	_tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tagline.position = Vector2(240, 205)
	_tagline.custom_minimum_size = Vector2(800, 30)
	_tagline.add_theme_font_size_override("font_size", 14)
	_tagline.add_theme_color_override("font_color", TAGLINE_COLOR)
	add_child(_tagline)

	# Menu buttons - centered vertically
	var btn_x := 440
	var btn_w := 400
	var btn_h := 55
	var btn_gap := 12
	var btn_start_y := 280

	_start_btn = _create_menu_button(btn_x, btn_start_y, btn_w, btn_h, 22)
	_start_btn.pressed.connect(_on_start_pressed)
	add_child(_start_btn)

	_continue_btn = _create_menu_button(btn_x, btn_start_y + (btn_h + btn_gap), btn_w, btn_h, 18)
	_continue_btn.pressed.connect(_on_continue_pressed)
	add_child(_continue_btn)

	_encyclopedia_btn = _create_menu_button(btn_x, btn_start_y + (btn_h + btn_gap) * 2, btn_w, btn_h, 18)
	_encyclopedia_btn.pressed.connect(_on_encyclopedia_pressed)
	add_child(_encyclopedia_btn)

	_settings_btn = _create_menu_button(btn_x, btn_start_y + (btn_h + btn_gap) * 3, btn_w, btn_h, 18)
	_settings_btn.pressed.connect(_on_settings_pressed)
	add_child(_settings_btn)

	_quit_btn = _create_menu_button(btn_x, btn_start_y + (btn_h + btn_gap) * 4, btn_w, btn_h, 18)
	_quit_btn.pressed.connect(func(): get_tree().quit())
	add_child(_quit_btn)

	# Language toggle button (top-right corner)
	_lang_btn = Button.new()
	_lang_btn.position = Vector2(1140, 15)
	_lang_btn.custom_minimum_size = Vector2(120, 36)
	_lang_btn.add_theme_font_size_override("font_size", 16)
	_lang_btn.pressed.connect(_on_lang_toggle)
	add_child(_lang_btn)

	# Decorative bottom waves
	var bottom_bar = ColorRect.new()
	bottom_bar.color = Color(0.15, 0.25, 0.35, 0.5)
	bottom_bar.position = Vector2(0, 650)
	bottom_bar.size = Vector2(1280, 70)
	add_child(bottom_bar)

	# Version info
	_ver = Label.new()
	_ver.position = Vector2(20, 692)
	_ver.add_theme_font_size_override("font_size", 12)
	_ver.add_theme_color_override("font_color", Color(0.35, 0.35, 0.4))
	add_child(_ver)

	Locale.language_changed.connect(_on_language_changed)
	_update_texts()


func _create_menu_button(x: float, y: float, w: float, h: float, font_size: int) -> Button:
	var btn := Button.new()
	btn.position = Vector2(x, y)
	btn.custom_minimum_size = Vector2(w, h)
	btn.add_theme_font_size_override("font_size", font_size)
	return btn


func _update_texts() -> void:
	_title.text = Locale.t("Voyages of Zheng He", "郑和下西洋")
	_subtitle.text = Locale.t("A Roguelike Deckbuilder", "肉鸽卡牌构筑游戏")
	_tagline.text = Locale.t(
		"Navigate the seas, build your deck, forge alliances",
		"纵横四海，构筑牌组，缔结同盟"
	)
	_start_btn.text = Locale.t("Start Game", "开始游戏")
	_continue_btn.text = Locale.t("Continue Game", "继续游戏")
	_encyclopedia_btn.text = Locale.t("Encyclopedia", "百科大全")
	_settings_btn.text = Locale.t("Settings", "设置")
	_quit_btn.text = Locale.t("Quit", "退出")
	_ver.text = "v0.3.0"

	# Language button shows the OTHER language as the action
	_lang_btn.text = Locale.t("中文", "English")

	# Disable continue if no save exists
	var has_save := GameState.has_run_save()
	_continue_btn.disabled = not has_save
	if not has_save:
		_continue_btn.tooltip_text = Locale.t("No saved game found", "未找到存档")


func _on_lang_toggle() -> void:
	Locale.toggle_language()


func _on_language_changed(_lang: String) -> void:
	_update_texts()


func _on_start_pressed():
	# Go to Liujiagang base to prepare before voyage
	get_tree().change_scene_to_file("res://scenes/base/base_scene.tscn")


func _on_continue_pressed():
	if GameState.load_run_save():
		# Restore to map scene
		get_tree().change_scene_to_file("res://scenes/map/map_scene.tscn")


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/settings/settings_scene.tscn")


func _on_encyclopedia_pressed():
	get_tree().change_scene_to_file("res://scenes/encyclopedia/encyclopedia_scene.tscn")
