extends Control
@onready var info_dialog: AcceptDialog = $AcceptDialog
func _process(delta: float) -> void:
	t()
	if Input.is_action_just_pressed("click"):
		$AudioStreamPlayer.play()
func _ready() -> void:
	$".".hide()
func resume():
	get_tree().paused =false
	$".".hide()

func pause():
	get_tree().paused = true
	$".".show()

func t():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()


func _on_button_4_pressed() -> void:
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
	resume()
