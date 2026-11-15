extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	volume_db = AudioLevel.music_volume
	print("Volume is " + str(volume_db))
