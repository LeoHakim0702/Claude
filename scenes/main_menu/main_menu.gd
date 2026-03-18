extends Control


func _ready():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.08, 0.15)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Title
	var title = Label.new()
	title.text = "Voyages of Zheng He"
	title.position = Vector2(400, 150)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.9, 0.75, 0.3))
	add_child(title)

	var subtitle = Label.new()
	subtitle.text = "A Roguelike Deckbuilder"
	subtitle.position = Vector2(420, 220)
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	add_child(subtitle)

	var tagline = Label.new()
	tagline.text = "A Roguelike Deckbuilder"
	tagline.position = Vector2(390, 260)
	tagline.add_theme_font_size_override("font_size", 16)
	tagline.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	add_child(tagline)

	# Start button
	var start_btn = Button.new()
	start_btn.text = "Start Voyage"
	start_btn.position = Vector2(490, 380)
	start_btn.custom_minimum_size = Vector2(300, 60)
	start_btn.add_theme_font_size_override("font_size", 20)
	start_btn.pressed.connect(_on_start_pressed)
	add_child(start_btn)

	# Quit button
	var quit_btn = Button.new()
	quit_btn.text = "Quit"
	quit_btn.position = Vector2(540, 460)
	quit_btn.custom_minimum_size = Vector2(200, 40)
	quit_btn.pressed.connect(func(): get_tree().quit())
	add_child(quit_btn)

	# Version info
	var ver = Label.new()
	ver.text = "v0.1.0 - Phase 1 MVP"
	ver.position = Vector2(20, 690)
	ver.add_theme_font_size_override("font_size", 12)
	ver.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	add_child(ver)


func _on_start_pressed():
	GameState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/combat/combat_scene.tscn")
