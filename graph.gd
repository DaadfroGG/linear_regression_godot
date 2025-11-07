extends Control
class_name Graph2D

@export var x_range: Vector2 = Vector2(-10, 10)
@export var y_range: Vector2 = Vector2(-10, 10)
@export var grid_color: Color = Color(0.3, 0.3, 0.3, 0.5)
@export var axis_color: Color = Color(1, 1, 1)
@export var line_color: Color = Color(0.2, 0.8, 0.2)
@export var point_color: Color = Color(1, 0.2, 0.2)
@export var line_thickness: float = 2.0
@export var point_radius: float = 3.0

var functions: Array[Callable] = []
var points: Array[Vector2] = []

func _ready():
	queue_redraw()

func _draw():
	_draw_grid()
	_draw_axes()
	_draw_functions()
	_draw_points()

func _draw_grid():
	var step_x = (x_range.y - x_range.x) / 10.0
	var step_y = (y_range.y - y_range.x) / 10.0
	for i in range(11):
		var gx = x_range.x + i * step_x
		var gy = y_range.x + i * step_y
		draw_line(_to_screen(Vector2(gx, y_range.x)), _to_screen(Vector2(gx, y_range.y)), grid_color)
		draw_line(_to_screen(Vector2(x_range.x, gy)), _to_screen(Vector2(x_range.y, gy)), grid_color)

func _draw_axes():
	var zero_x = clamp(0.0, x_range.x, x_range.y)
	var zero_y = clamp(0.0, y_range.x, y_range.y)
	draw_line(_to_screen(Vector2(zero_x, y_range.x)), _to_screen(Vector2(zero_x, y_range.y)), axis_color, 2)
	draw_line(_to_screen(Vector2(x_range.x, zero_y)), _to_screen(Vector2(x_range.y, zero_y)), axis_color, 2)

func _draw_functions():
	for f in functions:
		var prev: Vector2
		var steps = size.x
		for i in range(steps):
			var x_val = lerp(x_range.x, x_range.y, i / float(steps))
			var y_val = f.call(x_val)
			var screen_pos = _to_screen(Vector2(x_val, y_val))
			if i > 0:
				draw_line(prev, screen_pos, line_color, line_thickness)
			prev = screen_pos

func _draw_points():
	for p in points:
		draw_circle(_to_screen(p), point_radius, point_color)

func _to_screen(world_pos: Vector2) -> Vector2:
	var rel_x = (world_pos.x - x_range.x) / (x_range.y - x_range.x)
	var rel_y = (world_pos.y - y_range.x) / (y_range.y - y_range.x)
	return Vector2(rel_x * size.x, (1.0 - rel_y) * size.y)

# Public API
func add_function(f: Callable):
	functions.append(f)
	queue_redraw()

func add_point(p: Vector2):
	points.append(p)
	queue_redraw()

func clear_all():
	functions.clear()
	points.clear()
	queue_redraw()
