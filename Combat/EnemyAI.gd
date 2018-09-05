
static func choose_action(activeUnit, Allies, Enemies): # the AI controls the Enemies, obviously
	var targetable = Allies.get_alive_units()
	
	var i = randi() % targetable.size()
	return ["Attack", targetable[i]]