class_name BoingBoing2D
extends Node2D

@export var boing_amount : float = 65
@export var boing_speed : float = 20.0
# makes child node boing boing
# Called when the node enters the scene tree for the first time.
var first_child : Node2D = null
var _squash_amount : float = 0
var _force_offset_y : float = 0
func _ready():
	first_child = get_child(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	first_child.position.y = _force_offset_y
	
func do_boing(speed_mult):
	var sin_offset = sin(Time.get_ticks_msec() / 1000.0 * speed_mult * boing_speed)
	_force_offset_y = -abs(sin_offset) * boing_amount * abs(speed_mult)
	first_child.rotation = sin_offset * boing_amount * 0.005

func reset_boing():
	_force_offset_y = 0
	_squash_amount = 1
	first_child.rotation = 0
