extends CanvasLayer

onready var pause_logic = $PauseLogic
var pause_logic_deactivated = false
onready var death_screen_logic = $DeathScreenLogic
onready var label_score = $LabelScore
onready var animator_score = $LabelScore/AnimationPlayer
onready var label_wave = $LabelWave

func _ready():
	if OS.get_name() == "HTML5":
		$PauseLogic/ExitHint.visible = false

func _process(delta):
	if pause_logic_deactivated and not death_screen_logic.visible:
		pause_logic.set_process_input(true)
		pause_logic_deactivated = false

func _on_player_died():
	pause_logic.set_process_input(false)
	pause_logic_deactivated = true

func _on_score_changed(score, bonus=false):
	label_score.text = str(int(score))
	
	if bonus:
		animator_score.play("bonus")

func _on_wave_changed(wave):
	label_wave.text = str(wave)
	
	if wave == -1:
		label_wave.text = "EXTRA"