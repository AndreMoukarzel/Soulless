
static func choose_action(activeUnit, Allies, Enemies): # the AI controls the Enemies, obviously
	var targetable = Allies.get_alive_units()
	var i = find_weakest_unit(targetable)
	
	return [activeUnit.Signature1, targetable[i]]


func find_weakest_unit(Units):
	var weakest = Units[0]
	var weakest_val = weakest.HP + weakest.DEF * 0.5
	
	for U in Units:
		var u_val = U.HP + U.DEF * 0.5
		if weakest_val > u_val:
			weakest = U
			weakest_val = u_val
	
	return Units.find(weakest)