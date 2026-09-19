extends Node2D

@onready var label: Label = $Label

func _ready() -> void:
	$AnimatedSprite2D.hide()

func setup(value: int, is_heal: bool = false) -> void:
	if is_heal:
		$AnimatedSprite2D.show()
		$AnimatedSprite2D.play("default")
		label.text = "+" + str(value)
		label.modulate = Color.GREEN
	else:
		$AnimatedSprite2D.show()
		$AnimatedSprite2D.play("default")
		label.text = "-" + str(value)
		label.modulate = Color.RED

	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(self, "position:y", position.y - 40.0, 0.9)\
		 .set_trans(Tween.TRANS_CUBIC)\
		 .set_ease(Tween.EASE_OUT)
	
	# 2. Fade out (γίνεται διαφανές στο τέλος)
	tween.tween_property(self, "modulate:a", 0.0, 0.9)\
		 .set_trans(Tween.TRANS_LINEAR)\
		 .set_ease(Tween.EASE_IN)
	
	await tween.finished
	queue_free()
