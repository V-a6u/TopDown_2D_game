extends Area2D


export var goldToGive : int = 100

#give gold to player
func on_interact (player):
	player.give_gold(goldToGive)
	queue_free()
