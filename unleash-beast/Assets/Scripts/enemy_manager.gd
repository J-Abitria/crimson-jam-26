extends Node2D

signal enemies_defeated

@export var enemy_count = 2

@onready var twin_1 = $"../Twin-1"
@onready var twin_2 = $"../Twin-2"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	twin_1.enemy_removed.connect(_on_enemy_death)
	twin_2.enemy_removed.connect(_on_enemy_death)


func _on_enemy_death():
	enemy_count -= 1

	if enemy_count == 0:
		enemies_defeated.emit()
		await get_tree().create_timer(1.1).timeout
		get_tree().change_scene_to_file("res://win_scene.tscn")