extends NinePatchRect

const DIALOUGE = [
	"Hey, looks like people are doing a wave",
	"You know how to do a wave, right?",
	"It's easy! Just press any button when the white bar reaches you",
	"Best part is, the wave is in time with the music",
	"So don't let the visuals distract you too much!",
	"And remember, keep the wave alive!"
]

onready var text = $Dialouge
onready var blip = $Blip
signal dialouge_over

var current_line := 0

func _ready() -> void:
	visible = false
	set_process_input(false)


func _input(event:InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventKey) and event.pressed:
		next_line()


func do_tutorial() -> void:
	visible = true
	set_process_input(true)
	current_line = -1
	next_line()

func next_line() -> void:
	blip.play()
	current_line += 1
	if current_line >= DIALOUGE.size():
		visible = false
		set_process_input(false)
		emit_signal("dialouge_over")
	else:
		text.text = DIALOUGE[current_line]
