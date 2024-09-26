class_name CharacterDialogue
extends TextureRect

# node/scene references
@onready var close_button : Button = $CloseButton
@onready var name_label : Label = $Dialogue/VSplitContainer/NameLabel
@onready var dialogue_box : Label = $Dialogue/VSplitContainer/DialogueBox
@onready var npc_portrait : TextureRect = $HBoxContainer/NPCCharacterPortrait

@onready var responses_container : VBoxContainer = $MarginContainer/Responses
@onready var good_response : Button = $MarginContainer/Responses/GoodResponse
@onready var bad_response : Button = $MarginContainer/Responses/BadResponse

@onready var post_scroll_timer : Timer = $PostScrollTimer

@onready var sprite_bakery : CharacterSpriteBakery = $/root/Systems/CharacterSpriteBakery


enum {
	BAD_RESPONSE,
	GOOD_RESPONSE
}
#public member variables

#private member variables
var _current_message : Trait.DialogueMessage = null
var _time_per_character : float = 0
var _message_text : String = ""
var _message_index : int = 0
var _next_character_timer : float = 0
var _delay_tick : float = 0

var _flag_exit = false
var _exit_response_type = BAD_RESPONSE

# signals
signal picked_good_reponse()
signal picked_bad_response()
signal window_closed()


func _ready():
	close_button.pressed.connect(_on_close_button_pressed)
	post_scroll_timer.timeout.connect(_handle_post_dialogue)
	
	var default_image = load("res://Resources/Textures/Characters/Base/skin2.png")
	npc_portrait.texture = ImageTexture.create_from_image(default_image)

func set_message_delay(time : float):
	_delay_tick = time

func display_message_timed(message : Trait.DialogueMessage, time : float):
	reset_message_state()
	

	_current_message = message
	scroll_text_timed(message.message, time)
	
	good_response.text = message.get_response(Trait.RESPONSE_GOOD)[Trait.PLAYER_RESPONSE_TEXT]
	bad_response.text = message.get_response(Trait.RESPONSE_BAD)[Trait.PLAYER_RESPONSE_TEXT]

func scroll_text_timed(message_text, time, delay = 0.0):
	_time_per_character = time / message_text.length();
	_message_text = message_text
	set_message_delay(delay)
	
	_message_index = 0
	_next_character_timer = 0
	dialogue_box.text = ""

func portrait_from_npc(npc : NPCCharacter):
	
	npc_portrait.texture = sprite_bakery.request_character_texture(CharacterSpriteBakery.MODE_PORTRAIT, npc, npc_portrait.texture)
	

func reset_message_state():
	_current_message = null
	_time_per_character = 0
	_message_text = ""
	_message_index = 0
	
	dialogue_box.text = ""
	responses_container.visible = false
	_flag_exit = false
	
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
			
			if _message_index == _message_text.length():
				post_scroll_timer.start(1)


func _handle_post_dialogue():
	if !_flag_exit:
		responses_container.visible = true
	elif _exit_response_type == BAD_RESPONSE:
		picked_bad_response.emit()
	else:
		picked_good_reponse.emit()


func _on_close_button_pressed():
	reset_message_state()
	_toggle_visibility()
	window_closed.emit()

func _toggle_visibility():
	visible = !visible

func _is_running_message():
	return _message_index < _message_text.length()

func _set_exit_status(response_type):
	_flag_exit = true
	_exit_response_type = response_type
	#TODO: set the appropriate signal to be dispatched when flagged

func _on_bad_response_pressed():
	responses_container.visible = false;
	
	_set_exit_status(BAD_RESPONSE)
	scroll_text_timed(_current_message.get_response(Trait.RESPONSE_BAD)[Trait.NPC_RESPONSE_TEXT], 2.0, 1.2)
	window_closed.emit()
func _on_good_response_pressed():
	responses_container.visible = false;
	
	_set_exit_status(GOOD_RESPONSE)
	scroll_text_timed(_current_message.get_response(Trait.RESPONSE_GOOD)[Trait.NPC_RESPONSE_TEXT], 2.0, 1.2)
