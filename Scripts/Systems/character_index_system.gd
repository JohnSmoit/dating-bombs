class_name CharacterIndexSystem
extends Node


@onready var scene_characters = $/root/MainScene/SceneCharacters

var _traits_index = {}

func initialize():
	_read_traits_files();
	
func add_character(character):
	scene_characters.add_child(character)

var traits_count: int:
	get:
		return _traits_index.keys().size()

func get_trait_indexed(index : int):
	return _traits_index[_traits_index.keys()[index]]
# reads imported JSON files and potentially external files if we have time
func _read_traits_files():
	var data_dir : DirAccess = DirAccess.open("res://Data")
	var data_entries = []
	if data_dir:
		var err = data_dir.list_dir_begin()
		if err != OK:
			print("Failed to open traits directory!\nReason: %s", error_string(err))
			return
		
		var file_name = data_dir.get_next()
		while file_name != "":
			if !data_dir.current_is_dir():
				print("Found data file: " + file_name)
				data_entries.append(file_name)
			else:
				print("Found internal directory for some reason")
			file_name = data_dir.get_next()
		data_dir.list_dir_end()
	else:
		print("Could not open data directory")
	
	print("All Entries: " + _array_to_string(data_entries))
	
	# merge the JSON data 
	# TODO: Make trait loading merge multiple JSON files into a single object
	
	for file_name in data_entries:
		var full_path = "res://Data/%s" % file_name
		print("Attempting to load %s...", full_path)
		var json_data : JSON = ResourceLoader.load(full_path, "JSON")
		
		# load each sub object of the main JSON array (with error checking)
		var parsed_data = json_data.data
		if typeof(parsed_data) == TYPE_ARRAY:
			
			for trait_data in parsed_data:
				_create_trait_for(trait_data)
		else:
			printerr("Root JSON element must be a string for " + file_name)
	
	#TODO (Maybe): Handle external trait files?


func _create_trait_for(trait_data):
	print("Attempting to define trait named %s..." % trait_data["name"])
	
	var new_trait = Trait.create_from_dict(trait_data)
	var errors = new_trait.get_config_errors()
	if errors:
		printerr("Failed to load trait %s!" % trait_data["name"])
		for error in errors:
			printerr(error)
		pass
	else:
		_traits_index[trait_data["name"]] = new_trait

func _array_to_string(array : Array):
	var out = "["
	
	for item in array:
		out += " %s " % item
	
	out += "]"
	
	return out
