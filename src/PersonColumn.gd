extends Node2D
tool

const PERSON_TEX = preload("res://assets/textures/Person.png")
const TRANS = [Color("37D0FC"),Color("FCAAB9"),Color.white,Color("FCAAB9"),Color("37D0FC")]

var idle_frames = []
var colors = []
var glow := true

onready var anim = $AnimationPlayer

export(int) var person_count : int = 10 setget set_person_count
export(int) var frame : int = 0 setget set_frame
export(int) var skip : int = -1 setget set_skip

func _draw() -> void:
	
	if frame == 2 and glow:
		draw_rect(Rect2(6,0,36,person_count*64),Color.white)
	
	var make_idle_frames = false
	if idle_frames.empty() or colors.empty():
		idle_frames.clear()
		colors.clear()
		make_idle_frames = true
	
	var transday := false
	var time = OS.get_date()
	if time.day == 31 and time.month == 3:
		transday = true
	
	for i in range(person_count):
		
		if make_idle_frames:
			idle_frames.append(randi()%4)
			var c = float(i)/person_count
			if not transday:
				colors.append(Color.from_hsv(position.x/480,1-c,1.5-c))
			else:
				colors.append(TRANS[int(8*c)%5])
		
		if skip != i:
			var f = idle_frames[i] if frame == 0 else 3+frame
			draw_texture_rect_region(PERSON_TEX,Rect2(0,i*64,48,112),Rect2(f*48,0,48,112),colors[i])


func do_wave(glow:bool) -> void:
	self.glow = glow
	anim.stop()
	anim.play("Wave")


func set_frame(f:int) -> void:
	frame = f
	update()

func set_person_count(count:int) -> void:
	idle_frames.clear()
	colors.clear()
	person_count = count
	update()

func set_skip(s:int) -> void:
	skip = s
	update()
