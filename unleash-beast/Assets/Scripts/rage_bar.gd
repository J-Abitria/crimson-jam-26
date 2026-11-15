extends TextureProgressBar

@onready var player = $"../../../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = 0
	player.rage_changed.connect(_on_rage_changed)
	player.rage_used.connect(_on_rage_used)

func _on_rage_changed(amount):
	value = amount

func _on_rage_used():
	while value > 0:
		value -= 1
		await get_tree().create_timer(0.1).timeout
