extends Control


@onready var audio: AudioStreamPlayer = %AudioStreamPlayer


func _on_button_pressed() -> void: # Create room
	Manager.enet_peer.create_server(Manager.PORT)
	multiplayer.multiplayer_peer = Manager.enet_peer
	audio.play()
	get_tree().change_scene_to_file("res://game.tscn")


func joinroom() -> void: # Join room
	Manager.enet_peer.create_client(%TextEdit.text, Manager.PORT)
	multiplayer.multiplayer_peer = Manager.enet_peer
	audio.play()
	get_tree().change_scene_to_file("res://game.tscn")


func _on_button_2_button_down() -> void:
	%Main.hide()
	%Join.show()
	audio.play()


func _on_button_3_button_down() -> void:
	get_tree().quit()
	audio.play()


func volver() -> void:
	%Join.hide()
	%Main.show()
	audio.play()


func _on_nick_edit_text_changed() -> void:
	Manager.nick = %NickEdit.text
