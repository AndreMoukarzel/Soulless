
static func choose_action(active_unit, allies, enemies, allies_leader_index, enemies_leader_index): # of course, the AI controls the enemies
	if active_unit.hp <= 0:
		return null
	
	var targetable = []
	
	for i in range(1, allies.size()):
		if allies[i] != null and allies[i].hp > 0:
			targetable.append(i)
	if targetable.size() < 1: # Unit in the back is targetable
		targetable.append(0)
	
	if allies_leader_index in targetable:
		return ["Attack", allies[allies_leader_index]]
	else:
		var i = randi() % targetable.size()
		return ["Attack", get_unit(targetable[i], allies)]


static func get_unit(unit_id, unit_array):
	for u in unit_array:
		if u != null:
			if u.id == unit_id:
				return u 