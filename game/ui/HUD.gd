extends CanvasLayer

onready var pause_screen = get_node("PauseScreen")
onready var death_screen = get_node("DeathScreen")
onready var label_score = get_node("LabelScore")
onready var animator_score = get_node("LabelScore/AnimationPlayer")
onready var label_wave = get_node("LabelWave")

var pause_screen_deactivated = false

func _ready():
	death_screen.connect("change_visibility", self, "_on_DeathScreen_change_visibility")

func _on_score_changed(score, bonus=false):
	label_score.text = str(int(score))
	
	if bonus:
		animator_score.play("bonus")

func _on_wave_changed(wave):
	label_wave.text = str(wave)
	
	if wave == -1:
		label_wave.text = "EXTRA"

func _on_DeathScreen_change_visibility(visible):
	if visible:
		pause_screen.set_process_input(false)
	else:
		pause_screen.set_process_input(true)