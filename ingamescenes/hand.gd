extends HBoxContainer

const CARD_SCENE = preload("res://card.tscn")
@export var all_cards: Array[CardData]

func _ready() -> void:
	randomize()
	add_to_group("Hand") 
	Turns.turn_changed.connect(_on_turn_changed)
	display_random_cards(4)

func display_random_cards(amount: int) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
		
	if all_cards.is_empty(): 
		return
		
	var deck_pool = all_cards.duplicate()
	deck_pool.shuffle()
	
	for i in range(min(amount, deck_pool.size())):
		var card_data = deck_pool[i]
		var new_card = CARD_SCENE.instantiate()
		new_card.data = card_data
		add_child(new_card)

func hide_other_cards(played_card: Node) -> void:
	for card in get_children():
		if card != played_card:
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(card, "modulate:a", 0.0, 0.25)
			tween.tween_property(card, "scale", Vector2(0.8, 0.8), 0.25)

func show_all_cards() -> void:
	for card in get_children():
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(card, "modulate:a", 1.0, 0.3)
		tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.3)

func _on_turn_changed(_is_player_turn: bool) -> void:
	pass

func shuffle_and_draw_one() -> void:
	if all_cards.is_empty():
		return
		
	for child in get_children():
		remove_child(child)
		child.queue_free()  
		
	await get_tree().process_frame
	
	var random_card_data = all_cards.pick_random()
	var new_card = CARD_SCENE.instantiate()
	new_card.data = random_card_data
	add_child(new_card)
	
	new_card.modulate.a = 1.0
	new_card.scale = Vector2(1.0, 1.0)

	print("Shuffle: Τραβήχτηκε 1 νέα τυχαία κάρτα: ", random_card_data)
