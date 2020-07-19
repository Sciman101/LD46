extends Sprite

onready var animator = $AnimationPlayer
onready var flash = $Flash
signal player_click()

func _ready() -> void:
	frame = 3
	set_process_input(false)

func _input(event:InputEvent) -> void:
	if not animator.is_playing():
		if (event is InputEventMouseButton or event is InputEventKey) and event.pressed:
			animator.play("Wave")
			emit_signal("player_click")
