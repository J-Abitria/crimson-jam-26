extends Camera2D

@export var default_strength = 30.0
@export var shake_fade = 5.0

var rng = RandomNumberGenerator.new()
var shake_strength = 0

func _ready() -> void:
	rng.randomize()

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		offset = random_offset()
	else:
		offset = Vector2.ZERO

func apply_shake(strength = default_strength):
	shake_strength = strength
	
func random_offset():
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength)
	)
