extends Control
@onready var info_dialog: AcceptDialog = $AcceptDialog

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
	get_tree().change_scene_to_file("res://uiScenes/mainmenu.tscn")


func _on_button_3_pressed() -> void:
	resume()


func _on_button_2_pressed() -> void:
	info_dialog.popup_centered()

func _process(delta: float) -> void:
	t()
