extends Control


var help_button : PackedScene = preload("res://gui/scenes/help_button.tscn")


func get_help_container() -> VBoxContainer:
	return %HelpContainer
