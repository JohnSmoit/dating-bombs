class_name GameMasterSystem
extends Node



# node references
@onready var character_generator : CharacterGeneratorSystem = $CharacterGeneratorSystem
@onready var character_index : CharacterIndexSystem = $CharacterIndexSystem

# Called when the node enters the scene tree for the first time.
func _ready():
	character_index.initialize()
	character_generator.initialize()
