class_name NPCDialogueSystem
extends Node

# node/scene references
@onready var dialogue_ui : CharacterDialogue = $/root/MainScene/CanvasLayer/Dialogue

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
		pass
	
	var chosen_trait = _unrevealed_traits.pop_at(randi_range(0, remaining_traits - 1))
	
	# pick a random message from that trait
	return chosen_trait.messages[randi_range(0, chosen_trait.messages.size() - 1)]
	
func _bind_npc_info(npc : NPCCharacter):
	_current_npc = npc
	_unrevealed_traits.append_array(npc.traits)
	dialogue_ui.portrait_from_npc(npc)
