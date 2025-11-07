extends Control

@onready var graph: Graph2D = $VBoxContainer/HBoxContainer/MarginContainer/Graph2D

var time := 0.0
var point_timer := 0.0

# Dynamic function parameters
var m1 := 0.5
var b1 := 2.0
var m2 := -1.0
var b2 := 0.0

func _ready():
	randomize()
	graph.add_function(func(x): return m1 * x + b1)
	graph.add_function(func(x): return m2 * x + b2)
	graph.add_point(Vector2(2, 3))
	graph.add_point(Vector2(-4, -1))

func _process(delta):
	time += delta
	point_timer += delta

	# Update function parameters slowly
	m1 = 0.5 + 0.3 * sin(time)
	b1 = 2.0 + 0.5 * cos(time * 0.8)
	m2 = -1.0 + 0.4 * sin(time * 0.5)
	b2 = 0.5 * cos(time * 1.1)

	# Update the existing functions
	graph.functions[0] = func(x): return m1 * x + b1
	graph.functions[1] = func(x): return m2 * x + b2
	graph.queue_redraw()

	# Occasionally add random points
	if point_timer > 0.5:
		point_timer = 0.0
		var rand_x = randf_range(graph.x_range.x, graph.x_range.y)
		var rand_y = randf_range(graph.y_range.x, graph.y_range.y)
		graph.add_point(Vector2(rand_x, rand_y))
		
		# Limit total number of points (for performance)
		if graph.points.size() > 100:
			graph.points.pop_front()
