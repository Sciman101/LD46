extends CanvasLayer

const RANKS = [
	"Perfect!",
	"A - Amazing!",
	"B - Great!",
	"C - Ok!",
	"... Eh?",
	"Nice"
]

onready var rank_label = $VBoxContainer/Rank
onready var percent_label = $VBoxContainer/Percent
onready var timer = $Util/Timer
onready var scramble_timer = $Util/ScrambleTimer
onready var drumroll = $Util/Drumroll

func _ready() -> void:
	
	timer.one_shot = true
	
	timer.start(1)
	yield(timer,"timeout")
	
	# Scramble text
	drumroll.play()
	scramble_timer.start(0.05)
	
	timer.start(4.2)
	yield(timer,"timeout")
	scramble_timer.stop()
	
	var t = Tween.new()
	add_child(t)
	
	# Show actual rank
	set_percent(max(0,floor(Global.score_percent * 100)))
	if Global.score_percent >= 1:
		set_rank(0)
	elif Global.score_percent >= 0.9:
		set_rank(1)
	elif Global.score_percent >= 0.75:
		set_rank(2)
	elif round(Global.score_percent * 100) == 69:
		set_rank(5)
	elif Global.score_percent >= 0.5:
		set_rank(3)
	else:
		t.interpolate_property(drumroll,"pitch_scale",1,0.75,1,Tween.TRANS_LINEAR,Tween.EASE_OUT,0.1)
		t.start()
		set_rank(4)
	
	timer.start(2)
	yield(timer,"timeout")
	percent_label.text += "\n\nThanks so much for playing!\nDon't forget to leave a rating, and\nenjoy the rest of the Ludum Dare!"
	$Util/Music.play(8)
	t.interpolate_property($Rainbow,"rect_scale",Vector2(1,0),Vector2.ONE,0.5,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
	t.start()


func _on_ScrambleTimer_timeout():
	set_rank(randi()%RANKS.size())
	set_percent(randi()%100)

func set_percent(val:int) -> void:
	percent_label.text = "%d%% Accuracy" % val

func set_rank(index:int) -> void:
	rank_label.text = RANKS[index]
