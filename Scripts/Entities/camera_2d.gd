extends Camera2D

@export var radius_max : float = 1200
@export var radius_min : float = 200
@export var zoom_min : float = 0.25
@export var zoom_max : float = 1.5
@export var restitution_factor : float = 0.5
@export var drift_max : float = 100

var _zoom_target : float = 1.0
var _positional_drift : float = 0
var _current_pos_drift : float = 0

const _MAX_SPEED : float = 25

var sq_radius_min : float:
	get:
		return radius_min * radius_min

var sq_radius_max : float:
	get:
		return radius_max * radius_max
		

func _ready():
	pass


# zooms the camera between max and min values based on a min and max distance for the cursor from the center of the screen
func _process(delta):
	var viewport = get_viewport()
	
	var viewport_rect = viewport.get_visible_rect()
	var center = Vector2(viewport_rect.size.x, viewport_rect.size.y) * 0.5
	var mouse = viewport.get_mouse_position()
	
	var dist_sq = (center - mouse).length_squared()
	
	if dist_sq < sq_radius_max and dist_sq > sq_radius_min:
		var range = sq_radius_max
		var zoom_factor = 1 - (dist_sq / range)
		
		_zoom_target = (zoom_min + zoom_factor * (zoom_max - zoom_min))
		_positional_drift = (1 - zoom_factor) * drift_max
	elif dist_sq < sq_radius_min:
		_zoom_target = zoom_max
		_positional_drift = 0
	
	if abs(_positional_drift - _current_pos_drift) > 0.002:
		_current_pos_drift += min((_positional_drift - _current_pos_drift) * restitution_factor, _MAX_SPEED)
		
	
	position = (mouse - center).normalized() * _current_pos_drift
	if abs(zoom.x - _zoom_target) > 0.002:
		zoom += Vector2.ONE * ((_zoom_target - zoom.x) * restitution_factor)
