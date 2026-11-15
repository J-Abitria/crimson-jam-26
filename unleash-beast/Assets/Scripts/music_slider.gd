extends HSlider

@export var init_music_value = -20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value_changed.connect(_on_h_slider_value_changed)
	value = init_music_value


func _on_h_slider_value_changed(new_value: float) -> void:
	value = new_value
	AudioLevel.music_volume = value
