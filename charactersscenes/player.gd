extends Node2D

@export var max_hp: int = 100
var current_hp: int = 100
var base_attack_power: int = 10
var attack_power: int = 10

var buff_attack_turns: int = 0
var extra_cards_next_turn: int = 0

var max_plays_this_turn: int = 1
var plays_remaining: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("Player") 
	
	EventBus.player_healed.connect(_on_healed)
	EventBus.player_buffed.connect(_on_buffed)
	EventBus.player_attacked.connect(_on_player_attack)
	Turns.turn_changed.connect(_on_turn_changed)
	EventBus.enemy_attacked.connect(_on_take_damage)
	
	sprite.play("default")

func _on_buffed(buff_type: int) -> void:
	sprite.play("buff")
	EventBus.tzoub.emit(4, 0.4)
	
	var tween = create_tween()
	tween.tween_property(sprite, "position:x", sprite.position.x + 5.0, 0.1)
	tween.tween_property(sprite, "position:x", sprite.position.x, 0.1)
	
	match buff_type:
		1: 
			print("Buff: Shuffle Hand!")
			var hand = get_tree().get_first_node_in_group("Hand")
			if hand:
				print("Hand found in group!")
				if hand.has_method("shuffle_and_draw_one"):
					hand.shuffle_and_draw_one()
				else:
					print("ERROR: Hand missing 'shuffle_and_draw_one' method!")
			else:
				print("ERROR: Hand node NOT found in group 'Hand'!")
		2: 
			print("Buff: Joker! +1 επιπλέον ενέργεια/κάρτα στον επόμενο γύρο.")
			extra_cards_next_turn += 1
		3:
			print("Buff: +10 Attack Power για 2 γύρους!")
			buff_attack_turns = 2
			attack_power = base_attack_power + 10
			
	tween.finished.connect(func(): sprite.play("default"))

# 1. Θεραπεία Παίκτη
func _on_healed(amount: int) -> void:
	sprite.play("health")
	EventBus.tzoub.emit(4, 0.4)
	
	current_hp = clamp(current_hp + amount, 0, max_hp)
	print("Ο Παίκτης θεραπεύτηκε κατά: ", amount, " | Νέο HP: ", current_hp)
	
	var tween = create_tween()
	tween.tween_property(sprite, "position:x", sprite.position.x + 5.0, 0.1)
	tween.tween_property(sprite, "position:x", sprite.position.x, 0.1)
	
	await sprite.animation_finished
	sprite.play("default")
# 2. Επίθεση Παίκτη
func _on_player_attack(damage: int, _element_id: int) -> void:
	sprite.play("attack")
	EventBus.tzoub.emit(15, 0.4)
	var tween = create_tween()
	tween.tween_property(sprite, "position:x", sprite.position.x + 20.0, 0.1)
	tween.tween_property(sprite, "position:x", sprite.position.x, 0.1)
	
	await tween.finished
	sprite.play("default")

# 3. Λήψη Ζημιάς
func _on_take_damage(damage: int) -> void:
	if damage <= 0:
		return
		
	current_hp = clamp(current_hp - damage, 0, max_hp)
	print("Player HP: ", current_hp, " / ", max_hp, " (Took ", damage, " damage)")
	
	if current_hp <= 0:
		_on_player_death()
	else:
		sprite.play("dmg")
		await sprite.animation_finished
		sprite.play("default")

# 4. Αλλαγή Γύρου
func _on_turn_changed(is_player_turn: bool) -> void:
	if is_player_turn:
		if buff_attack_turns > 0:
			buff_attack_turns -= 1
			if buff_attack_turns == 0:
				attack_power = base_attack_power
				print("Attack Buff έληξε!")
		max_plays_this_turn = 1 + extra_cards_next_turn
		plays_remaining = max_plays_this_turn
		
		if extra_cards_next_turn > 0:
			print("Joker Buff Ενεργό! Μπορείς να παίξεις ", max_plays_this_turn, " κάρτες αυτόν τον γύρο.")
			extra_cards_next_turn = 0 
		var hand = get_tree().get_first_node_in_group("Hand")
		if hand:
			hand.display_random_cards(4)
			hand.show_all_cards()

# Στο player.gd
func on_card_played() -> void:
	plays_remaining -= 1
	print("Κάρτες που απομένουν για αυτόν τον γύρο: ", plays_remaining)
	
	if plays_remaining <= 0:
		print("Τέλειωσαν οι ενέργειες. Τέλος γύρου παίκτη.")
		Turns.end_player_turn()
	else:
		print("Μπορείς να παίξεις κι άλλη κάρτα! Επανεμφάνιση καρτών.")
		var hand = get_tree().get_first_node_in_group("Hand")
		if hand and hand.has_method("show_all_cards"):
			hand.show_all_cards()

# 6. Θάνατος Παίκτη
func _on_player_death() -> void:
	print("Game Over! Ο Παίκτης ηττήθηκε.")
	sprite.play("death")
	EventBus.tzoub.emit(15, 0.4)
	var tween = create_tween()
	tween.tween_property(sprite, "position:x", sprite.position.x - 20.0, 0.1)
	tween.tween_property(sprite, "position:x", sprite.position.x, 0.1)
	
	await sprite.animation_finished
	get_tree().change_scene_to_file("res://uiScenes/gameover.tscn")
