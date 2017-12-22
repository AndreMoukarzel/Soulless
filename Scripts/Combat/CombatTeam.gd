extends Node2D

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
			units.append(u.id)
			unit_db.instance_body(u.name, self, Vector2(0, 0), str(u.id))
	captain = captain_id
	get_cap_index()
	set_all_positions()


func set_all_positions():
	var center = Vector2(-OS.get_window_size().x/4, (OS.get_window_size().y - TOPMARGIN - BOTMARGIN)/2 + TOPMARGIN/2)
	
	# Talvez tenha q add a TOPMARGIN e remover a BOTMARGIN de todos
	if units[0] != null: # Unit in the back collum
		get_node(str(units[0])).set_position(Vector2(-HORMARGIN, center.y))
	if units[1] != null: # Top
		get_node(str(units[1])).set_position(Vector2(center.x * 0.6 - HORMARGIN, center.y/2))
		get_node(str(units[1])).set_scale(Vector2(0.95, 0.95))
	if units[2] != null: # Mid
		get_node(str(units[2])).set_position(Vector2(center.x * 0.8 - HORMARGIN, center.y))
	if units[3] != null: # Bot
		get_node(str(units[3])).set_position(Vector2(center.x * 0.6 - HORMARGIN, center.y * 1.5))
		get_node(str(units[3])).set_scale(Vector2(1.05, 1.05))


func get_cap_index():
	for i in range(units.size()):
		if units[i] == null:
			continue
		if units[i] == captain:
			cap_index = i


func get_next_actor():
	# Search for next unit, from captain, that has not acted yet
	for i in range(cap_index, cap_index + units.size()):
		var unit_id = units[i % units.size()]
		if unit_id == null:
			continue
		if not unit_id in acted: # found unit
			acted.append(unit_id)
			if acted.size() == unit_num:
				acted = []
			return unit_id


func swap(unit_id1, unit_id2):
	var i1 = -1
	var i2 = -1
	
	for i in range(units.size()):
		if units[i] == null:
			continue
		
		if units[i] == unit_id1:
			i1 = i
		elif units[i] == unit_id2:
			i2 = i
	
	if i1 == -1 or i2 == -1:
		print("ERROS: UNIT NOT FOUND IN TEAM")
		return
	
	var temp = units[i1]
	units[i1] = units[i2]
	units[i2] = temp
	get_cap_index()
	set_all_positions()