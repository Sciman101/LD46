extends Camera2D

var timer

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = Global.seconds_per_beat*2
	add_child(timer)
	#timer.start()
	
	timer.connect("timeout",self,"on_timeout")

func on_timeout() -> void:
	offset = Vector2.DOWN * 4

func _process(delta:float) -> void:
	if offset.y != 0:
		offset.y = lerp(offset.y,0,delta*5)
