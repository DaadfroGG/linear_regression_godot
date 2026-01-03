extends Control


@onready var loss_map: TextureRect = $VBoxContainer/HBoxContainer/MarginContainer2/Data/HBoxContainer/MarginContainer5/LossMap
@onready var loss_marker: Control = $VBoxContainer/HBoxContainer/MarginContainer2/Data/HBoxContainer/MarginContainer5/LossMap/LossMarker
@onready var loss_guides: Control = $VBoxContainer/HBoxContainer/MarginContainer2/Data/HBoxContainer/MarginContainer5/LossMap/LossGuides
@onready var margin_container_5: MarginContainer = $VBoxContainer/HBoxContainer/MarginContainer2/Data/HBoxContainer/MarginContainer5

@onready var graph: Graph2D = $VBoxContainer/HBoxContainer/MarginContainer/Graph2D
@onready var learning_rate_label: Label = $VBoxContainer/HBoxContainer/MarginContainer2/Data/HBoxContainer/MarginContainer6/Label
@export var learning_rate := 0.01

const data = preload("res://data.csv")

var time := 0.0
var point_timer := 0.0

# Dynamic function parameters (normalized space)
var m1 := 0.5
var b1 := 0.5

# Normalization factors
var max_km := 1.0
var max_price := 1.0

# --- Centralized loss landscape ranges ---
var m_range := Vector2(-2.5, 1.5)  # (min, max)
var b_range := Vector2(-0.5, 2.5)  # (min, max)

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
	_generate_loss_landscape()
	
	#Initialize learning rate label
	learning_rate_label.text = "learning rate : " + str(learning_rate)

func _process(_delta):

	# --- Gradient descent on normalized data ---
	var grad_m := 0.0
	var grad_b := 0.0
	var n := float(data.records.size())

	for record in data.records:
		var x = record["km_n"]
		var y = record["price_n"]
		var y_pred = m1 * x + b1
		var error = y_pred - y
		grad_m += error * x
		grad_b += error

	# Compute averages
	grad_m *= (2.0 / n)
	grad_b *= (2.0 / n)

	# Gradient descent update
	m1 -= learning_rate * grad_m
	b1 -= learning_rate * grad_b

	# --- Update marker position ---
	var tex_size := loss_map.texture.get_size()
	var marker_pos := Vector2(
		(m1 - m_range.x) / (m_range.y - m_range.x) * tex_size.x,
		(1.0 - (b1 - b_range.x) / (b_range.y - b_range.x)) * tex_size.y
	)
	loss_marker.update_marker(marker_pos)

	# --- De-normalized display values ---
	loss_guides.update_guides(marker_pos, m1, b1)

	graph.functions[0] = func(x): return (m1 * (x / max_km) + b1) * max_price

	graph.queue_redraw()

func _generate_loss_landscape():
	var width : int = int(margin_container_5.custom_minimum_size.x)
	var height : int = int(margin_container_5.custom_minimum_size.y)
	var loss_image := Image.create_empty(width, height, false, Image.FORMAT_RGB8)

	for y in height:
		var b_try = lerp(b_range.x, b_range.y, float(y) / height)
		for x in width:
			var m_try = lerp(m_range.x, m_range.y, float(x) / width)
			var loss := 0.0
			var n := float(data.records.size())
			for record in data.records:
				var x_n = record["km_n"]
				var y_n = record["price_n"]
				var y_pred = m_try * x_n + b_try
				var error = y_pred - y_n
				loss += error * error
			loss /= n

			var color_val = clamp(loss * 5.0, 0.0, 1.0)
			var color = Color(0, 1.0 - color_val, color_val)
			loss_image.set_pixel(x, height - y - 1, color)

	var tex := ImageTexture.create_from_image(loss_image)
	loss_map.texture = tex


func _on_button_pressed() -> void:
	#randomize parameters
	m1 = randf_range(m_range.x,m_range.y)
	b1 = randf_range(b_range.x,b_range.y)
	pass # Replace with function body.

func _on_learning_rate_change(value: float) -> void:
	learning_rate = value
	learning_rate_label.text = "learning rate : " + str(learning_rate)
	pass # Replace with function body.
