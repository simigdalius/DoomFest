extends Node2D

var total_value: int = 0

func _ready() -> void:
	$SCORE.play("default")
	EventBus.enemy_spawned.connect(_on_enemy_spawned)

func _process(delta: float) -> void:
	pass

func _on_enemy_spawned() -> void:
	var random_add: int = randi_range(20, 30)
	total_value += random_add
	$Label2.text = str(total_value)
	EventBus.update_score(total_value)
	animate_score_bump()

func animate_score_bump() -> void:
	var tween: Tween = create_tween()
	
	var original_y: float = position.y
	var shake_intensity: float = 8.0  
	var shake_count: int = 4          
	var step_duration: float = 0.04  
	
	for i in range(shake_count):
		var direction: float = 1.0 if i % 2 == 0 else -1.0
		var current_offset: float = direction * shake_intensity * (1.0 - float(i) / shake_count)
		
		tween.tween_property(self, "position:y", original_y + current_offset, step_duration)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
			
	tween.tween_property(self, "position:y", original_y, step_duration)
	
