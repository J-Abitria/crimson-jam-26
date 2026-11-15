extends AnimationPlayer

@onready var player = $"../../Player"
@onready var enemy_manager = $"../../EnemyManager"

func _ready() -> void:
	player.died.connect(_on_game_end)
	enemy_manager.enemies_defeated.connect(_on_game_end)

func _on_game_end():
	play("fade-out")
