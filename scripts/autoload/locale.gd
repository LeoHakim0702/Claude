extends Node
## 语言管理器 - Language Manager
## Global singleton for switching between English and Chinese.

signal language_changed(lang: String)

## Current language: "en" or "zh"
var current_lang: String = "zh"

const SAVE_PATH := "user://language.cfg"


func _ready() -> void:
	_load_language()


func set_language(lang: String) -> void:
	if lang != "en" and lang != "zh":
		return
	if lang == current_lang:
		return
	current_lang = lang
	_save_language()
	language_changed.emit(current_lang)


func toggle_language() -> void:
	set_language("en" if current_lang == "zh" else "zh")


func is_zh() -> bool:
	return current_lang == "zh"


func is_en() -> bool:
	return current_lang == "en"


## Pick the right string based on current language.
## Usage: Locale.t(english_text, chinese_text)
func t(en_text: String, zh_text: String) -> String:
	return zh_text if current_lang == "zh" else en_text


## For data objects that have paired name/name_zh fields.
func pick(en_value: String, zh_value: String) -> String:
	if current_lang == "zh" and zh_value != "":
		return zh_value
	return en_value


func _save_language() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(current_lang)
		f.close()


func _load_language() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f:
		var lang := f.get_as_text().strip_edges()
		if lang == "en" or lang == "zh":
			current_lang = lang
		f.close()
