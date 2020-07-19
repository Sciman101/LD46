extends Sprite
tool

onready var target = $SpotlightTarget

func _process(delta:float) -> void:
	var p = target.position
	region_rect.position = -(p + Vector2(200,200))
