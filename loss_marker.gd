extends Control

var marker_pos := Vector2.ZERO

func _draw():
	draw_circle(marker_pos, 4.0, Color(1, 0, 0)) # red dot

func update_marker(new_pos: Vector2):
	marker_pos = new_pos
	queue_redraw()
