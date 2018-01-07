
static func choose_action(active_unit, allies, enemies, allies_leader, enemies_leader): # of course, the AI controls the enemies
	if active_unit.hp <= 0:
		return null
	
	var back_free = true  # back unit is the only one alive
	var targetable = []
	
	for i in range(1, 4):
		if allies[i] != null and allies[i].hp > 0:
			back_free = false
			targetable.append(i)
	if back_free:
		targetable.append(0)
	
	if allies_leader in targetable:
		return ["Attack", get_unit(allies_leader, allies)]
	else:
		var i = randi() % targetable.size()
		return ["Attack", get_unit(targetable[i], allies)]


static func get_unit(unit_id, unit_array):
	for u in unit_array:
		if u != null:
			if u.id == unit_id:
				return u 