class_name CharacterDialogue
extends TextureRect

# node/scene references
@onready var close_button : Button = $CloseButton
@onready var name_label : Label = $Dialogue/VSplitContainer/NameLabel
@onready var dialogue_box : Label = $Dialogue/VSplitContainer/DialogueBox


#public member variables

#private member variables
var _current_message = null
var _time_per_character : float = 0
var _message_text : String = ""
var _message_index : int = 0
var _next_character_timer : float = 0
var _delay_tick : float = 0

func set_message_delay(time : float):
	_delay_tick = time

func display_message_timed(message, time : float):
	reset_message_state()
	
	_current_message = message
	_time_per_character = time / message.length;
	_message_text = message.message

func portrait_from_npc(npc : NPCCharacter):
	print("NPC Has traits: %s, %s, and %s" % [npc.traits[0].name, npc.traits[1].name, npc.traits[2].name])
	pass

func reset_message_state():
	_current_message = null
	_time_per_character = 0
	_message_text = ""
	_message_index = 0
	
	dialogue_box.text = ""

func _ready():
	close_button.pressed.connect(_on_close_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _delay_tick > 0:
		_delay_tick -= delta
		return
	
	if _is_running_message():
		_next_character_timer += delta
		if _next_character_timer >= _time_per_character:
			dialogue_box.text += _message_text[_message_index]
			
			_message_index += 1
			_next_character_timer = 0

func _on_close_button_pressed():
	reset_message_state()
	_toggle_visibility()

func _toggle_visibility():
	visible = !visible

func _is_running_message():
	return _message_index < _message_text.length()
