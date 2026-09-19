extends Control

@export var max_hp: int = 100
var current_hp: int = 100

@onready var health_bar = $Panel4/front
@onready var buff: TextureRect = $TextureRect

func _ready() -> void:
	$Panel.hide()
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	
	if buff:
		buff.hide()
	
	EventBus.player_healed.connect(_on_player_healed)
	EventBus.enemy_attacked.connect(_on_enemy_attacked)
	

func _process(_delta: float) -> void:
	if buff and buff.visible and EventBus.buff_attack_turns <= 0:
		buff.hide()
	if EventBus.buff== true:
		$Panel.show()
		var tween = create_tween()
		tween.tween_property(buff, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(buff, "scale", Vector2(1.0, 1.0), 0.1)
	if EventBus.buff== false:
		$Panel.hide()
		var tween = create_tween()
		tween.tween_property(buff, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(buff, "scale", Vector2(1.0, 1.0), 0.1)

func _on_player_healed(amount: int) -> void:
	current_hp = clamp(current_hp + amount, 0, max_hp)
	
	var tween = create_tween()
	tween.tween_property(health_bar, "value", current_hp, 0.4)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)

func _on_enemy_attacked(amount: int) -> void:
	current_hp = clamp(current_hp - amount, 0, max_hp)
	
	var tween = create_tween()
	tween.tween_property(health_bar, "value", current_hp, 0.3)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)
	
	print("Player HP: ", current_hp)

	
	
