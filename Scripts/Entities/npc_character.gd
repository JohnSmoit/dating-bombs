class_name NPCCharacter
extends CharacterBody2D

var traits : Array[Trait]

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var interaction_radius : Area2D = $Area2D

var _current_player : PlayerCharacter = null

#signals
signal player_interact(npc : NPCCharacter)

func _ready():
	interaction_radius.body_entered.connect(_on_interaction_radius_entered)
	interaction_radius.body_exited.connect(_on_interaction_radius_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()
	
func _process(delta):
	#handle player interactionss
	if Input.is_action_just_pressed("player_interact") and _current_player:
		player_interact.emit(self)

func set_traits(_traits):
	self.traits.append_array(_traits)

#NOTE: Maybe add this to the player instead, since overlapping NPCS would make it hard to guarantee which one is interacted with
func _on_interaction_radius_entered(body : Node2D):
	if body is PlayerCharacter:
		_current_player = body

func _on_interaction_radius_exited(body : Node2D):
	if body is PlayerCharacter and body == _current_player:
		_current_player = null
