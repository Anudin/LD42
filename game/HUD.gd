extends CanvasLayer

onready var main = get_node("/root/Main")
onready var label_score = $LabelScore
onready var animator_score = $LabelScore/AnimationPlayer
onready var label_wave = $LabelWave

func _ready():
	main.connect("score_changed", self, "_on_score_changed")
	main.connect("wave_changed", self, "_on_wave_changed")

func _on_score_changed(score):
	label_score.text = str(int(score))
	animator_score.play("bonus")

func _on_wave_changed(wave):
	label_wave.text = str(wave)
	
	if wave == -1:
		label_wave.text = "EXTRA"