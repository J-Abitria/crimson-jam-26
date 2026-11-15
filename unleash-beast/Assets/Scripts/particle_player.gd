extends AnimationPlayer

@onready var player = $".."
@onready var particles = $"../ParticleSprite"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.health_changed.connect(_on_health_changed)
	particles.visible = false

func _on_health_changed(amount):
	if amount == 5:
		particles.visible = true
		play("damaged")
