extends TextureProgressBar

@onready var player = $"../../../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = 0
	player.rage_changed.connect(_on_rage_changed)


func _on_rage_changed(amount):
	value = amount
