class_name GameMasterSystem
extends Node



# node references
@onready var character_generator : CharacterGeneratorSystem = $CharacterGeneratorSystem
@onready var character_index : CharacterIndexSystem = $CharacterIndexSystem
@onready var sprite_bakery : CharacterSpriteBakery = $CharacterSpriteBakery

# Called when the node enters the scene tree for the first time.
func _ready():
	Trait.static_init(self)
	sprite_bakery.preregister_textures()
	
	character_index.initialize()
	character_generator.initialize()
	
