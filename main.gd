extends Control

@onready var graph: Graph2D = $VBoxContainer/HBoxContainer/MarginContainer/Graph2D
@export var learning_rate := 0.01
@onready var data_ui: Data_UI = $VBoxContainer/HBoxContainer/MarginContainer2/Data
const data = preload("res://data.csv")

var time := 0.0
var point_timer := 0.0

# Dynamic function parameters (in normalized space)
var m1 := 0.5
var b1 := 0.5

# Normalization factors
var max_km := 1.0
var max_price := 1.0

func _ready():
	if data.records.size() > 0:
		var min_km = INF
		var max_km_local = -INF
		var min_price = INF
		var max_price_local = -INF
		
		# Find data bounds
		for record in data.records:
			var km = float(record["km"])
			var price = float(record["price"])
			min_km = min(min_km, km)
			max_km_local = max(max_km_local, km)
			min_price = min(min_price, price)
			max_price_local = max(max_price_local, price)

		max_km = max_km_local
		max_price = max_price_local

		# --- Normalize data for training ---
		for record in data.records:
			record["km_n"] = float(record["km"]) / max_km
			record["price_n"] = float(record["price"]) / max_price

			# Add *de-normalized* points for display
			graph.add_point(Vector2(float(record["km"]), float(record["price"])))

		# Add a margin for display ranges
		var x_margin = (max_km_local - min_km) * 0.1
		var y_margin = (max_price_local - min_price) * 0.1
		graph.x_range = Vector2(min_km - x_margin, max_km_local + x_margin)
		graph.y_range = Vector2(min_price - y_margin, max_price_local + y_margin)

	# Add the initial regression line
	graph.add_function(func(x): return (m1 * (x / max_km) + b1) * max_price)
func _process(delta):
	time += delta
	point_timer += delta

	# --- Gradient descent on normalized data ---
	var grad_m := 0.0
	var grad_b := 0.0
	var loss := 0.0
	var n := float(data.records.size())

	for record in data.records:
		var x = record["km_n"]
		var y = record["price_n"]
		var y_pred = m1 * x + b1
		var error = y_pred - y
		grad_m += error * x
		grad_b += error
		loss += error * error  # accumulate squared error

	# Compute averages
	grad_m *= (2.0 / n)
	grad_b *= (2.0 / n)
	loss /= n  # mean squared error

	# Gradient descent update
	m1 -= learning_rate * grad_m
	b1 -= learning_rate * grad_b

	# --- De-normalized display values for printing ---
	var m_real := (m1 * max_price) / max_km
	var b_real := b1 * max_price
	data_ui.update_data(m_real, b_real, loss)

	graph.functions[0] = func(x): return (m1 * (x / max_km) + b1) * max_price
	graph.queue_redraw()
