class_name GameMasterSystem
extends Node



# node references
@onready var character_generator : CharacterGeneratorSystem = $CharacterGeneratorSystem
@onready var character_index : CharacterIndexSystem = $CharacterIndexSystem
@onready var sprite_bakery : CharacterSpriteBakery = $CharacterSpriteBakery

@onready var player : PlayerCharacter = $/root/MainScene/Player
@onready var timer : Timer = $GameTimer

@onready var hud : GameHUD = $/root/MainScene/CanvasLayer/HUD

@onready var scene_characters : Node2D = $/root/MainScene/SceneCharacters


const DATES_REQUIRED = 5
var dates_counter = 0

var preferred_traits : Array[Trait] = []

func add_successful_date():
	dates_counter += 1
	pick_preferences()

func time_penalty(seconds : float):
	hud.timer_flash_alert(2.0)
	timer.start(max(timer.time_left - seconds, 0))

func get_remaining_time():
	return timer.time_left

# Called when the node enters the scene tree for the first time.
func _ready():
	Trait.static_init(self)
	sprite_bakery.preregister_textures()
	
	character_index.initialize()
	character_generator.initialize()
	
	pick_preferences()

func pick_preferences():
	preferred_traits.clear()
	
	var rand_character_index = randi_range(0, scene_characters.get_child_count() - 1)
	var rand_character = scene_characters.get_child(rand_character_index)
	
	preferred_traits.append_array(rand_character.traits)
	hud.update_preferred_traits(preferred_traits)
