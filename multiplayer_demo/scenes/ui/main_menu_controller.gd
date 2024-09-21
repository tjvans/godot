extends Control

@export var visible_on_start: bool

@export var host_button: Button
@export var join_button: Button
@export var start_button: Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = visible_on_start
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)


func _on_host_button_pressed():
	Lobby.create_game()

func _on_join_button_pressed():
	Lobby.join_game(Lobby.local_ip)

func _on_start_button_pressed():
	Lobby.load_game(Globals.game_root, )
