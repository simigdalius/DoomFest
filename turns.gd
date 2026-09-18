extends Node

signal turn_changed(is_player_turn)

enum Turn { PLAYER, ENEMY }
var current_turn: Turn = Turn.PLAYER

var cards_allowed_this_turn: int = 1
var cards_played_this_turn: int = 0

func is_player_turn() -> bool:
	return current_turn == Turn.PLAYER

func start_player_turn() -> void:
	current_turn = Turn.PLAYER
	cards_allowed_this_turn = 1 # Reset σε 1 κάρτα ανά γύρο
	cards_played_this_turn = 0
	turn_changed.emit(true)
	print("Γύρος Παίκτη!")

func end_player_turn() -> void:
	current_turn = Turn.ENEMY
	turn_changed.emit(false)
	print("Γύρος Αντιπάλου!")

func card_played() -> void:
	cards_played_this_turn += 1
	if cards_played_this_turn >= cards_allowed_this_turn:
		end_player_turn()

func start_new_battle() -> void:
	EventBus.enemy_spawned.emit()
	start_player_turn()
