extends Control

# signals
func _on_host_button_pressed() -> void:
	Lobby.create_game()


func _on_join_button_pressed() -> void:
	Lobby.join_game()
	self.hide()


func _on_start_button_pressed() -> void:
	Signals.game_start.emit()
	self.hide()
