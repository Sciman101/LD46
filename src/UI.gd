extends CanvasLayer

onready var indicators = [$Great,$Good,$Miss]

var tween : Tween

func _ready() -> void:
	tween = Tween.new()
	add_child(tween)

func show_indicator(index:int) -> void:
	tween.stop(indicators[index],"rect_position")
	tween.interpolate_property(indicators[index],"rect_position",Vector2(0,600),Vector2(0,480),0.2,Tween.TRANS_BACK,Tween.EASE_OUT)
	tween.interpolate_property(indicators[index],"rect_position",Vector2(0,480),Vector2(0,600),0.05,Tween.TRANS_QUART,Tween.EASE_IN,0.4)
	tween.start()
