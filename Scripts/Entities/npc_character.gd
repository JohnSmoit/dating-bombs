class_name NPCCharacter
extends CharacterBody2D

var traits : Array[Trait]

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var interaction_radius : Area2D = $Area2D
@onready var boing_boing : BoingBoing2D = $BoingBoing2D

var _current_player : PlayerCharacter = null
var _wander_timer = 0
@onready var _wander_target : float = position.x

const MOVE_SPEED = 1200

var appearance_layers : Array[CharacterSpriteBakery.TraitAppearanceModifier] = []

#signals
signal player_interact(npc : NPCCharacter)

func _init():
	appearance_layers.resize(CharacterSpriteBakery.SpriteLayers.LAYERS_COUNT)

func _ready():
	interaction_radius.body_entered.connect(_on_interaction_radius_entered)
	interaction_radius.body_exited.connect(_on_interaction_radius_exited)
	
	_start_wander_timer()


func _start_wander_timer():
	_wander_timer = randf_range(5, 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	#if _wander_timer > 0:
		#_wander_timer -= delta
		#if _wander_timer <= 0:
			#_wander_target = position.x + randf_range(-600, 600)
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#var dist = _wander_target - position.x
	#if abs(dist) > 10:
		#boing_boing.do_boing(1)
		#velocity.x = (-1 if dist < 0 else 1) * MOVE_SPEED * delta
		#print(velocity.x)
	#elif _wander_timer <= 0:
		#boing_boing.reset_boing()
		#velocity.x = move_toward(velocity.x, 0, delta)
		#_start_wander_timer()
	move_and_slide()
	
func _process(delta):
	#handle player interactionss
	if Input.is_action_just_pressed("player_interact") and _current_player:
		player_interact.emit(self)

func set_traits(_traits):
	self.traits.append_array(_traits)


#TODO: Setup system for detgerminining whether a modifier is default or added by a trait
func has_layer_modifier(layer):
	return false

func set_default_layer(layer, layer_modifier):
	appearance_layers[layer] = layer_modifier

func get_appearance_set():
	var modified_layers = Array(appearance_layers)
	for tr in traits:
		for modifier in tr.trait_appearance_modifiers:
			modified_layers[modifier.layer] = modifier 
	return appearance_layers

#NOTE: Maybe add this to the player instead, since overlapping NPCS would make it hard to guarantee which one is interacted with
func _on_interaction_radius_entered(body : Node2D):
	if body is PlayerCharacter:
		_current_player = body

func _on_interaction_radius_exited(body : Node2D):
	if body is PlayerCharacter and body == _current_player:
		_current_player = null
