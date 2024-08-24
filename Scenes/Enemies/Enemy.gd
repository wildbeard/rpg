extends Character
class_name Enemy

signal start_battle(enemies: Array[Enemy])

const ITEMS = preload("res://Resources/Items.tres")

func generateRewards() -> Dictionary:
	# @TODO: Generate gold based on level
	var gold: int = 25
	var item: Item = getRandomItemReward()

	return {
		'gold': gold,
		'item': item,
	}

func getRandomItemReward() -> Item:
	return ITEMS.resource_list.filter(func(item: Item): return item.name != 'Coins').pick_random() as Item
