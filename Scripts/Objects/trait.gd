class_name Trait
extends RefCounted

static var sprite_bakery : CharacterSpriteBakery = null

static func static_init(game_master : GameMasterSystem):
	sprite_bakery = game_master.sprite_bakery

enum {
	RESPONSE_GOOD,
	RESPONSE_BAD
}

enum {
	PLAYER_RESPONSE_TEXT,
	NPC_RESPONSE_TEXT
}

var name : String
var description : String
var displayLabel : String
var messages : Array[DialogueMessage] = []
var trait_appearance_modifiers : Array[CharacterSpriteBakery.TraitAppearanceModifier] = []

static func create_from_dict(trait_data):
	var new_trait = Trait.new()
	
	new_trait.name = _value_if_key_exists(trait_data, "name", true)
	new_trait.description = _value_if_key_exists(trait_data, "description")
	new_trait.displayLabel = _value_if_key_exists(trait_data, "displayLabel")
	
	if trait_data.has("dialogue"):
		for message_dict in trait_data["dialogue"]:
			var new_msg = DialogueMessage.new(message_dict["message"])
			
			# I admit that this is sort of terrible code vvv
			_add_response(new_msg, message_dict["responses"], "good")
			_add_response(new_msg, message_dict["responses"], "bad")
			new_trait.messages.append(new_msg)
	
	# iterate through appearance modifiers, register, and request modification indices
	if trait_data.has("appearance"):
		for appearance_dict in trait_data["appearance"]:
			assert(appearance_dict.has("layer") and appearance_dict.has("texPath"))
			var appearance_modifier = sprite_bakery.request_appearance_modifier(
				appearance_dict["layer"],
				appearance_dict["texPath"]
			)
			
			new_trait.trait_appearance_modifiers.append(appearance_modifier)
	
	# new_trait._test_print_data()
	return new_trait

static func _add_response(msg, response_dict, response_type_label):
	var response_type = RESPONSE_GOOD if response_type_label == "good" else RESPONSE_BAD
	var response_text = "%sResponse" % response_type_label
	var npc_response_text = "%sResponseText" % response_type_label
	
	msg.add_response(
		response_type,
		response_dict[response_text],
		response_dict[npc_response_text]
	)

static func _value_if_key_exists(dict : Dictionary, key, error_on_failure : bool = false):
	if !dict.has(key):
		assert(!error_on_failure, "Failed to find key in dictionary!")
		return null
	
	return dict[key]

func _test_print_data():
	print("PRINTING TRAIT: ")
	print("name: %s\ndisplayLabel: %s\ndescription: %s\n" % [name, displayLabel, description])
	
	print("Responses: ")
	for message in messages:
		print(message._responses)
	print("DONE PRINTING TRAIT")
	
func get_config_errors():
	return null

class DialogueMessage extends RefCounted:
	
	var message = ""
	var length : int:
		get:
			return message.length()
	
	var _responses = [null, null]
	
	func _init(messageText):
		message = messageText
	
	func add_response(response_type, response_text, npc_response_text):
		print("Adding response %s && %s" % [response_text, npc_response_text])
		_responses[response_type] = [response_text, npc_response_text]
	
	func get_response(response_type):
		return _responses[response_type]
