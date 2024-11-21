#The class that controls the falling arrows, mostly fairly self explanatory
extends Sprite2D

@export var window = 0.2

var speed = 0:set = set_speed
var expected = 0
var state = "active"
var delta_sum_ = 0.0

func set_speed(new_speed:int):
	speed = new_speed

func test_hit(time:float) -> bool:
	if abs(time - expected) < window:
		return true
	return false

func hit():
	state = "hit"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if delta_sum_ < AudioServer.get_output_latency():
		delta_sum_ += delta
		return
	
	global_position.y += delta * speed
	if state == "hit" or global_position.y >= 600:
		queue_free()
	
