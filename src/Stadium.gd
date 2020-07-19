extends Node2D

const HIT_MARGIN : float = 0.1 # Difference needs to be less than this to count as a hit
const BARELY_MARGIN : float = 0.2 # Difference needs to be less than this to count as a near miss

# Song beat data
var beat_times = [8.1, 9.6, 11.6, 13.6, 14.6, 15.6, 17.6, 19.6, 21.6, 22.6, 23.6, 25.6, 27.6, 29.6, 30.6, 33.6, 35.6, 37.6, 38.6, 41.6, 43.6, 44.6, 45.6, 47.1, 48.1, 49.1, 50.1, 51.6, 53.6, 55.6, 56.6, 59.6, 61.6, 63.6, 64.6, 65.6, 67.6, 69.6, 71.6, 72.6, 73.6, 82.1, 84.1, 86.1, 88.1, 90.1, 92.1, 94.1, 95.1, 96.1, 98.1, 100.1, 101.1, 102.1, 104.1, 105.1, 107.6, 109.6, 111.6, 112.6, 113.6, 115.6, 117.6, 119.6, 120.6, 121.6, 124.1, 125.1, 126.1]
var current_beat : int = 0
var score : int = 0

onready var music = $Util/Music
onready var hitsound = $Util/Clap

# Stuff used to control waves
onready var timer = $Util/WaveTimer
onready var player = $Visuals/Player
onready var friend = $Visuals/Friend
onready var camera = $Camera2D
onready var distraction_animator = $Util/DistractionAnimator
onready var ui = $UI
onready var tutorial = $UI/Tutorial

var columns = []
var num_people_on_side

# Wave properties
var wave_duration : float = Global.seconds_per_beat * 2
var wave_dir : int = 0

# Various boolean flags
var wave_done := false
var has_clicked := false
var wave_interrupt := false
var click_cooldown := 0.0

func _ready() -> void:
	# Get columns
	columns = $Visuals/People.get_children()
	
	set_friend_visible(false)
	
	num_people_on_side = columns.size()/2
	
	# Hide distractions
	camera.zoom = Vector2.ONE * 0.3
	camera.position = Vector2(0,-328)
	$Visuals/Spotlight.visible = false


# Check for any button to start
func _input(event:InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventKey) and event.pressed:
		set_process_input(false)
		start_game()


func start_game() -> void:
	distraction_animator.play("StartGame")
	yield(distraction_animator,"animation_finished")
	
	set_friend_visible(true)
	tutorial.do_tutorial()
	yield(tutorial,"dialouge_over")
	set_friend_visible(false)
	
	# Start the game!!
	player.set_process_input(true)
	music.play()
	camera.timer.start()
	$Visuals/Pointer.visible = true


# Check the current position of music playback and create waves
func _process(delta:float) -> void:
	
	if click_cooldown > 0: click_cooldown -= delta
	
	var pos = music.get_playback_position()
	
	#$UI/Label.text = str(current_beat)
	
	# Play distractions
	if not distraction_animator.is_playing() and pos < 100:
		if pos >= 30 and pos <= 31:
			distraction_animator.play("Zoom")
		elif pos >= 57 and pos <= 58:
			distraction_animator.play("Pan Up")
		elif pos >= 90 and pos <= 91:
			distraction_animator.play("Spotlight")
	
	
	if pos >= beat_times[current_beat]+0.15:
		# Go to the next beat
		current_beat += 1
		wave_done = false
		
		# If we didn't make an attempt at all, we missed
		if not has_clicked:
			wave_interrupt = true
			ui.show_indicator(2)
		has_clicked = false
		
		# Have we reached the end?
		if current_beat >= beat_times.size():
			set_process(false)
			on_song_end()
		
	elif not wave_done and music.get_playback_position() >= beat_times[current_beat]-wave_duration:
		# Make a wave
		if is_last_beat():
			# On the last beat, the wave comes from both directions
			create_wave(true)
			create_wave(false)
		else:
			wave_dir = randi()%2
			create_wave(wave_dir)
		wave_done = true

# Create a wave
func create_wave(reverse:bool=false) -> void:
	# Determine per-person delay based on wave duration
	var delay = wave_duration/(num_people_on_side+3)
	
	for i in range(columns.size()):
		# Trigger wave effect on current column
		var x = (columns.size()-1)-i if reverse else i
		columns[x].do_wave(not reverse == (x < num_people_on_side) or x == num_people_on_side)
		
		# Wait
		timer.start(delay)
		yield(timer,"timeout")
		
		# Cut off the wave if we've missed
		if wave_interrupt and i == num_people_on_side+1:
			wave_interrupt = false
			return


# Helper used to sort player columns
func set_friend_visible(vis:bool) -> void:
	# Hide friend
	columns[6].skip = 2 if vis else -1
	friend.visible = vis


# Check if we're at the end of the song
func is_last_beat() -> bool:
	return current_beat >= beat_times.size()-1


func on_song_end() -> void:
	# Write score to global
	Global.score_percent = float(score)/(beat_times.size()*2)
	
	# Pan camera up
	yield(music,'finished')
	distraction_animator.play("Pan Up End")
	camera.timer.stop()
	yield(distraction_animator,"animation_finished")
	get_tree().change_scene("res://ResultsScreen.tscn")


# When the player actually tries to do an input
func _on_Player_player_click():
	# Make sure we aren't past the end of the song
	if current_beat >= beat_times.size() or click_cooldown > 0: return
	
	# Hide the player 'perfect' flash
	player.flash.visible = false
	
	# If we've already clicked this wave and hit, then this must be a miss
	if has_clicked:
		score -= 1
		ui.show_indicator(2)
		return
	
	# Get player error
	var difference = abs(music.get_playback_position() - beat_times[current_beat])
	var success := true
	
	if difference < HIT_MARGIN: # Nailed it
		score += 2
		player.flash.visible = true
		ui.show_indicator(0)
	elif difference < BARELY_MARGIN: # Amost got it
		score += 1
		ui.show_indicator(1)
	else: # Outright miss
		wave_interrupt = true
		success = false
		ui.show_indicator(2)
	
	# If we were successful...
	if success:
		has_clicked = true
		hitsound.play()
		click_cooldown = 0.05
		# Play a special animation on the last beat
		if is_last_beat():
			var a = player.get_node("AnimationPlayer")
			a.stop()
			a.play("Jump")
