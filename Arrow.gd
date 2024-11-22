@tool
extends Sprite2D

@export var is_pressed = false:set=set_pressed
@export var color:Color
@export var key:String
@export var note:int


func set_pressed(value:bool):
	is_pressed = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_pressed:
		modulate = lerp(modulate, color, 1.0)
		scale.y  = lerp(scale.y, 0.7, 1)
		scale.x  = lerp(scale.x, 0.7 , 1)
	else:
		modulate = lerp(modulate, Color.GRAY, delta * 10.0)
		scale.y  = lerp(scale.y, 0.5, delta * 10.0)
		scale.x  = lerp(scale.x, 0.5, delta * 10.0)
