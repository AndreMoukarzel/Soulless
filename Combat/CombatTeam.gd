extends Node2D

signal all_acted() # All units were selected as next actor in this iteration

const BODYSIZE = 0.7
const SWAPTIME = 0.3
const FLEETIME = 1.0
const POSVAR = 20

var act_queue = []


func populate(all_units, invert_interface):
	randomize()
	for u in all_units:
		var u_scn = load("res://Characters/" + u + "/" + u + ".tscn")
		var unit = u_scn.instance()
		unit.set_HPBar(invert_interface)
		add_child(unit)
	
	set_all_positions()

func set_all_positions():
	var center = Vector2(-OS.get_window_size().x/4, OS.get_window_size().y/2)
	var units = get_all_units()
	var i = 0
	
	for u in units:
		var y = (randi() % 2 * POSVAR) - POSVAR
		u.set_position(center + Vector2(i * 200, y))
		i += 1
		

func swap(Unit1, Unit2):
	var allUnits = get_children()
	allUnits.pop_front() # Discards Tween node
	
	var unit_index1 = allUnits.find(Unit1)
	var unit_index2 = allUnits.find(Unit2)

	if unit_index1 == -1 or unit_index2 == -1:
		print("ERROS: UNIT NOT FOUND IN TEAM")
		return

	move_child(Unit1, unit_index2 + 1) # +1 in indexes is so Tween node remains in correct relative position
	move_child(Unit2, unit_index1 + 1)

	var Twn = get_node("Tween")
	var pos1 = Unit1.get_position()
	var pos2 = Unit2.get_position()

	Unit1.set_z_index(5)
	Unit2.set_z_index(10)
	Twn.interpolate_property(Unit1, "position", pos1, pos2, SWAPTIME, 4, 2)
	Twn.interpolate_property(Unit2, "position", pos2, pos1, SWAPTIME, 4, 2)
	Unit1.play_animation("walk")
	Unit2.play_animation("walk")
	Twn.start()
	yield(Twn, "tween_completed")
	Unit1.play_animation("idle")
	Unit2.play_animation("idle")
	Unit1.set_z_index(0)
	Unit2.set_z_index(0)

# Removes unit from all data
# Animates unit's escape
# Does not consider if unit is captain or not
func flee(Unit):
	var Unit_index = get_children().find(Unit)
	
	if Unit_index == -1: # not found
		return 0
	
	var Twn = get_node("Tween")
	var pos = Unit.get_position()
	Unit.get_node("HPBar").queue_free()
	Unit.HP = 0 # "Kills" the unit to keep consistence in battle_ended() function in Combat.gd
	Twn.interpolate_property(Unit, "position", pos, Vector2(1000, pos.y), FLEETIME, Tween.TRANS_LINEAR, Tween.EASE_IN)
	Unit.flee()
	Twn.start()
	yield(Twn, "tween_completed")
	get_children()[Unit_index].queue_free()

####################### GETTERS #######################
# All "unit" getters return an array

# Search for next unit that will act
func get_next_actor():
	if act_queue.empty():
		act_queue = get_idle_units()
	var actor = act_queue.pop_front()
	if act_queue.empty():
		emit_signal("all_acted") # signals for team change in combat
		
	return actor

func get_all_units():
	var all = get_children()
	all.pop_front()
	
	return all

func get_front_unit():
	return [get_all_units().pop_front()]

func get_idle_units():
	var idle = []
	
	for u in get_all_units():
		if u.HP >= 0: # ignores dead and stunned units
			idle.append(u)
	
	return idle

func get_alive_units():
	var alive = []
	
	for u in get_all_units():
		if u.HP > 0: # ignores dead and stunned units
			alive.append(u)
	
	return alive

func get_dead_units():
	var dead = []
	
	for u in get_all_units():
		if u.HP <= 0:
			dead.append(u)
	
	return dead

func get_unit_pos(unit_id):
	var pos = get_node(str(unit_id)).get_position()
	
	if self.get_name() == "Allies":
		# Scene's scale is (-1, 1)
		pos.x = -pos.x
	pos += self.get_position()
	
	return pos
