extends Node

var current_weakness: Resource = null 
signal weakness_changed(new_weakness)
# Enemy Signals
signal enemy_healed(amount: int)
signal enemy_attacked(amount: int)
signal enemy_spawned

# Player Signals
signal player_attacked(damage: int, element_id: int)
signal player_healed(amount: int)
signal player_buffed(stat_name: String, amount: int)
signal turn_started

#camera tzoub tzoub
signal tzoub(shake:int, float)

#pop
signal pop(amount: int, pos: Vector2, is_heal: bool)


signal game_over

var final_score: int = 0

func update_score(new_score: int) -> void:
	final_score = new_score

var buff_attack_turns: int = 0
var buff: bool = false
