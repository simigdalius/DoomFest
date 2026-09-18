extends Control

@export var posibleweaknes: Array[EnemyWeakness]
@export var max_hp: int = 100
var current_hp: int = 100

@onready var health_bar = $Panel4/front
@onready var weakness_icon: TextureRect = $TextureRect


func _ready() -> void:
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	
	# Σύνδεση σημάτων
	EventBus.enemy_healed.connect(_on_enemy_healed)
	EventBus.enemy_spawned.connect(_on_enemy_spawned)
	EventBus.player_attacked.connect(_on_player_attacked)
	
	_on_enemy_spawned()

func _on_enemy_spawned() -> void:
	current_hp = max_hp
	health_bar.value = current_hp
	
	if posibleweaknes.is_empty():
		print("WARNING: Η λίστα posibleweaknes είναι άδεια στον Inspector!")
		return
		
	EventBus.current_weakness = posibleweaknes.pick_random()
	
	if weakness_icon and EventBus.current_weakness:
		weakness_icon.texture = EventBus.current_weakness.texture
		weakness_icon.position = Vector2(930, 184)
		weakness_icon.custom_minimum_size = Vector2(64, 64)
		weakness_icon.show()
		
		print("Weakness icon loaded successfully: ", EventBus.current_weakness.resource_path)

func _on_player_attacked(damage: int, element_id: int) -> void:
	var final_damage = damage
	if EventBus.current_weakness and element_id == EventBus.current_weakness.weakness:
		final_damage *= 2
		
	current_hp = clamp(current_hp - final_damage, 0, max_hp)
	
	var tween = create_tween()
	tween.tween_property(health_bar, "value", current_hp, 0.3)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)

func _on_enemy_healed(amount: int) -> void:
	current_hp = clamp(current_hp + amount, 0, max_hp)
	var tween = create_tween()
	tween.tween_property(health_bar, "value", current_hp, 0.9)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)
