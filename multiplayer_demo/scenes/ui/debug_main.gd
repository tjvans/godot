extends Control

# signals
func _on_host_button_pressed() -> void:
	Lobby.player_info["name"] = "Host"
	Lobby.create_game()
	%JoinButton.disabled = true

func _on_join_button_pressed() -> void:
	Lobby.player_info["name"] = "Client"
	Lobby.join_game()
	self.hide()

func _on_load_button_pressed() -> void:
	Signals.load_level.emit()
	self.hide()
