class_name InkWashRenderer
extends RefCounted
## 水墨山水画 - Chinese Ink Wash Painting Renderer
##
## A utility class providing static functions to draw traditional Chinese
## landscape painting (山水画) style backgrounds using Godot's CanvasItem
## draw API. All rendering is procedural — no image assets required.
##
## Palette:
##   Parchment  - Color(0.95, 0.92, 0.85)  rice paper base
##   Ink Black  - Color(0.10, 0.10, 0.10)   darkest ink
##   Ink Dark   - Color(0.20, 0.20, 0.18)   heavy brush
##   Ink Medium - Color(0.40, 0.40, 0.38)   mid-tone wash
##   Ink Light  - Color(0.65, 0.63, 0.60)   diluted ink
##   Ink Faint  - Color(0.80, 0.78, 0.75)   ghost wash
##   Jade Green - Color(0.40, 0.55, 0.42)   bamboo / foliage
##   Ocean Blue - Color(0.25, 0.32, 0.42)   deep water
##   Ocean Light- Color(0.45, 0.55, 0.65)   shallow water / mist
##   Seal Red   - Color(0.78, 0.18, 0.15)   印章 vermilion
##   Wood Brown - Color(0.45, 0.35, 0.25)   ship planks / docks
##   Lantern    - Color(0.90, 0.55, 0.20)   warm lantern glow

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
const SCREEN_W: float = 1280.0
const SCREEN_H: float = 720.0

# Palette
const COL_PARCHMENT := Color(0.95, 0.92, 0.85)
const COL_PARCHMENT_DARK := Color(0.88, 0.84, 0.76)
const COL_INK_BLACK := Color(0.10, 0.10, 0.10)
const COL_INK_DARK := Color(0.20, 0.20, 0.18)
const COL_INK_MED := Color(0.40, 0.40, 0.38)
const COL_INK_LIGHT := Color(0.65, 0.63, 0.60)
const COL_INK_FAINT := Color(0.80, 0.78, 0.75)
const COL_JADE := Color(0.40, 0.55, 0.42)
const COL_JADE_LIGHT := Color(0.55, 0.68, 0.55)
const COL_OCEAN_DEEP := Color(0.25, 0.32, 0.42)
const COL_OCEAN_MID := Color(0.35, 0.44, 0.54)
const COL_OCEAN_LIGHT := Color(0.45, 0.55, 0.65)
const COL_SEAL_RED := Color(0.78, 0.18, 0.15)
const COL_WOOD_BROWN := Color(0.45, 0.35, 0.25)
const COL_WOOD_LIGHT := Color(0.58, 0.48, 0.36)
const COL_LANTERN := Color(0.90, 0.55, 0.20)
const COL_LANTERN_GLOW := Color(0.95, 0.75, 0.35, 0.35)
const COL_WHITE_MIST := Color(1.0, 1.0, 0.97, 0.25)
const COL_SPRAY := Color(0.85, 0.90, 0.95, 0.30)

# ---------------------------------------------------------------------------
# 1. Main Menu Background  主菜单
# ---------------------------------------------------------------------------
static func draw_main_menu_bg(canvas: CanvasItem) -> void:
	# Rice paper base
	canvas.draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), COL_PARCHMENT)

	# Subtle paper texture — faint horizontal brush-stroke lines
	_draw_paper_texture(canvas)

	# --- Distant mountains (3 layers, far to near) ---
	# Layer 1 — farthest, lightest
	draw_mountain_silhouette(canvas, -40.0, 380.0, 1360.0, 160.0,
		Color(COL_INK_FAINT, 0.45), 7)
	# Layer 2 — mid
	draw_mountain_silhouette(canvas, -80.0, 430.0, 1440.0, 180.0,
		Color(COL_INK_LIGHT, 0.55), 5)
	# Layer 3 — nearest, darkest
	draw_mountain_silhouette(canvas, -60.0, 480.0, 1400.0, 200.0,
		Color(COL_INK_MED, 0.65), 6)

	# --- Mist bands between mountain layers ---
	draw_ink_cloud(canvas, Vector2(300, 390), Vector2(500, 30), 0.18)
	draw_ink_cloud(canvas, Vector2(800, 410), Vector2(400, 25), 0.15)
	draw_ink_cloud(canvas, Vector2(600, 450), Vector2(550, 28), 0.20)

	# --- Cloud wisps in the sky ---
	draw_ink_cloud(canvas, Vector2(200, 120), Vector2(220, 40), 0.12)
	draw_ink_cloud(canvas, Vector2(500, 80), Vector2(300, 35), 0.10)
	draw_ink_cloud(canvas, Vector2(900, 150), Vector2(250, 38), 0.14)
	draw_ink_cloud(canvas, Vector2(1100, 100), Vector2(180, 30), 0.08)
	draw_ink_cloud(canvas, Vector2(700, 180), Vector2(200, 28), 0.11)

	# --- Flowing water at bottom ---
	for i in range(6):
		var y_pos: float = 600.0 + i * 18.0
		var alpha: float = 0.15 + i * 0.05
		var col := Color(COL_OCEAN_LIGHT.r, COL_OCEAN_LIGHT.g, COL_OCEAN_LIGHT.b, alpha)
		draw_wave_line(canvas, y_pos, 6.0 - i * 0.5, 0.012 + i * 0.002, col, 1.5)

	# Water body at very bottom
	var water_poly := PackedVector2Array()
	water_poly.append(Vector2(0, 650))
	for ix in range(65):
		var xp: float = ix * 20.0
		var yp: float = 650.0 + sin(xp * 0.02) * 5.0
		water_poly.append(Vector2(xp, yp))
	water_poly.append(Vector2(SCREEN_W, 650))
	water_poly.append(Vector2(SCREEN_W, SCREEN_H))
	water_poly.append(Vector2(0, SCREEN_H))
	canvas.draw_polygon(water_poly, [Color(COL_OCEAN_LIGHT, 0.30)])

	# --- Bamboo on left side ---
	draw_bamboo(canvas, 50, 280, 320, Color(COL_JADE, 0.5))
	draw_bamboo(canvas, 80, 310, 280, Color(COL_JADE, 0.45))
	draw_bamboo(canvas, 35, 330, 250, Color(COL_JADE_LIGHT, 0.40))

	# --- Bamboo on right side (sparser) ---
	draw_bamboo(canvas, 1210, 300, 290, Color(COL_JADE, 0.45))
	draw_bamboo(canvas, 1240, 340, 240, Color(COL_JADE_LIGHT, 0.38))

	# --- Ink splatter decorative dots ---
	_draw_ink_splatters(canvas)

	# --- Seal stamp in lower-right corner ---
	draw_chinese_seal(canvas, Vector2(1150, 600), Vector2(70, 70))


# ---------------------------------------------------------------------------
# 2. Combat Background  战斗 — ocean scene
# ---------------------------------------------------------------------------
static func draw_combat_bg(canvas: CanvasItem) -> void:
	# Deep sky gradient (ink wash style — top dark, horizon lighter)
	_draw_sky_gradient(canvas, Color(0.18, 0.22, 0.30), Color(0.50, 0.55, 0.62), 0, 350)

	# --- Dramatic clouds ---
	draw_ink_cloud(canvas, Vector2(150, 60), Vector2(350, 55), 0.22)
	draw_ink_cloud(canvas, Vector2(500, 40), Vector2(400, 50), 0.18)
	draw_ink_cloud(canvas, Vector2(900, 70), Vector2(320, 48), 0.20)
	draw_ink_cloud(canvas, Vector2(1150, 50), Vector2(260, 42), 0.16)
	# Smaller wisps
	draw_ink_cloud(canvas, Vector2(300, 130), Vector2(180, 30), 0.12)
	draw_ink_cloud(canvas, Vector2(750, 110), Vector2(220, 32), 0.14)
	draw_ink_cloud(canvas, Vector2(1050, 140), Vector2(160, 28), 0.10)

	# --- Misty horizon with distant land silhouettes ---
	draw_mountain_silhouette(canvas, -30.0, 310.0, 500.0, 60.0,
		Color(COL_INK_LIGHT, 0.30), 4)
	draw_mountain_silhouette(canvas, 800.0, 320.0, 520.0, 50.0,
		Color(COL_INK_LIGHT, 0.25), 3)

	# Horizon mist
	draw_ink_cloud(canvas, Vector2(640, 340), Vector2(1400, 35), 0.25)

	# --- Deep ocean waves (sine-curve polygons) ---
	_draw_ocean_body(canvas, 350.0)

	# --- Wave crests with spray ---
	for i in range(8):
		var y_pos: float = 360.0 + i * 30.0
		var amp: float = 10.0 + i * 2.0
		var freq: float = 0.008 + i * 0.001
		var darkness: float = 0.4 + i * 0.06
		var col := Color(COL_OCEAN_DEEP.r * (1.0 - darkness * 0.3),
			COL_OCEAN_DEEP.g * (1.0 - darkness * 0.2),
			COL_OCEAN_DEEP.b * (1.0 - darkness * 0.1), 0.6 + i * 0.04)
		draw_wave_line(canvas, y_pos, amp, freq, col, 2.0 + i * 0.3)

	# Spray / mist near waves
	for i in range(12):
		var sx: float = fmod(float(i) * 113.7, SCREEN_W)
		var sy: float = 370.0 + fmod(float(i) * 47.3, 80.0)
		canvas.draw_circle(Vector2(sx, sy), 3.0 + fmod(float(i) * 7.1, 5.0), COL_SPRAY)

	# Additional spray clusters
	_draw_spray_cluster(canvas, Vector2(200, 390), 8)
	_draw_spray_cluster(canvas, Vector2(600, 380), 10)
	_draw_spray_cluster(canvas, Vector2(1000, 395), 7)

	# --- Ship deck planks at bottom ---
	_draw_ship_deck(canvas, 560.0)


# ---------------------------------------------------------------------------
# 3. Map Background  航海图
# ---------------------------------------------------------------------------
static func draw_map_bg(canvas: CanvasItem) -> void:
	# Aged parchment base
	canvas.draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), COL_PARCHMENT)

	# Vignette effect — darker edges
	_draw_vignette(canvas)

	# Paper texture
	_draw_paper_texture(canvas)

	# --- Scroll border (double-line frame) ---
	draw_scroll_border(canvas, Rect2(30, 30, SCREEN_W - 60, SCREEN_H - 60), COL_INK_MED)

	# --- Subtle wave patterns across ocean areas ---
	for row in range(12):
		for col_idx in range(8):
			var wx: float = 100.0 + col_idx * 140.0 + fmod(float(row) * 37.0, 60.0)
			var wy: float = 180.0 + row * 40.0
			_draw_tiny_wave(canvas, Vector2(wx, wy), 20.0, Color(COL_OCEAN_LIGHT, 0.12))

	# --- Sea routes as dotted ink lines ---
	_draw_dotted_route(canvas,
		[Vector2(200, 400), Vector2(350, 350), Vector2(550, 320),
		 Vector2(750, 310), Vector2(900, 350), Vector2(1050, 400)],
		Color(COL_INK_MED, 0.6))
	_draw_dotted_route(canvas,
		[Vector2(200, 400), Vector2(300, 500), Vector2(500, 550),
		 Vector2(700, 520), Vector2(850, 480)],
		Color(COL_INK_LIGHT, 0.5))
	# A third route
	_draw_dotted_route(canvas,
		[Vector2(550, 320), Vector2(600, 250), Vector2(750, 200),
		 Vector2(900, 220)],
		Color(COL_INK_LIGHT, 0.45))

	# --- Compass rose in top-right corner ---
	_draw_compass_rose(canvas, Vector2(1130, 150), 70.0)

	# --- Small island / land indicators ---
	_draw_land_blob(canvas, Vector2(180, 380), 50.0, COL_PARCHMENT_DARK)
	_draw_land_blob(canvas, Vector2(1060, 390), 40.0, COL_PARCHMENT_DARK)
	_draw_land_blob(canvas, Vector2(900, 210), 30.0, COL_PARCHMENT_DARK)

	# Corner decorations — small seal
	draw_chinese_seal(canvas, Vector2(60, 620), Vector2(45, 45))


# ---------------------------------------------------------------------------
# 4. Base Background  刘家港 — Liujiagang harbor
# ---------------------------------------------------------------------------
static func draw_base_bg(canvas: CanvasItem) -> void:
	# Sky
	_draw_sky_gradient(canvas, Color(0.65, 0.72, 0.80), COL_PARCHMENT, 0, 350)

	# --- Mountain backdrop ---
	draw_mountain_silhouette(canvas, -50.0, 280.0, 1380.0, 180.0,
		Color(COL_INK_FAINT, 0.40), 6)
	draw_mountain_silhouette(canvas, 100.0, 310.0, 1100.0, 150.0,
		Color(COL_INK_LIGHT, 0.50), 5)

	# Mist between mountains and harbor
	draw_ink_cloud(canvas, Vector2(640, 330), Vector2(1300, 40), 0.20)

	# --- Traditional Chinese architecture silhouettes ---
	_draw_pagoda(canvas, Vector2(180, 270), 80.0, 140.0, Color(COL_INK_MED, 0.6))
	_draw_pagoda(canvas, Vector2(350, 290), 60.0, 100.0, Color(COL_INK_MED, 0.5))
	_draw_curved_roof(canvas, Vector2(500, 320), 120.0, 35.0, Color(COL_INK_DARK, 0.55))
	_draw_curved_roof(canvas, Vector2(750, 310), 100.0, 30.0, Color(COL_INK_MED, 0.50))

	# --- Harbor water ---
	var water_rect := Rect2(0, 450, SCREEN_W, SCREEN_H - 450)
	canvas.draw_rect(water_rect, Color(COL_OCEAN_LIGHT, 0.40))
	for i in range(10):
		var wy: float = 455.0 + i * 25.0
		draw_wave_line(canvas, wy, 4.0, 0.015, Color(COL_OCEAN_MID, 0.20 + i * 0.02), 1.0)

	# --- Dock structures ---
	_draw_dock(canvas, 400.0, 430.0, 200.0, 40.0)
	_draw_dock(canvas, 700.0, 440.0, 180.0, 35.0)
	_draw_dock(canvas, 1000.0, 435.0, 160.0, 38.0)

	# Dock pilings
	for dx in [420.0, 480.0, 540.0, 580.0]:
		canvas.draw_line(Vector2(dx, 430.0), Vector2(dx, 490.0),
			Color(COL_WOOD_BROWN, 0.7), 3.0)
	for dx in [720.0, 770.0, 830.0, 870.0]:
		canvas.draw_line(Vector2(dx, 440.0), Vector2(dx, 500.0),
			Color(COL_WOOD_BROWN, 0.65), 3.0)

	# --- Ships at dock ---
	_draw_ship(canvas, Vector2(460, 400), 1.0)
	_draw_ship(canvas, Vector2(780, 410), 0.8)
	_draw_ship(canvas, Vector2(1050, 405), 0.7)

	# --- Water reflections (semi-transparent mirrored shapes) ---
	_draw_ship_reflection(canvas, Vector2(460, 470), 1.0)
	_draw_ship_reflection(canvas, Vector2(780, 480), 0.8)

	# --- Lanterns ---
	draw_lantern(canvas, Vector2(430, 350), Vector2(14, 20), COL_LANTERN)
	draw_lantern(canvas, Vector2(560, 340), Vector2(12, 18), COL_LANTERN)
	draw_lantern(canvas, Vector2(750, 345), Vector2(13, 19), COL_LANTERN)
	draw_lantern(canvas, Vector2(900, 355), Vector2(11, 16), Color(0.85, 0.45, 0.18))
	draw_lantern(canvas, Vector2(1060, 350), Vector2(12, 17), COL_LANTERN)

	# --- Bamboo clusters at edges ---
	draw_bamboo(canvas, 30, 250, 300, Color(COL_JADE, 0.50))
	draw_bamboo(canvas, 60, 280, 260, Color(COL_JADE_LIGHT, 0.45))
	draw_bamboo(canvas, 1230, 260, 280, Color(COL_JADE, 0.48))
	draw_bamboo(canvas, 1255, 290, 240, Color(COL_JADE_LIGHT, 0.42))


# ===========================================================================
# 5. PUBLIC HELPER FUNCTIONS  辅助绘制
# ===========================================================================

## Draws a mountain range silhouette with the given number of peaks.
## Peaks are generated as a smooth polygon ridge line from base_x to base_x+width.
static func draw_mountain_silhouette(canvas: CanvasItem, base_x: float,
		base_y: float, width: float, height: float, color: Color,
		peaks: int) -> void:
	var poly := PackedVector2Array()
	# Bottom-left anchor
	poly.append(Vector2(base_x, base_y + height * 0.4))

	var segment_w: float = width / float(peaks)
	# Build ridge line
	for i in range(peaks + 1):
		var t: float = float(i) / float(peaks)
		var px: float = base_x + t * width
		# Peak heights vary — taller in the centre, shorter at edges
		var envelope: float = sin(t * PI)  # 0→1→0
		var peak_factor: float = 0.6 + 0.4 * envelope
		# Alternate between peaks and valleys
		var is_peak: bool = (i % 2 == 0)
		var h: float
		if is_peak:
			h = height * peak_factor * (0.7 + fmod(float(i) * 0.37, 0.3))
		else:
			h = height * peak_factor * (0.25 + fmod(float(i) * 0.53, 0.25))
		poly.append(Vector2(px, base_y - h + height * 0.4))

		# Add a midpoint for smoother slopes
		if i < peaks:
			var mid_x: float = px + segment_w * 0.5
			var mid_h: float = height * peak_factor * (0.35 + fmod(float(i) * 0.71, 0.25))
			poly.append(Vector2(mid_x, base_y - mid_h + height * 0.4))

	# Bottom-right anchor
	poly.append(Vector2(base_x + width, base_y + height * 0.4))
	# Close along bottom
	poly.append(Vector2(base_x + width, base_y + height))
	poly.append(Vector2(base_x, base_y + height))

	canvas.draw_polygon(poly, [color])


## Draws a cloud wisp as a cluster of semi-transparent ellipses.
static func draw_ink_cloud(canvas: CanvasItem, center: Vector2,
		size: Vector2, opacity: float) -> void:
	var col := Color(1.0, 1.0, 0.97, opacity)
	# Main ellipse approximated by a wide, flat polygon
	var cloud_poly := PackedVector2Array()
	var steps: int = 24
	for i in range(steps + 1):
		var angle: float = float(i) / float(steps) * TAU
		var px: float = center.x + cos(angle) * size.x * 0.5
		var py: float = center.y + sin(angle) * size.y * 0.5
		cloud_poly.append(Vector2(px, py))
	if cloud_poly.size() >= 3:
		canvas.draw_polygon(cloud_poly, [col])

	# Smaller satellite puffs
	var puff_offsets := [
		Vector2(-size.x * 0.3, -size.y * 0.15),
		Vector2(size.x * 0.3, -size.y * 0.1),
		Vector2(-size.x * 0.15, size.y * 0.2),
		Vector2(size.x * 0.2, size.y * 0.15),
	]
	for offset in puff_offsets:
		var pc := center + offset
		var pr := size * 0.3
		var puff := PackedVector2Array()
		for i in range(steps + 1):
			var angle: float = float(i) / float(steps) * TAU
			puff.append(Vector2(pc.x + cos(angle) * pr.x, pc.y + sin(angle) * pr.y))
		if puff.size() >= 3:
			canvas.draw_polygon(puff, [Color(1.0, 1.0, 0.97, opacity * 0.6)])


## Draws a sine-wave line across the full screen width.
static func draw_wave_line(canvas: CanvasItem, y_pos: float,
		amplitude: float, frequency: float, color: Color,
		width_val: float) -> void:
	var prev := Vector2(0, y_pos)
	var step: float = 4.0  # pixel step for smoothness
	var x: float = step
	while x <= SCREEN_W:
		var y: float = y_pos + sin(x * frequency * TAU) * amplitude
		canvas.draw_line(prev, Vector2(x, y), color, width_val)
		prev = Vector2(x, y)
		x += step


## Draws a simple bamboo stalk with segmented stem and leaves.
static func draw_bamboo(canvas: CanvasItem, x: float, y: float,
		height: float, color: Color) -> void:
	var stem_top: float = y - height
	# Stem
	canvas.draw_line(Vector2(x, y), Vector2(x, stem_top), color, 3.0)

	# Nodes (horizontal marks)
	var node_count: int = int(height / 40.0)
	for i in range(1, node_count + 1):
		var ny: float = y - float(i) * 40.0
		if ny < stem_top:
			break
		canvas.draw_line(Vector2(x - 4, ny), Vector2(x + 4, ny), color, 2.0)

		# Leaves at each node
		_draw_bamboo_leaf(canvas, Vector2(x, ny), 1, color)
		if i % 2 == 0:
			_draw_bamboo_leaf(canvas, Vector2(x, ny), -1, color)

	# Top leaves
	_draw_bamboo_leaf(canvas, Vector2(x, stem_top), 1, color)
	_draw_bamboo_leaf(canvas, Vector2(x, stem_top), -1, color)
	_draw_bamboo_leaf(canvas, Vector2(x, stem_top - 5), 1, Color(color, color.a * 0.8))


## Draws a Chinese red seal stamp (方印) — a square vermilion mark
## with an inner border, evoking traditional artist seals.
static func draw_chinese_seal(canvas: CanvasItem, position: Vector2,
		size: Vector2) -> void:
	var rect := Rect2(position, size)
	# Outer red fill
	canvas.draw_rect(rect, COL_SEAL_RED)
	# Inner border (slightly inset white/cream line)
	var inset: float = 4.0
	var inner := Rect2(position.x + inset, position.y + inset,
		size.x - inset * 2, size.y - inset * 2)
	canvas.draw_rect(inner, Color(COL_SEAL_RED, 0.9), false, 2.0)

	# Decorative cross/character strokes inside (abstract 印 glyph)
	var cx: float = position.x + size.x * 0.5
	var cy: float = position.y + size.y * 0.5
	var hw: float = size.x * 0.28
	var hh: float = size.y * 0.28
	var stroke_col := Color(0.95, 0.85, 0.80, 0.9)
	# Vertical stroke
	canvas.draw_line(Vector2(cx, cy - hh), Vector2(cx, cy + hh), stroke_col, 2.0)
	# Horizontal stroke
	canvas.draw_line(Vector2(cx - hw, cy), Vector2(cx + hw, cy), stroke_col, 2.0)
	# Top-left to center diagonal
	canvas.draw_line(Vector2(cx - hw * 0.8, cy - hh * 0.8),
		Vector2(cx, cy), Color(stroke_col, 0.7), 1.5)
	# Bottom-right accent
	canvas.draw_line(Vector2(cx, cy),
		Vector2(cx + hw * 0.8, cy + hh * 0.8), Color(stroke_col, 0.7), 1.5)
	# Small square in upper-right quadrant
	var sq_size: float = size.x * 0.15
	canvas.draw_rect(Rect2(cx + 2, cy - hh + 2, sq_size, sq_size),
		Color(stroke_col, 0.6), false, 1.5)


## Draws a traditional scroll-style double-line border.
static func draw_scroll_border(canvas: CanvasItem, rect: Rect2,
		color: Color) -> void:
	# Outer border
	canvas.draw_rect(rect, color, false, 2.5)
	# Inner border (inset by 8 pixels)
	var inset: float = 8.0
	var inner := Rect2(rect.position.x + inset, rect.position.y + inset,
		rect.size.x - inset * 2, rect.size.y - inset * 2)
	canvas.draw_rect(inner, Color(color, color.a * 0.6), false, 1.5)

	# Corner ornaments — small squares at each corner of inner rect
	var cs: float = 6.0
	var corners := [
		inner.position,
		Vector2(inner.position.x + inner.size.x - cs, inner.position.y),
		Vector2(inner.position.x, inner.position.y + inner.size.y - cs),
		Vector2(inner.position.x + inner.size.x - cs, inner.position.y + inner.size.y - cs),
	]
	for c in corners:
		canvas.draw_rect(Rect2(c, Vector2(cs, cs)), Color(color, color.a * 0.5))


## Draws a Chinese lantern — a glowing oval with a cap and tassel.
static func draw_lantern(canvas: CanvasItem, position: Vector2,
		size: Vector2, color: Color) -> void:
	# Glow behind
	canvas.draw_circle(position, maxf(size.x, size.y) * 1.2,
		Color(color.r, color.g, color.b, 0.15))

	# Lantern body (ellipse via polygon)
	var body := PackedVector2Array()
	var steps: int = 20
	for i in range(steps + 1):
		var angle: float = float(i) / float(steps) * TAU
		body.append(Vector2(
			position.x + cos(angle) * size.x * 0.5,
			position.y + sin(angle) * size.y * 0.5))
	if body.size() >= 3:
		canvas.draw_polygon(body, [color])

	# Top cap
	var cap_w: float = size.x * 0.4
	var cap_h: float = size.y * 0.15
	canvas.draw_rect(Rect2(position.x - cap_w * 0.5, position.y - size.y * 0.5 - cap_h,
		cap_w, cap_h), COL_INK_DARK)

	# Hanging cord above
	canvas.draw_line(Vector2(position.x, position.y - size.y * 0.5 - cap_h),
		Vector2(position.x, position.y - size.y * 0.5 - cap_h - 15),
		COL_INK_DARK, 1.0)

	# Tassel below
	var tassel_top := Vector2(position.x, position.y + size.y * 0.5)
	canvas.draw_line(tassel_top, tassel_top + Vector2(0, 10),
		Color(color, 0.8), 1.5)
	canvas.draw_line(tassel_top + Vector2(0, 10), tassel_top + Vector2(-3, 16),
		Color(color, 0.6), 1.0)
	canvas.draw_line(tassel_top + Vector2(0, 10), tassel_top + Vector2(3, 16),
		Color(color, 0.6), 1.0)

	# Horizontal ribs on lantern body
	for ri in [-0.25, 0.0, 0.25]:
		var ry: float = position.y + ri * size.y
		var rx_half: float = cos(asin(ri * 2.0)) * size.x * 0.5 if absf(ri * 2.0) <= 1.0 else size.x * 0.3
		canvas.draw_line(Vector2(position.x - rx_half, ry),
			Vector2(position.x + rx_half, ry),
			Color(COL_INK_DARK, 0.3), 0.8)


# ===========================================================================
# PRIVATE HELPERS  内部辅助
# ===========================================================================

## Faint horizontal lines to suggest handmade paper grain.
static func _draw_paper_texture(canvas: CanvasItem) -> void:
	var col := Color(COL_INK_FAINT, 0.08)
	var y: float = 10.0
	var idx: int = 0
	while y < SCREEN_H:
		var x_start: float = fmod(float(idx) * 73.0, 80.0)
		var x_end: float = SCREEN_W - fmod(float(idx) * 51.0, 100.0)
		canvas.draw_line(Vector2(x_start, y), Vector2(x_end, y), col, 0.5)
		y += 12.0 + fmod(float(idx) * 17.0, 8.0)
		idx += 1


## Vertical gradient fill (sky).
static func _draw_sky_gradient(canvas: CanvasItem, top_col: Color,
		bot_col: Color, y_start: float, y_end: float) -> void:
	var bands: int = 30
	var band_h: float = (y_end - y_start) / float(bands)
	for i in range(bands):
		var t: float = float(i) / float(bands)
		var col: Color = top_col.lerp(bot_col, t)
		canvas.draw_rect(Rect2(0, y_start + i * band_h, SCREEN_W, band_h + 1), col)


## Draw a single bamboo leaf (direction: 1=right, -1=left).
static func _draw_bamboo_leaf(canvas: CanvasItem, base: Vector2,
		direction: int, color: Color) -> void:
	var tip := base + Vector2(direction * 25, -15)
	var side := base + Vector2(direction * 8, -3)
	var leaf := PackedVector2Array([base, tip, side])
	canvas.draw_polygon(leaf, [Color(color, color.a * 0.7)])


## Scatter decorative ink dots across the canvas.
static func _draw_ink_splatters(canvas: CanvasItem) -> void:
	# Deterministic pseudo-random positions
	var positions := [
		Vector2(120, 500), Vector2(310, 560), Vector2(480, 530),
		Vector2(650, 580), Vector2(790, 510), Vector2(940, 550),
		Vector2(1100, 520), Vector2(200, 620), Vector2(500, 640),
		Vector2(750, 610), Vector2(1000, 630), Vector2(350, 200),
		Vector2(900, 250), Vector2(1050, 180), Vector2(150, 180),
	]
	for i in range(positions.size()):
		var r: float = 1.5 + fmod(float(i) * 3.7, 3.0)
		var alpha: float = 0.06 + fmod(float(i) * 2.3, 0.08)
		canvas.draw_circle(positions[i], r, Color(COL_INK_MED, alpha))


## Draw the deep ocean body for combat scene.
static func _draw_ocean_body(canvas: CanvasItem, start_y: float) -> void:
	# Build a polygon from start_y (with wave top) to bottom of screen.
	var poly := PackedVector2Array()
	var steps: int = 80
	for i in range(steps + 1):
		var x: float = float(i) / float(steps) * SCREEN_W
		var y: float = start_y + sin(x * 0.01 * TAU) * 12.0 + sin(x * 0.023 * TAU) * 6.0
		poly.append(Vector2(x, y))
	poly.append(Vector2(SCREEN_W, SCREEN_H))
	poly.append(Vector2(0, SCREEN_H))
	canvas.draw_polygon(poly, [Color(COL_OCEAN_DEEP, 0.85)])

	# Lighter band near the surface
	var surface := PackedVector2Array()
	for i in range(steps + 1):
		var x: float = float(i) / float(steps) * SCREEN_W
		var y: float = start_y + sin(x * 0.01 * TAU) * 12.0 + sin(x * 0.023 * TAU) * 6.0
		surface.append(Vector2(x, y))
	for i in range(steps, -1, -1):
		var x: float = float(i) / float(steps) * SCREEN_W
		var y: float = start_y + 40.0 + sin(x * 0.012 * TAU) * 8.0
		surface.append(Vector2(x, y))
	if surface.size() >= 3:
		canvas.draw_polygon(surface, [Color(COL_OCEAN_MID, 0.35)])


## Ship deck planks drawn as horizontal wood-toned lines.
static func _draw_ship_deck(canvas: CanvasItem, start_y: float) -> void:
	# Deck background
	canvas.draw_rect(Rect2(0, start_y, SCREEN_W, SCREEN_H - start_y),
		Color(COL_WOOD_BROWN, 0.90))

	# Plank lines
	var plank_y: float = start_y + 5.0
	var idx: int = 0
	while plank_y < SCREEN_H:
		var col: Color = COL_WOOD_LIGHT if idx % 2 == 0 else COL_WOOD_BROWN
		canvas.draw_line(Vector2(0, plank_y), Vector2(SCREEN_W, plank_y),
			Color(col, 0.6), 1.0)
		# Plank gap (dark line)
		canvas.draw_line(Vector2(0, plank_y + 1), Vector2(SCREEN_W, plank_y + 1),
			Color(COL_INK_DARK, 0.25), 0.5)
		plank_y += 16.0
		idx += 1

	# Vertical plank seams
	var seam_x: float = 50.0
	while seam_x < SCREEN_W:
		var seam_start_y: float = start_y + fmod(seam_x * 1.7, 20.0)
		canvas.draw_line(Vector2(seam_x, seam_start_y),
			Vector2(seam_x, seam_start_y + 50.0 + fmod(seam_x, 30.0)),
			Color(COL_INK_DARK, 0.15), 0.5)
		seam_x += 80.0 + fmod(seam_x * 0.3, 40.0)

	# Deck edge highlight
	canvas.draw_line(Vector2(0, start_y), Vector2(SCREEN_W, start_y),
		Color(COL_INK_DARK, 0.5), 2.5)


## Spray particles clustered near a point.
static func _draw_spray_cluster(canvas: CanvasItem, center: Vector2,
		count: int) -> void:
	for i in range(count):
		var angle: float = float(i) / float(count) * TAU + float(i) * 0.7
		var dist: float = 10.0 + fmod(float(i) * 13.3, 25.0)
		var pos := center + Vector2(cos(angle) * dist, sin(angle) * dist * 0.5)
		var r: float = 1.5 + fmod(float(i) * 3.1, 3.5)
		canvas.draw_circle(pos, r, COL_SPRAY)


## Vignette effect for the map — darker edges.
static func _draw_vignette(canvas: CanvasItem) -> void:
	var edge_col := Color(COL_INK_MED.r, COL_INK_MED.g, COL_INK_MED.b, 0.0)
	# We approximate vignette with semi-transparent rectangles along edges.
	var depth: int = 15
	for i in range(depth):
		var alpha: float = 0.04 * (1.0 - float(i) / float(depth))
		var col := Color(0.3, 0.28, 0.22, alpha)
		var inset: float = float(i) * 6.0
		canvas.draw_rect(
			Rect2(inset, inset, SCREEN_W - inset * 2, SCREEN_H - inset * 2),
			col, false, 6.0)


## Draw a compass rose at the given center and radius.
static func _draw_compass_rose(canvas: CanvasItem, center: Vector2,
		radius: float) -> void:
	var col := Color(COL_INK_MED, 0.7)
	var col_light := Color(COL_INK_LIGHT, 0.5)

	# Outer circle
	canvas.draw_arc(center, radius, 0, TAU, 48, col, 1.5)
	# Inner circle
	canvas.draw_arc(center, radius * 0.75, 0, TAU, 36, col_light, 1.0)
	# Innermost circle
	canvas.draw_arc(center, radius * 0.12, 0, TAU, 16, col, 1.5)

	# Cardinal direction lines (N, S, E, W)
	var directions := [
		Vector2(0, -1),   # N
		Vector2(0, 1),    # S
		Vector2(1, 0),    # E
		Vector2(-1, 0),   # W
	]
	for dir in directions:
		canvas.draw_line(center + dir * radius * 0.15,
			center + dir * radius * 0.95, col, 1.5)

	# Intercardinal lines (NE, NW, SE, SW) — shorter
	var diag := 0.707  # ~ cos(45°)
	var intercard := [
		Vector2(diag, -diag), Vector2(-diag, -diag),
		Vector2(diag, diag), Vector2(-diag, diag),
	]
	for dir in intercard:
		canvas.draw_line(center + dir * radius * 0.2,
			center + dir * radius * 0.7, col_light, 1.0)

	# North pointer — small filled triangle
	var n_tip := center + Vector2(0, -radius)
	var n_left := center + Vector2(-5, -radius * 0.75)
	var n_right := center + Vector2(5, -radius * 0.75)
	canvas.draw_polygon(PackedVector2Array([n_tip, n_left, n_right]),
		[Color(COL_SEAL_RED, 0.6)])

	# Tick marks around the outer circle
	for i in range(16):
		var angle: float = float(i) / 16.0 * TAU
		var outer := center + Vector2(cos(angle), sin(angle)) * radius
		var inner := center + Vector2(cos(angle), sin(angle)) * radius * 0.88
		canvas.draw_line(inner, outer, col_light, 0.8)


## Draw a dotted route line through a series of points.
static func _draw_dotted_route(canvas: CanvasItem, points: Array,
		color: Color) -> void:
	for i in range(points.size() - 1):
		var from: Vector2 = points[i]
		var to: Vector2 = points[i + 1]
		var dist: float = from.distance_to(to)
		var dir: Vector2 = (to - from).normalized()
		var dot_spacing: float = 8.0
		var d: float = 0.0
		var dot_idx: int = 0
		while d < dist:
			if dot_idx % 2 == 0:
				var p: Vector2 = from + dir * d
				canvas.draw_circle(p, 1.8, color)
			d += dot_spacing
			dot_idx += 1

	# Small circles at waypoints
	for pt in points:
		canvas.draw_circle(pt, 3.5, Color(color, color.a * 0.8))
		canvas.draw_arc(pt, 3.5, 0, TAU, 12, color, 1.0)


## Small wave glyph used on the map.
static func _draw_tiny_wave(canvas: CanvasItem, pos: Vector2,
		width: float, color: Color) -> void:
	var half_w: float = width * 0.5
	var prev := Vector2(pos.x - half_w, pos.y)
	var step: float = 2.0
	var x: float = -half_w + step
	while x <= half_w:
		var y: float = pos.y + sin(x / half_w * PI * 2.0) * 3.0
		var cur := Vector2(pos.x + x, y)
		canvas.draw_line(prev, cur, color, 0.8)
		prev = cur
		x += step


## Draw a small land mass blob on the map.
static func _draw_land_blob(canvas: CanvasItem, center: Vector2,
		radius: float, color: Color) -> void:
	var poly := PackedVector2Array()
	var steps: int = 16
	for i in range(steps):
		var angle: float = float(i) / float(steps) * TAU
		var r: float = radius * (0.7 + fmod(float(i) * 0.47, 0.35))
		poly.append(center + Vector2(cos(angle), sin(angle)) * r)
	canvas.draw_polygon(poly, [Color(color, 0.5)])
	# Coastline
	var outline := PackedVector2Array(poly)
	outline.append(poly[0])  # close the loop
	canvas.draw_polyline(outline, Color(COL_INK_MED, 0.4), 1.0)


## Draw dock structure (pier rectangle).
static func _draw_dock(canvas: CanvasItem, x: float, y: float,
		width: float, height: float) -> void:
	# Main deck surface
	canvas.draw_rect(Rect2(x, y, width, height), Color(COL_WOOD_BROWN, 0.80))
	# Plank lines across
	var px: float = x + 5.0
	while px < x + width:
		canvas.draw_line(Vector2(px, y), Vector2(px, y + height),
			Color(COL_INK_DARK, 0.15), 0.5)
		px += 12.0
	# Top edge highlight
	canvas.draw_line(Vector2(x, y), Vector2(x + width, y),
		Color(COL_WOOD_LIGHT, 0.6), 1.5)
	# Bottom shadow
	canvas.draw_line(Vector2(x, y + height), Vector2(x + width, y + height),
		Color(COL_INK_DARK, 0.3), 1.0)


## Draw a simplified Chinese junk ship.
static func _draw_ship(canvas: CanvasItem, pos: Vector2,
		scale_factor: float) -> void:
	var sf: float = scale_factor
	# Hull
	var hull := PackedVector2Array([
		pos + Vector2(-50 * sf, 0),
		pos + Vector2(-60 * sf, 15 * sf),
		pos + Vector2(-45 * sf, 28 * sf),
		pos + Vector2(45 * sf, 28 * sf),
		pos + Vector2(60 * sf, 15 * sf),
		pos + Vector2(50 * sf, 0),
	])
	canvas.draw_polygon(hull, [Color(COL_WOOD_BROWN, 0.85)])
	# Hull outline
	var hull_outline := PackedVector2Array(hull)
	hull_outline.append(hull[0])
	canvas.draw_polyline(hull_outline, Color(COL_INK_DARK, 0.5), 1.5)

	# Mast
	var mast_base := pos + Vector2(0, 0)
	var mast_top := pos + Vector2(0, -80 * sf)
	canvas.draw_line(mast_base, mast_top, Color(COL_INK_DARK, 0.7), 2.0)

	# Sail (rectangular junk sail with battens)
	var sail := PackedVector2Array([
		pos + Vector2(-5 * sf, -75 * sf),
		pos + Vector2(35 * sf, -65 * sf),
		pos + Vector2(38 * sf, -15 * sf),
		pos + Vector2(-3 * sf, -10 * sf),
	])
	canvas.draw_polygon(sail, [Color(COL_PARCHMENT, 0.75)])
	# Sail outline
	var sail_outline := PackedVector2Array(sail)
	sail_outline.append(sail[0])
	canvas.draw_polyline(sail_outline, Color(COL_INK_MED, 0.5), 1.0)

	# Battens (horizontal lines on sail)
	for i in range(1, 5):
		var t: float = float(i) / 5.0
		var left: Vector2 = sail[0].lerp(sail[3], t)
		var right: Vector2 = sail[1].lerp(sail[2], t)
		canvas.draw_line(left, right, Color(COL_INK_MED, 0.3), 0.8)

	# Second smaller sail
	var sail2 := PackedVector2Array([
		pos + Vector2(-30 * sf, -50 * sf),
		pos + Vector2(-8 * sf, -48 * sf),
		pos + Vector2(-6 * sf, -10 * sf),
		pos + Vector2(-28 * sf, -12 * sf),
	])
	canvas.draw_polygon(sail2, [Color(COL_PARCHMENT, 0.60)])
	var sail2_outline := PackedVector2Array(sail2)
	sail2_outline.append(sail2[0])
	canvas.draw_polyline(sail2_outline, Color(COL_INK_MED, 0.4), 0.8)


## Draw a semi-transparent reflection of a ship in water.
static func _draw_ship_reflection(canvas: CanvasItem, pos: Vector2,
		scale_factor: float) -> void:
	var sf: float = scale_factor
	# Mirrored hull shape (flipped vertically, semi-transparent)
	var refl := PackedVector2Array([
		pos + Vector2(-50 * sf, 0),
		pos + Vector2(-55 * sf, -12 * sf),
		pos + Vector2(-40 * sf, -22 * sf),
		pos + Vector2(40 * sf, -22 * sf),
		pos + Vector2(55 * sf, -12 * sf),
		pos + Vector2(50 * sf, 0),
	])
	canvas.draw_polygon(refl, [Color(COL_WOOD_BROWN, 0.15)])

	# Mast reflection
	canvas.draw_line(pos, pos + Vector2(0, 50 * sf),
		Color(COL_INK_DARK, 0.10), 1.5)

	# Sail reflection (faint)
	var sail_refl := PackedVector2Array([
		pos + Vector2(-5 * sf, 5 * sf),
		pos + Vector2(30 * sf, 10 * sf),
		pos + Vector2(32 * sf, 45 * sf),
		pos + Vector2(-3 * sf, 40 * sf),
	])
	canvas.draw_polygon(sail_refl, [Color(COL_PARCHMENT, 0.08)])


## Draw a simple pagoda silhouette.
static func _draw_pagoda(canvas: CanvasItem, base_pos: Vector2,
		width: float, height: float, color: Color) -> void:
	var floors: int = 4
	var floor_h: float = height / float(floors)
	for i in range(floors):
		var fy: float = base_pos.y - float(i) * floor_h
		# Each floor narrows
		var t: float = float(i) / float(floors)
		var fw: float = width * (1.0 - t * 0.6)
		var cx: float = base_pos.x

		# Floor body
		canvas.draw_rect(
			Rect2(cx - fw * 0.4, fy - floor_h + 5, fw * 0.8, floor_h - 5),
			Color(color, color.a * (0.9 - t * 0.15)))

		# Curved roof overhang
		_draw_curved_roof_line(canvas, Vector2(cx, fy - floor_h + 3),
			fw, 8.0, color)

	# Spire on top
	var top_y: float = base_pos.y - height
	canvas.draw_line(Vector2(base_pos.x, top_y),
		Vector2(base_pos.x, top_y - 20),
		Color(color, color.a * 0.8), 2.0)
	canvas.draw_circle(Vector2(base_pos.x, top_y - 22), 3.0,
		Color(color, color.a * 0.6))


## Draw a curved traditional Chinese roofline.
static func draw_curved_roof(canvas: CanvasItem, center: Vector2,
		width: float, curve_height: float, color: Color) -> void:
	_draw_curved_roof(canvas, center, width, curve_height, color)


static func _draw_curved_roof(canvas: CanvasItem, center: Vector2,
		width: float, curve_height: float, color: Color) -> void:
	# Roof body
	var body := PackedVector2Array()
	body.append(Vector2(center.x - width * 0.4, center.y))
	body.append(Vector2(center.x + width * 0.4, center.y))
	body.append(Vector2(center.x + width * 0.45, center.y + curve_height * 0.3))
	body.append(Vector2(center.x - width * 0.45, center.y + curve_height * 0.3))
	canvas.draw_polygon(body, [Color(color, color.a * 0.7)])

	# Curved roof line on top
	_draw_curved_roof_line(canvas, center, width, curve_height, color)

	# Walls below
	canvas.draw_rect(
		Rect2(center.x - width * 0.35, center.y + curve_height * 0.3,
			width * 0.7, curve_height * 1.5),
		Color(color, color.a * 0.5))


## Draw just the curved roof line (shared by pagoda and standalone roofs).
static func _draw_curved_roof_line(canvas: CanvasItem, center: Vector2,
		width: float, curve_h: float, color: Color) -> void:
	var points := PackedVector2Array()
	var steps: int = 20
	for i in range(steps + 1):
		var t: float = float(i) / float(steps)
		var x: float = center.x + (t - 0.5) * width
		# Curve: dips in center, rises at edges (like a Chinese roof)
		var normalized_t: float = (t - 0.5) * 2.0  # -1 to 1
		var curve: float = curve_h * (normalized_t * normalized_t - 0.3)
		# Tips flare upward
		var flare: float = 0.0
		if absf(normalized_t) > 0.8:
			flare = -curve_h * 0.4 * ((absf(normalized_t) - 0.8) / 0.2)
		points.append(Vector2(x, center.y - curve + flare))
	canvas.draw_polyline(points, color, 2.0)
