class_name GameHUD
extends Control


@onready var stamina_bar : ProgressBar = $PanelContainer/StaminaBar/ProgressBar
@onready var time_label : RichTextLabel = $Time/RichTextLabel
@onready var date_label : Label = $DateTracker/Label

@onready var game_master : GameMasterSystem = $/root/Systems

# Called when the node enters the scene tree for the first time.

var _flash_seconds = 0

func _ready():
	pass # Replace with function body.


func timer_flash_alert(seconds: float):
	_flash_seconds = seconds
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	stamina_bar.value = game_master.player.stamina / game_master.player.max_stamina
	stamina_bar.self_modulate = Color.FIREBRICK if game_master.player._flag_no_sprint else Color.GREEN_YELLOW
	
	var elapsed = int(game_master.timer.time_left)
	var seconds = elapsed % 60
	var minutes = elapsed / 60
	
	var text = "%02d:%02d" % [minutes, seconds]
	
	#handle flashing if needed
	if _flash_seconds > 0:
		text = "[color=red]%02d:%02d[/color]" % [minutes, seconds]
		
		time_label.rotation = sin(_flash_seconds * 10) * 0.25
		_flash_seconds -= delta
	
	time_label.clear()
	time_label.append_text(text)
	
	date_label.text = "Dates: %d/%d" % [game_master.dates_counter, game_master.DATES_REQUIRED]

func update_preferred_traits(traits : Array[Trait]):
	var preferences_list = $PanelContainer2/VBoxContainer/ItemList
	preferences_list.clear()
	for t in traits:
		preferences_list.add_item(t.displayLabel)
