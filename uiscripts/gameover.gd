extends Control


@onready var final_score_label: Label = $Label2

func _ready() -> void:
	final_score_label.text = "Final Score: " + str(EventBus.final_score)
	checkscore()


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://uiScenes/mainmenu.tscn")


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://ingamescenes/arena.tscn")

func checkscore():
	if EventBus.final_score <50:
		$Panel2/Label2.text = str("with that score you do not deserve no resurrection")
	elif EventBus.final_score <100:
		$Panel2/Label2.text = str("Eh.. could have been better")
	else:
		$Panel2/Label2.text = str("... wait what.... how  you deserve the reseruction everyone who passes in front of you will think only 2 words imminent doom")
