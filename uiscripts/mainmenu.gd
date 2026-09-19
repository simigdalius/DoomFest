extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		$AudioStreamPlayer.play()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://uiScenes/story.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://uiScenes/info.tscn")


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://uiScenes/credits.tscn")
