extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_controls_pressed)

func _on_controls_pressed():
	get_tree().change_scene_to_file("res://controls.tscn")
