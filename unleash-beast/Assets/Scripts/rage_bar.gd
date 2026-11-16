extends TextureProgressBar

@onready var player = $"../../../Player"
@onready var audio_player = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = 0
	player.rage_changed.connect(_on_rage_changed)
	player.rage_used.connect(_on_rage_used)

func _on_rage_changed(amount):
	if amount == 100 and not value == 100:
		audio_player.stream = load("res://Assets/Sounds/Player/Rage-Full.wav")
		audio_player.play()

	value = amount
	

func _on_rage_used():
	audio_player.stream = load("res://Assets/Sounds/Player/Rage-Use.wav")
	audio_player.play()

	while value > 0:
		value -= 1
		await get_tree().create_timer(0.05).timeout
