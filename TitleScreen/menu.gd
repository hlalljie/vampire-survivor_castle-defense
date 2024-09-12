extends Control


var level: String = "res://World/world.tscn"

func _on_play_button_click_end() -> void:
	var _level: Error = get_tree().change_scene_to_file(level)


func _on_quit_button_click_end() -> void:
	print("quit")
	get_tree().quit()
