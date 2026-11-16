extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_credits_pressed)

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://credits.tscn")
