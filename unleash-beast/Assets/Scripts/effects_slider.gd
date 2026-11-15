extends HSlider

@export var init_effects_volume = -5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value_changed.connect(_on_h_slider_value_changed)
	value = init_effects_volume


func _on_h_slider_value_changed(new_value: float) -> void:
	value = new_value
	AudioLevel.sound_effect_volume = value
