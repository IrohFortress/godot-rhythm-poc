# Godot is a purely object oriented engine, every script is attached to a node.
# Node2d is the root node, this is the scene (node) that is run first by the
# engine. Here, we define logic for rendering the note components

extends Node2D

const END_POSITION = 400

#Most important of these is time to bottom, which you can change from inspector
@export var starting_y = -200
@export var time_to_bottom = 1.5
@export var bpm = 120

var score := 0
var total_time := 0.0
var lanes = {}

func _detect_key_pressed(key:String):
	return Input.is_action_just_pressed("ui_{key}".format({"key": key}))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Initialise bottom buttons
	for i in $Buttons.get_children():
		lanes[i.note] = {		\
			"node": i,			\
			"key": i.key,		\
			"color": i.color,	\
			"queue": []			\
		}
	
	#Midi processing
	$MidiPlayer.set_tempo(bpm)
	$MidiPlayer.midi_event.connect(_on_midi_event)
	
	#Start midi player, then wait before starting audio
	$MidiPlayer.play()
	await get_tree().create_timer(time_to_bottom).timeout
	$AudioStreamPlayer2D.play()

#Called when a midi event is encountered - create an arrow
func _on_midi_event(_channel, event) -> void:
	#Fail cases
	if event.type != SMF.MIDIEventType.note_on:
		return
	var note = event.note
	if note not in lanes.keys():
		return
	
	#Queue new note to fall
	var i = preload("res://scenes/note.tscn").instantiate()
	add_child(i)
	i.expected = total_time + time_to_bottom
	i.global_position.y = starting_y
	i.global_position.x = lanes[note].node.global_position.x
	i.global_rotation = lanes[note].node.global_rotation
	i.color = lanes[note].color
	i.speed = (END_POSITION - starting_y)/time_to_bottom
	lanes[note].queue.push_back(i)

# Called every frame - 'delta' = elapsed time in seconds since previous frame.
func _process(delta: float) -> void:
	total_time += delta
	
	#Track whether a note has been hit, remove missed notes
	for l in lanes.values():
		l.node.is_pressed = _detect_key_pressed(l.key)
		
		if not l.queue.is_empty() && l.queue.front().global_position.y > 590:
			l.queue.pop_front()
			
		if !l.node.is_pressed:
			continue
			
		if not l.queue.is_empty() and l.queue.front().test_hit(total_time):
			l.queue.pop_front().hit()
			score += 1
		
	
	$Score.set_text(str(score))
	
	
	

	
