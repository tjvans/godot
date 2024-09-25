extends Control
class_name MenuController

@export var buttons_container: Node


func _ready() -> void:
	var buttons = buttons_container.get_children()
	for button in buttons:
		pass
