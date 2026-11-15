extends AnimationPlayer

@onready var player = $"../../Player"

func _ready() -> void:
	player.died.connect(_on_player_death)

func _on_player_death():
	play("fade-out")
