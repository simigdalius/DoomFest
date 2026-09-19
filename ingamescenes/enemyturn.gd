extends HBoxContainer

const ENEMY_MOVE_SCENE = preload("res://ingamescenes/enemymove.tscn")
var floating_text_scene = preload("res://ingamescenes/popup.tscn")
signal enemy_healed(amount: int)
signal enemy_attacked(amount: int)
signal enemy_slept(amount: int)

@export var possible_moves: Array[EnemyMove]

func _ready() -> void:
	Turns.turn_changed.connect(_on_turn_changed)
	EventBus.pop.connect(_on_pop_requested)

func _on_turn_changed(is_player_turn: bool) -> void:
	if not is_player_turn:
		play_enemy_turn()

func play_enemy_turn() -> void:
	print("Σειρά του εχθρού: Ξεκινάει ο κουλοχέρης!")
	
	clear_current_moves()
	
	await start_rotation_sequence()
	
	$froutakia.play("run")
	$"../Timer".start()
	$AudioStreamPlayer2.play()
	
	await $"../Timer".timeout
	$AudioStreamPlayer2.stop()
	await generate_random_moves(3)

	await get_tree().create_timer(1.0).timeout
	Turns.start_player_turn()

func generate_random_moves(amount: int) -> void:
	if possible_moves.size() == 0:
		return

	var total_health: int = 0
	var total_attack: int = 0

	for i in range(amount):
		var random_move: EnemyMove = possible_moves.pick_random()
		
		var new_move_node = ENEMY_MOVE_SCENE.instantiate()
		new_move_node.data = random_move
		
		new_move_node.modulate.a = 0.0
		new_move_node.scale = Vector2(0.2, 0.2)
		new_move_node.pivot_offset = new_move_node.size / 2.0
		$AudioStreamPlayer.play()
		add_child(new_move_node)
		
		if random_move.health > 0:
			total_health += random_move.health
		if random_move.attack > 0:
			total_attack += random_move.attack
			
		print("Εχθρός Roll ", i + 1, ": ", random_move.resource_path)
		
		EventBus.tzoub.emit(7, 0.4)
		var tween = create_tween().set_parallel(true)
		tween.tween_property(new_move_node, "modulate:a", 1.0, 0.2)
		tween.tween_property(new_move_node, "scale", Vector2(1.0, 1.0), 0.3)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)

		await tween.finished
		await get_tree().create_timer(0.15).timeout

	if total_health > 0:
		var final_health = 0
		if total_health==1:
			final_health=10
		elif total_health==2:
			final_health=20
		elif total_health==3:
			final_health=35
		print("Πρόσθεση ", final_health, " health στον εχθρό!")
		EventBus.pop.emit(final_health, Vector2(730, 230), true)
		EventBus.enemy_healed.emit(final_health)
	if total_attack > 0:
		var final_damage = 0
		if total_attack == 1:
			final_damage = 10
		elif total_attack == 2:
			final_damage = 20
		elif total_attack >= 3:
			final_damage = 35
			
		print("Επίθεση εχθρού για ", final_damage, " dmg!")
		EventBus.pop.emit(final_damage, Vector2(430, 230), false)
		EventBus.enemy_attacked.emit(final_damage)
		
func clear_current_moves() -> void:
	for child in get_children():
		if child is Control and child != $froutakia and child != $kouloxeris:
			child.queue_free()

func start_rotation_sequence() -> void:
	var tween = create_tween()
	tween.tween_property($kouloxeris, "rotation_degrees", -30.0, 0.2)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)

	tween.tween_property($kouloxeris, "rotation_degrees", 30.0, 0.15)\
		 .set_trans(Tween.TRANS_QUAD)\
		 .set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property($kouloxeris, "rotation_degrees", 0.0, 0.1)\
		 .set_trans(Tween.TRANS_BOUNCE)\
		 .set_ease(Tween.EASE_OUT)
	
	await tween.finished

func _on_timer_timeout() -> void:
	if not Turns.is_player_turn():
		$froutakia.play("flash")

func _on_pop_requested(amount: int, pos: Vector2, is_heal: bool) -> void:
	var pop = floating_text_scene.instantiate()
	get_tree().root.add_child(pop)
	pop.global_position = pos
	pop.z_index = 100
	pop.setup(amount, is_heal)
