extends Control

## Settings scene - Language, display, and game options.

const BG_COLOR := Color(0.02, 0.06, 0.12)
const PANEL_BG := Color(0.08, 0.10, 0.16)
const TITLE_COLOR := Color(0.9, 0.75, 0.3)
const TEXT_COLOR := Color(0.85, 0.82, 0.75)
const LABEL_COLOR := Color(0.6, 0.58, 0.52)

var _lang_btn: Button
var _fullscreen_btn: Button
var _screenshake_btn: Button
var _back_btn: Button

# Settings stored in config
var _settings := {
	"fullscreen": false,
	"screenshake": true,
}


func _ready() -> void:
	_load_settings()
	_build_ui()


func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.color = BG_COLOR
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Title
	var title := Label.new()
	title.text = Locale.t("Settings", "设置")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(340, 40)
	title.custom_minimum_size = Vector2(600, 50)
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", TITLE_COLOR)
	add_child(title)

	# Settings panel
	var panel := ColorRect.new()
	panel.color = PANEL_BG
	panel.position = Vector2(290, 110)
	panel.size = Vector2(700, 450)
	add_child(panel)

	var y_offset := 140

	# Language setting
	_add_setting_label(Locale.t("Language", "语言"), y_offset)
	_lang_btn = Button.new()
	_lang_btn.position = Vector2(690, y_offset)
	_lang_btn.custom_minimum_size = Vector2(250, 45)
	_lang_btn.add_theme_font_size_override("font_size", 18)
	_lang_btn.text = Locale.t("中文 (Chinese)", "English (英文)")
	_lang_btn.pressed.connect(_on_lang_toggle)
	add_child(_lang_btn)
	y_offset += 70

	# Fullscreen setting
	_add_setting_label(Locale.t("Fullscreen", "全屏模式"), y_offset)
	_fullscreen_btn = Button.new()
	_fullscreen_btn.position = Vector2(690, y_offset)
	_fullscreen_btn.custom_minimum_size = Vector2(250, 45)
	_fullscreen_btn.add_theme_font_size_override("font_size", 18)
	_update_fullscreen_btn()
	_fullscreen_btn.pressed.connect(_on_fullscreen_toggle)
	add_child(_fullscreen_btn)
	y_offset += 70

	# Screen shake setting
	_add_setting_label(Locale.t("Screen Shake", "屏幕震动"), y_offset)
	_screenshake_btn = Button.new()
	_screenshake_btn.position = Vector2(690, y_offset)
	_screenshake_btn.custom_minimum_size = Vector2(250, 45)
	_screenshake_btn.add_theme_font_size_override("font_size", 18)
	_update_screenshake_btn()
	_screenshake_btn.pressed.connect(_on_screenshake_toggle)
	add_child(_screenshake_btn)
	y_offset += 70

	# Delete save data
	_add_setting_label(Locale.t("Delete Save Data", "删除存档数据"), y_offset)
	var delete_btn := Button.new()
	delete_btn.position = Vector2(690, y_offset)
	delete_btn.custom_minimum_size = Vector2(250, 45)
	delete_btn.add_theme_font_size_override("font_size", 18)
	delete_btn.text = Locale.t("Delete", "删除")
	delete_btn.pressed.connect(_on_delete_save)
	add_child(delete_btn)
	y_offset += 70

	# Version info
	var ver_label := Label.new()
	ver_label.text = Locale.t("Version: v0.3.0", "版本: v0.3.0")
	ver_label.position = Vector2(540, y_offset + 20)
	ver_label.add_theme_font_size_override("font_size", 14)
	ver_label.add_theme_color_override("font_color", LABEL_COLOR)
	add_child(ver_label)

	# Back button
	_back_btn = Button.new()
	_back_btn.text = Locale.t("Back", "返回")
	_back_btn.position = Vector2(540, 590)
	_back_btn.custom_minimum_size = Vector2(200, 50)
	_back_btn.add_theme_font_size_override("font_size", 20)
	_back_btn.pressed.connect(_on_back)
	add_child(_back_btn)

	Locale.language_changed.connect(_on_language_changed)


func _add_setting_label(text: String, y: float) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(340, y + 8)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", TEXT_COLOR)
	add_child(label)


func _on_lang_toggle() -> void:
	Locale.toggle_language()


func _on_language_changed(_lang: String) -> void:
	# Rebuild UI to update all texts
	for child in get_children():
		child.queue_free()
	_build_ui()


func _on_fullscreen_toggle() -> void:
	_settings.fullscreen = not _settings.fullscreen
	if _settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_update_fullscreen_btn()
	_save_settings()


func _on_screenshake_toggle() -> void:
	_settings.screenshake = not _settings.screenshake
	_update_screenshake_btn()
	_save_settings()


func _update_fullscreen_btn() -> void:
	var on_text := Locale.t("ON", "开")
	var off_text := Locale.t("OFF", "关")
	_fullscreen_btn.text = on_text if _settings.fullscreen else off_text


func _update_screenshake_btn() -> void:
	var on_text := Locale.t("ON", "开")
	var off_text := Locale.t("OFF", "关")
	_screenshake_btn.text = on_text if _settings.screenshake else off_text


func _on_delete_save() -> void:
	GameState.delete_run_save()


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _save_settings() -> void:
	var save_file := FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(_settings))


func _load_settings() -> void:
	if not FileAccess.file_exists("user://settings.cfg"):
		return
	var save_file := FileAccess.open("user://settings.cfg", FileAccess.READ)
	if not save_file:
		return
	var json := JSON.new()
	if json.parse(save_file.get_as_text()) == OK:
		var data: Dictionary = json.data
		_settings.fullscreen = data.get("fullscreen", false)
		_settings.screenshake = data.get("screenshake", true)
