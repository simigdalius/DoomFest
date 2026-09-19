extends Control


@onready var final_score_label: Label = $Label2

func _ready() -> void:
	final_score_label.text = "Final Score: " + str(EventBus.final_score)
	checkscore()
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		$AudioStreamPlayer.play()

func _on_button_2_pressed() -> void:
	get_tree().paused = false
	
	var tweens = get_tree().get_processed_tweens()
	for t in tweens:
		if t and t.is_valid():
			t.kill()
	get_tree().call_group("popups", "queue_free")
	EventBus.reset_all_states()
	Turns.reset_all_turns()
	get_tree().change_scene_to_file("res://uiScenes/mainmenu.tscn")

func _on_button_3_pressed() -> void:
	get_tree().paused = false
	
	var tweens = get_tree().get_processed_tweens()
	for t in tweens:
		if t and t.is_valid():
			t.kill()
	get_tree().call_group("popups", "queue_free")
	EventBus.reset_all_states()
	Turns.reset_all_turns()
	get_tree().change_scene_to_file("res://ingamescenes/arena.tscn")

func checkscore():
	if EventBus.final_score <50:
		$Panel2/Label2.text = str("With that score, you don't deserve any resurrection!")
	elif EventBus.final_score <100:
		$Panel2/Label2.text = str("Eh... could have been better.")
	else:
		$Panel2/Label2.text = str("...Wait, what? How? You deserve resurrection!")
		$Panel2/Label3.text = str(" Everyone who passes by you will think only two words: ")
		$Panel2/Label4.text = str("Imminent Doom")
