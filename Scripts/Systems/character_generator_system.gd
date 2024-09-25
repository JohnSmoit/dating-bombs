class_name CharacterGeneratorSystem
extends Node


const _SPAWN_AREA_TEMP = 1200.0

# class references
const NPCCharacter = preload("res://Scripts/Entities/npc_character.gd")

# node/scene references
@onready var character_scene = preload("res://Scenes/Entities/npc_character.tscn")
@onready var character_index : CharacterIndexSystem = $/root/Systems/CharacterIndexSystem
@onready var npc_dialogue_system : NPCDialogueSystem = $/root/Systems/NPCDialogueSystem
@onready var sprite_bakery : CharacterSpriteBakery = $/root/Systems/CharacterSpriteBakery

func initialize():
	generate_level_characters()


func generate_level_characters():
	for i in range(3):
		var character = generate_character()
		spawn_character(character, randf(), null)

func generate_character():
	var new_character = character_scene.instantiate()
	var traits = _pick_random_traits(3, null)
	new_character.set_traits(traits)
	_finalize_character_appearance(new_character)
	
	return new_character

# spawn range is a number between 0 and 1
# spawn area dictates the region to spawn the character in (treated as NULL for now
func spawn_character(character : NPCCharacter, spawnRange : float, spawnRegion):
	# place character at location in world depending on parameters
	character_index.add_character(character)
	character.position = Vector2(spawnRange * 1000, -200)
	
	# connect signals to where they need to go
	character.player_interact.connect(npc_dialogue_system._on_npc_interacted)
	print("Spawning New Character!")
	# add character to the active characters index
	pass

# selectionFilter is a dictionary containing either a 
# blakclist or whitelist of traits (Implement Later treat as NULL for now)
func _pick_random_traits(numTraits, selectionFilter):
	var picked = {}
	var chosen = []
	var traits_count = character_index.traits_count
	for i in range(numTraits):
		var potential_trait : Trait = character_index.get_trait_indexed(randi_range(0, traits_count - 1))
		while picked.has(potential_trait.name):
			potential_trait = character_index.get_trait_indexed(randi_range(0, traits_count - 1))
		picked[potential_trait.name] = true
		chosen.append(potential_trait)
		
	return chosen

func _finalize_character_appearance(npc : NPCCharacter):
	for layer in range(CharacterSpriteBakery.SpriteLayers.LAYERS_COUNT):
		var layer_modifier = sprite_bakery.random_appearance_modifier(layer)
		npc.set_default_layer(layer, layer_modifier)
	
	#for layer_modifier in npc.get_appearance_set():
		#print("Layer: %s, Texture %s" % [layer_modifier.layer, layer_modifier.path_name])
