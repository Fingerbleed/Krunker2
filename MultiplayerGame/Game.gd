extends Node3D


@export var player_template: PackedScene = null


func _ready() -> void:
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())


func add_player(peer_id) -> void:
	var player = player_template.instantiate()
	player.name = str(peer_id)
	add_child(player)
	%AudioStreamPlayer.set_stream(preload("res://addons/kenney music jingles/Sax jingles/jingles_sax_0.ogg"))
	%AudioStreamPlayer.play()


func remove_player(peer_id) -> void:
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
		%AudioStreamPlayer.set_stream(preload("res://addons/kenney music jingles/Sax jingles/jingles_sax_5.ogg"))
	%AudioStreamPlayer.play()
