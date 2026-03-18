extends Control

var _title: Label
var _subtitle: Label
var _tagline: Label
var _start_btn: Button
var _quit_btn: Button
var _lang_btn: Button
var _ver: Label


func _ready():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.08, 0.15)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Title
	_title = Label.new()
	_title.position = Vector2(400, 150)
	_title.add_theme_font_size_override("font_size", 48)
	_title.add_theme_color_override("font_color", Color(0.9, 0.75, 0.3))
	add_child(_title)

	_subtitle = Label.new()
	_subtitle.position = Vector2(420, 220)
	_subtitle.add_theme_font_size_override("font_size", 24)
	_subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	add_child(_subtitle)

	_tagline = Label.new()
	_tagline.position = Vector2(390, 260)
	_tagline.add_theme_font_size_override("font_size", 16)
	_tagline.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	add_child(_tagline)

	# Start button
	_start_btn = Button.new()
	_start_btn.position = Vector2(490, 380)
	_start_btn.custom_minimum_size = Vector2(300, 60)
	_start_btn.add_theme_font_size_override("font_size", 20)
	_start_btn.pressed.connect(_on_start_pressed)
	add_child(_start_btn)

	# Quit button
	_quit_btn = Button.new()
	_quit_btn.position = Vector2(540, 460)
	_quit_btn.custom_minimum_size = Vector2(200, 40)
	_quit_btn.pressed.connect(func(): get_tree().quit())
	add_child(_quit_btn)

	# Language toggle button (top-right corner)
	_lang_btn = Button.new()
	_lang_btn.position = Vector2(1140, 15)
	_lang_btn.custom_minimum_size = Vector2(120, 36)
	_lang_btn.add_theme_font_size_override("font_size", 16)
	_lang_btn.pressed.connect(_on_lang_toggle)
	add_child(_lang_btn)

	# Version info
	_ver = Label.new()
	_ver.position = Vector2(20, 690)
	_ver.add_theme_font_size_override("font_size", 12)
	_ver.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	add_child(_ver)

	Locale.language_changed.connect(_on_language_changed)
	_update_texts()


func _update_texts() -> void:
	_title.text = Locale.t("Voyages of Zheng He", "郑和下西洋")
	_subtitle.text = Locale.t("A Roguelike Deckbuilder", "肉鸽卡牌构筑游戏")
	_tagline.text = Locale.t(
		"Navigate the seas, build your deck, forge alliances",
		"纵横四海，构筑牌组，缔结同盟"
	)
	_start_btn.text = Locale.t("Start Voyage", "开始航行")
	_quit_btn.text = Locale.t("Quit", "退出")
	_ver.text = "v0.2.0"

	# Language button shows the OTHER language as the action
	_lang_btn.text = Locale.t("中文", "English")


func _on_lang_toggle() -> void:
	Locale.toggle_language()


func _on_language_changed(_lang: String) -> void:
	_update_texts()


func _on_start_pressed():
	GameState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/combat/combat_scene.tscn")
