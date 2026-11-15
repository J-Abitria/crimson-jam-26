extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_menu_pressed)

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://title_screen.tscn")
