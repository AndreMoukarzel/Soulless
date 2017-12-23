extends Node2D

signal all_acted() # All units were selected as next actor in this iteration

var TOPMARGIN = 200
var BOTMARGIN = 100
var HORMARGIN = 200

onready var unit_db = get_node("/root/Units")

var captain = null
var cap_index = 0 # captain pos in array
var units = []
var acted = []
var unit_num = 0


func populate(all_units, captain_id):
	for u in all_units:
		if u == null:
			units.append(null)
		else:
			unit_num += 1
			units.append(u)
			unit_db.instance_body(u.name, self, Vector2(0, 0), str(u.id))
	captain = captain_id
	get_cap_index()
	set_all_positions()


func set_all_positions():
	var center = Vector2(-OS.get_window_size().x/4, (OS.get_window_size().y - TOPMARGIN - BOTMARGIN)/2 + TOPMARGIN/2)
	
	# Talvez tenha q add a TOPMARGIN e remover a BOTMARGIN de todos
	if units[0] != null: # Unit in the back collum
		get_node(str(units[0].id)).set_position(Vector2(-HORMARGIN, center.y))
		get_node(str(units[0].id)).set_scale(Vector2(1, 1))
	if units[1] != null: # Top
		get_node(str(units[1].id)).set_position(Vector2(center.x * 0.6 - HORMARGIN, center.y/2))
		get_node(str(units[1].id)).set_scale(Vector2(0.95, 0.95))
	if units[2] != null: # Mid
		get_node(str(units[2].id)).set_position(Vector2(center.x * 0.8 - HORMARGIN, center.y))
		get_node(str(units[2].id)).set_scale(Vector2(1, 1))
	if units[3] != null: # Bot
		get_node(str(units[3].id)).set_position(Vector2(center.x * 0.6 - HORMARGIN, center.y * 1.5))
		get_node(str(units[3].id)).set_scale(Vector2(1.05, 1.05))


func get_cap_index():
	for i in range(units.size()):
		if units[i] == null:
			continue
		if units[i].id == captain:
			cap_index = i


# Search for next unit, from captain, that has not acted yet
func get_next_actor():
	for i in range(cap_index, cap_index + units.size()):
		var unit_id = units[i % units.size()].id
		if unit_id == null:
			continue
		if not unit_id in acted: # found unit
			acted.append(unit_id)
			if acted.size() == unit_num:
				emit_signal("all_acted")
				acted = []
			return units[i % units.size()]


func get_targetable_units():
	var all = []
	
	for i in range(1, units.size()):
		if units[i] != null and units[i].hp > 0:
			all.append(units[i])
	
	if all.size() < 1: # No units in the front row
		all.append(units[0]) # Unit in the back is targetable
	
	return all


func get_all_units():
	var all = []
	
	for u in units:
		if u != null and u.hp > 0:
			all.append(u)
	
	return all


func get_dead_units():
	var all = []
	
	for u in units:
		if u != null and u.hp <= 0:
			all.append(u)
	
	return all


func swap(unit_id1, unit_id2):
	var i1 = -1
	var i2 = -1
	
	for i in range(units.size()):
		if units[i] == null:
			continue
		
		if units[i].id == unit_id1:
			i1 = i
		elif units[i].id == unit_id2:
			i2 = i
	
	if i1 == -1 or i2 == -1:
		print("ERROS: UNIT NOT FOUND IN TEAM")
		return
	
	var temp = units[i1]
	units[i1] = units[i2]
	units[i2] = temp
	get_cap_index()
	set_all_positions()
