extends Node2D

@onready var info_dialog: AcceptDialog = $AcceptDialog

func _ready() -> void:
	info_dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	
	info_dialog.confirmed.connect(resume)
	info_dialog.canceled.connect(resume)

func _process(_delta: float) -> void:
	$npc1.play("default")
	$npc2.play("default")
	if Input.is_action_just_pressed("click"):
		$AudioStreamPlayer.play()

func resume() -> void:
	get_tree().paused = false

func pause() -> void:
	get_tree().paused = true

func _on_button_2_pressed() -> void:
	pause() 
	info_dialog.popup_centered() 
