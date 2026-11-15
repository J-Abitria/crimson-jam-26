extends AudioStreamPlayer

@onready var player = $"../Player"
@onready var twin_1 = $"../Twin-1"
@onready var twin_2 = $"../Twin-2"
@onready var player_death = AudioStreamWAV.load_from_file("res://Assets/Sounds/Player/Player-Death.wav")
@onready var enemy_death = AudioStreamWAV.load_from_file("res://Assets/Sounds/Twin/Twin-Death.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.died.connect(_on_player_death)
	twin_1.enemy_died.connect(_on_enemy_death)
	twin_2.enemy_died.connect(_on_enemy_death)

func _on_player_death():
	volume_db = -5
	stream = player_death
	play()
	volume_db = 0

func _on_enemy_death():
	stream = enemy_death
	play()
