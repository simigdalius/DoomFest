extends Node2D
var floating_text_scene = preload("res://ingamescenes/popup.tscn")
@export var max_hp: int = 100
var current_hp: int = 100

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	EventBus.enemy_healed.connect(_on_enemy_healed)
	EventBus.enemy_attacked.connect(_on_enemy_attack)
	EventBus.enemy_spawned.connect(_on_enemy_spawned)
	EventBus.player_attacked.connect(_on_player_attacked)
	
	sprite.play("default")
	set_initial_color()

func set_initial_color() -> void:
	var random_r: float = randf_range(0.5, 1.0)
	var random_g: float = randf_range(0.5, 1.0)
	var random_b: float = randf_range(0.5, 1.0)
	
	sprite.modulate = Color(random_r, random_g, random_b, 1.0)

func _on_enemy_spawned() -> void:
	current_hp = max_hp 
	sprite.play("default")
	apply_random_color_with_tween()

func apply_random_color_with_tween() -> void:
	var random_r: float = randf_range(0.5, 1.0)
	var random_g: float = randf_range(0.5, 1.0)
	var random_b: float = randf_range(0.5, 1.0)
	
	var new_color = Color(random_r, random_g, random_b, 1.0)
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", new_color, 0.3)

func reset_enemy_stats() -> void:
	show()
	_on_enemy_spawned()

func _on_player_attacked(damage: int, element_id: int) -> void:
	var final_damage = damage
	if EventBus.current_weakness and element_id == EventBus.current_weakness.weakness:
		final_damage *= 2
		print("SUPER EFFECTIVE HIT! Damage: ", final_damage)

	current_hp = clamp(current_hp - final_damage, 0, max_hp)
	print("Enemy HP: ", current_hp)
	
	if current_hp <= 0:
		_on_enemy_death()
	else:
		$AudioStreamPlayer2.play()
		sprite.play("dmg")
		var tween = create_tween()
		tween.tween_property(sprite, "position:x", sprite.position.x - 10, 0.05)
		tween.tween_property(sprite, "position:x", sprite.position.x, 0.05)
		await sprite.animation_finished
		sprite.play("default")

func _on_enemy_death() -> void:
	print("Ο εχθρός πέθανε!")
	$AudioStreamPlayer2.play()
	sprite.play("death")
	EventBus.tzoub.emit(15, 0.4)
	var tween = create_tween()
	tween.tween_property(sprite, "position:x", sprite.position.x - 20, 0.1)
	tween.tween_property(sprite, "position:x", sprite.position.x, 0.1)
	
	await sprite.animation_finished
	EventBus.enemy_spawned.emit()

func _on_enemy_healed(amount: int) -> void:
	print("Ο εχθρός δέχθηκε θεραπεία: ", amount)
	$AudioStreamPlayer.play()
	sprite.play("health")
	current_hp = clamp(current_hp - amount, 0, max_hp)
	EventBus.tzoub.emit(4, 0.4)
	var tween = create_tween()
	tween.tween_property(sprite, "position:x", sprite.position.x - 0.1, 0.1)
	tween.tween_property(sprite, "position:x", sprite.position.x, 0.1)
	await sprite.animation_finished
	sprite.play("default")

func _on_enemy_attack(amount: int) -> void:
	print("Ο εχθρός έκανε επίθεση με damage: ", amount)
	$AudioStreamPlayer2.play()
	sprite.play("attack")
	EventBus.tzoub.emit(15, 0.4)
	var tween = create_tween()
	tween.tween_property(sprite, "position:x", sprite.position.x - 20, 0.1)
	tween.tween_property(sprite, "position:x", sprite.position.x, 0.1)
	await sprite.animation_finished
	sprite.play("default")
