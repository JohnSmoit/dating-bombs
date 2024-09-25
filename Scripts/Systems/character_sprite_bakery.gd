class_name CharacterSpriteBakery
extends Node

#node/scene references
@onready var viewport : SubViewport = $SubViewport
@onready var texture_base : TextureRect = $SubViewport/TextureRect


const _BASE_PATH : String = "res://Resources/Textures/Characters/"
const _WORLD_EXTENSION : String = "_world"





enum {
	MODE_PORTRAIT,
	MODE_WORLD
}

enum SpriteLayers {
	LAYER_BASE = 0,
	LAYER_CLOTHING,
	LAYER_MOUTH,
	LAYER_NOSE,
	LAYER_EYES,
	LAYER_EYEBROWS,
	LAYER_ACCESSORY,
	LAYER_HAIR,
	LAYERS_COUNT
}

static var layer_name_map : Dictionary = {
	"Base": SpriteLayers.LAYER_BASE,
	"Clothing": SpriteLayers.LAYER_CLOTHING,
	"Mouth": SpriteLayers.LAYER_MOUTH,
	"Nose": SpriteLayers.LAYER_NOSE,
	"Eyes": SpriteLayers.LAYER_EYES,
	"Eyebrows": SpriteLayers.LAYER_EYEBROWS,
	"Accessory": SpriteLayers.LAYER_ACCESSORY,
	"Hair": SpriteLayers.LAYER_HAIR,
}

var _file_path_table = {}
var _layer_path_table = []
var _sprite_image_set = []

# preregisters all textures found in /Textures/Characters/* with their file paths
func preregister_textures():
	# setup sprite image set
	for i in range(SpriteLayers.LAYERS_COUNT):
		_layer_path_table.append([])
		_sprite_image_set.append([])
	
	# set up viewport layers
	var sprite_image = load("res://Resources/Textures/Characters/Base/skin1.png") # setup the image texture to use the default texture size for all sprite parts
	sprite_image.fill(Color(0, 0, 0, 0))
	var img_base = ImageTexture.create_from_image(sprite_image)
	
	texture_base.texture = img_base
	
	for layer in range(SpriteLayers.LAYERS_COUNT - 1):
		var layer_tex_slot = texture_base.duplicate()
		var texture = img_base.duplicate(true)
		layer_tex_slot.texture = texture
		viewport.add_child(layer_tex_slot)
	

	
	# load references to files for the file path table
	var sprite_dir = DirAccess.open(_BASE_PATH)
	if sprite_dir:
		var err = sprite_dir.list_dir_begin()
		if err != OK:
			print("Encountered error listing directory: " + error_string(err))
			return
		
		var directory_name = sprite_dir.get_next()
		while directory_name != "":
			if sprite_dir.current_is_dir():
				_load_directory_textures(directory_name)
			else:
				print("Encountered non-directory in root character directory: " + directory_name)
			directory_name = sprite_dir.get_next()
		sprite_dir.list_dir_end()
	
	#for layer in _layer_path_table.size():
		#print("layer: " + str(layer))
		#for path in _layer_path_table[layer]:
			#print("path: " + path)

func _load_directory_textures(dir_name : String):
	var layer = layer_name_map[dir_name]
	#print("loading textures from: " + dir_name)
	var path = _BASE_PATH + dir_name + "/"
	var dir = DirAccess.open(path)
	if dir:
		for file_name in dir.get_files():
			if !_fname_ends_with(file_name, _WORLD_EXTENSION) and !file_name.get_extension() == "import":
				var file_path = path + file_name
				_file_path_table[file_path] = -1
				#print("Adding %s to layer %s" % [file_path, layer])
				_layer_path_table[layer].append(file_path)
	else:
		print("Failed to open directory: " + dir_name)

func _set_viewport_update():
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func random_appearance_modifier(layer : SpriteLayers):
	var path_set = _layer_path_table[layer]
	var path = path_set[randi_range(0, path_set.size() - 1)]
	var index = _file_path_table[path]
	return TraitAppearanceModifier.new(index, layer, path)

func request_character_texture(texture_mode, npc_info : NPCCharacter, texture):
	print("Traits: %s %s %s" % [npc_info.traits[0].name, npc_info.traits[1].name, npc_info.traits[2].name])
	var appearance_modifiers = npc_info.get_appearance_set()
	for layer_modifier in appearance_modifiers: # NOTE: As expected, this is very slow, but it will have to do for now
		var image = _get_or_load_image(layer_modifier)
		var layer_node : TextureRect = viewport.get_child(layer_modifier.layer)
		var tex : ImageTexture = layer_node.texture

		tex.update(image)
	
	_set_viewport_update()
	return viewport.get_texture()

func _map_layer_id_to_node(id : int):
	return SpriteLayers.LAYERS_COUNT - 1 - id
func request_appearance_modifier(layer_name : String, tex_path : String):
	return _request_appearance_modifier_i(layer_name_map[layer_name], tex_path)

func _request_appearance_modifier_i(layer : SpriteLayers, tex_path : String):
	var full_tex_path = _BASE_PATH + tex_path
	var current_index = _file_path_table[full_tex_path]
	return TraitAppearanceModifier.new(current_index, layer, full_tex_path)

func _fname_ends_with(name : String, ending : String):
	return name.ends_with(ending + ".png")

func _get_or_load_image(modifier : TraitAppearanceModifier):
	if modifier.id != -1:
		# print("found image named: " + modifier.path_name)
		return _sprite_image_set[modifier.layer][modifier.id]
	else:
		var loaded_image = load(modifier.path_name)
		
		modifier.id = _sprite_image_set[modifier.layer].size()
		_sprite_image_set[modifier.layer].append(loaded_image)
		
		return loaded_image

class TraitAppearanceModifier extends RefCounted:
	var id : int = 0
	var layer : SpriteLayers = SpriteLayers.LAYER_BASE
	var path_name : String = ""
	static var bakery_instance : CharacterSpriteBakery = null
	
	func _init(_id, _layer, _path_name,  _bakery_instance = null):
		self.id = _id
		self.layer = _layer
		self.path_name = _path_name
		
		if !self.bakery_instance and _bakery_instance:
			self.bakery_instance = _bakery_instance
