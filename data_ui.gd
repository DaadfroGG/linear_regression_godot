extends Control
class_name Data_UI

@onready var label: Label = $HBoxContainer/MarginContainer/Label
@onready var label2: Label = $HBoxContainer/MarginContainer2/Label
@onready var label3: Label = $HBoxContainer/MarginContainer3/Label

func update_data(m_value: float, b_value: float, loss_value: float) -> void:
	# Show formatted, readable numbers
	label.text = "m: %.4f" % m_value
	label2.text = "b: %.4f" % b_value
	label3.text = "loss: %.6f" % loss_value
