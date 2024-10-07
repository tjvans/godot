extends Node3D


@export var main_menu_scene: PackedScene
@export var lobby_scene: PackedScene
@onready var game_root: Node3D = $GameManager
@onready var ui_root: CanvasLayer = $UI 


func _ready() -> void:
	Globals.game_root = game_root
	Globals.ui_root = ui_root
	
	var main_menu = main_menu_scene.instantiate()
	ui_root.add_child(main_menu)
	var lobby = lobby_scene.instantiate()
	ui_root.add_child(lobby)
