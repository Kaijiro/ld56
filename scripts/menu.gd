extends Control



func _on_classic_mode_button_pressed() -> void:
    self.get_tree().change_scene_to_file("res://scenes/ld_56.tscn")

func _on_creative_mode_button_pressed() -> void:
    self.get_tree().change_scene_to_file("res://scenes/creative.tscn")
