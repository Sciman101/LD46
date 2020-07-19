extends Sprite

export var speed : float
export var frame_time : float

func _ready() -> void:
	var timer = Timer.new()
	timer.one_shot = false
	timer.connect("timeout",self,"next_frame")
	add_child(timer)
	timer.start(frame_time)

func _process(delta:float) -> void:
	position += Vector2.LEFT * delta * speed
	if position.x < -380:
		position.x = 380

func next_frame() -> void:
	frame = wrapi(frame+1,0,vframes)
