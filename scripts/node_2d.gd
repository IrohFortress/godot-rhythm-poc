# Godot is a purely object oriented engine, every script is attached to a node.
# Node2d is the root node, this is the scene (node) that is run first by the
# engine. Here, we define logic for rendering the note components

extends Node2D

const END_POSITION = 400

#Most important of these is time to bottom, which you can change from inspector
@export var starting_x = 400
@export var starting_y = -200
@export var time_to_bottom = 1.0
@export var bpm = 120

var score := 0
var total_time := 0.0
var queue := []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MidiPlayer.set_tempo(bpm)
	$MidiPlayer.midi_event.connect(_on_midi_event)
	
	##Start midi player, then wait before starting audio
	$MidiPlayer.play()
	await get_tree().create_timer(time_to_bottom).timeout
	$AudioStreamPlayer2D.play()

#Called when a midi event is encountered - create an arrow
func _on_midi_event(channel_, event) -> void:
	if event.type != SMF.MIDIEventType.note_on:
		return
		
	var i = preload("res://scenes/note.tscn").instantiate()
	add_child(i)
	i.expected = total_time + time_to_bottom
	i.global_position.y = starting_y
	i.global_position.x = starting_x
	i.speed = (END_POSITION - starting_y)/time_to_bottom
	queue.push_back(i)

# Called every frame - 'delta' = elapsed time in seconds since previous frame.
func _process(delta: float) -> void:
	total_time += delta
	if Input.is_action_just_pressed("ui_select"):
		if not queue.is_empty() and queue.front().test_hit(total_time):
			queue.pop_front().hit()
			score += 1

	if not queue.is_empty() && queue.front().global_position.y > 590:
		queue.pop_front()
	
	$Score.set_text(str(score))
	
	
	

	
