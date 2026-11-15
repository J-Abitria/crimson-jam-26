extends Button

func _ready() -> void:
    button_up.connect(_on_replay_pressed)

func _on_replay_pressed():
    get_tree().change_scene_to_file("res://battleground.tscn")