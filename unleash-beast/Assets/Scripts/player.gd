extends CharacterBody2D

@onready var animation_sprite = $AnimatedSprite2D

func _ready():
    animation_sprite.play("idle")

