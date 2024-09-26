class_name NPCDialogueSystem
extends Node

# node/scene references
@onready var dialogue_ui : CharacterDialogue = $CanvasLayer/Dialogue
@onready var game_master : GameMasterSystem = $/root/Systems

@export var message_scroll_time : float = 2.0

#private variables
var _current_npc : NPCCharacter = null
var _unrevealed_traits : Array[Trait] = []


func _on_npc_interacted(npc : NPCCharacter):
	if !dialogue_ui.visible:
		dialogue_ui.visible = true
		_bind_npc_info(npc) # this sets up the NPC appearance and prepares messages/traits for dialogue
		dialogue_ui.set_message_delay(1.2) # this delays dialogue display by n seconds
		
		var message = _pick_random_message() # picks a random message to display
		dialogue_ui.display_message_timed(message, message_scroll_time) #displays message via scrolling text, within n seconds.

func _pick_random_message():
	var remaining_traits = _unrevealed_traits.size()
	if remaining_traits <= 0:
		return null
	
	var chosen_trait = _unrevealed_traits.pop_at(randi_range(0, remaining_traits - 1))
	print("Showing message from: " + chosen_trait.displayLabel)
	
	# pick a random message from that trait
	return chosen_trait.messages[randi_range(0, chosen_trait.messages.size() - 1)]
	
func _bind_npc_info(npc : NPCCharacter):
	_current_npc = npc
	_unrevealed_traits.append_array(npc.traits)
	dialogue_ui.portrait_from_npc(npc)

func _unbind_npc():
	_current_npc = null
	_unrevealed_traits.clear()
func _on_dialogue_picked_bad_response():
	dialogue_ui.visible = false
	_unbind_npc()
	# TODO: Evaluate the outcome of the dialogue and update game state accordingly

func _check_correct_person():
	var preferred_traits = game_master.preferred_traits
	var npc_traits = _current_npc.traits
	
	if preferred_traits.size() != npc_traits.size():
		return false
	
	for t in npc_traits:
		if preferred_traits.count(t) == 0:
			return false
	return true

func _on_dialogue_picked_good_reponse():
	var next_trait_message = _pick_random_message()
	if next_trait_message:
		dialogue_ui.set_message_delay(1.2)
		dialogue_ui.display_message_timed(next_trait_message, message_scroll_time)
	else:
		dialogue_ui.visible = false
		if _check_correct_person():
			game_master.add_successful_date()
		else:
			game_master.time_penalty(15)
		_unbind_npc()

func _on_dialogue_window_closed():
	_unbind_npc()
