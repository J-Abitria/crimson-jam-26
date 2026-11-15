extends TextureProgressBar

@onready var player = $"../../../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = 10
	player.health_changed.connect(_on_health_changed)


func _on_health_changed(amount):
	value = amount
