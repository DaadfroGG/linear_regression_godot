extends Control

var marker_pos: Vector2 = Vector2.ZERO
var m_value: float = 0.0
var b_value: float = 0.0

# Customizable offsets (in pixels)
@export var m_label_offset := Vector2(0, -12)   # move label slightly above the bottom
@export var b_label_offset := Vector2(10, 0)    # move label right of the y-axis

func update_guides(pos: Vector2, m: float = 0.0, b: float = 0.0) -> void:
	marker_pos = pos
	m_value = m
	b_value = b
	queue_redraw()

func _draw() -> void:
	if marker_pos == Vector2.ZERO:
		return

	var color := Color(1, 1, 1, 1)
	var step := 6.0  # gap between dots
	var font := get_theme_default_font()
	var font_size := get_theme_default_font_size()

	# --- Dotted lines ---
	for y in range(0, size.y, step * 2):
		draw_line(Vector2(marker_pos.x, y), Vector2(marker_pos.x, y + step), color, 1.0)

	for x in range(0, size.x, step * 2):
		draw_line(Vector2(x, marker_pos.y), Vector2(x + step, marker_pos.y), color, 1.0)

	# --- Text labels ---
	var m_text := "θ₁ = %.3f" % m_value
	var b_text := "θ₀ = %.3f" % b_value

	# 'm' label near bottom axis (centered under marker line)
	var m_text_size := font.get_string_size(m_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var m_text_pos := Vector2(
		marker_pos.x - m_text_size.x / 2 + m_label_offset.x,
		size.y - 6 + m_label_offset.y
	)

	draw_string(
		font,
		m_text_pos,
		m_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		color
	)


	draw_string(
		font,
		Vector2(
		b_label_offset.x,
		marker_pos.y + float(font_size) / 2 + b_label_offset.y),
		b_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		color
	)
