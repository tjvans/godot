extends Node3D

@export var main_menu_scene: PackedScene
@export var lobby_scene: PackedScene

func _ready() -> void:
	var game_root: Node3D = $GameManager
	var ui_root: CanvasLayer = $UI
	Globals.game_root = game_root
	Globals.ui_root = ui_root
	
	var main_menu = main_menu_scene.instantiate()
	ui_root.add_child(main_menu)
	var lobby = lobby_scene.instantiate()
	ui_root.add_child(lobby)
