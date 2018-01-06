extends Node2D

signal all_acted() # All units were selected as next actor in this iteration

const BODYSIZE = 0.7
const SWAPTIME = 0.3
var TOPMARGIN = 600
var BOTMARGIN = -200
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
		var unit = get_node(str(units[0].id))
		unit.set_position(Vector2(-HORMARGIN, center.y))
		unit.set_scale(BODYSIZE * Vector2(units[0].size, units[0].size))
	if units[1] != null: # Top
		var unit = get_node(str(units[1].id))
		unit.set_position(Vector2(center.x * 0.6 - HORMARGIN, center.y/2))
		unit.set_scale(0.90 * BODYSIZE * Vector2(units[1].size, units[1].size))
		unit.set_z(-3)
	if units[2] != null: # Mid
		var unit = get_node(str(units[2].id))
		unit.set_position(Vector2(center.x * 0.8 - HORMARGIN, center.y))
		unit.set_scale(BODYSIZE * Vector2(units[2].size, units[2].size))
	if units[3] != null: # Bot
		var unit = get_node(str(units[3].id))
		unit.set_position(Vector2(center.x * 0.6 - HORMARGIN, center.y * 1.5))
		unit.set_scale(1.1 * BODYSIZE * Vector2(units[3].size, units[3].size))
		unit.set_z(3)


func get_cap_index():
	for i in range(units.size()):
		if units[i] == null:
			continue
		if units[i].id == captain:
			cap_index = i


# Search for next unit, from captain, that has not acted yet
func get_next_actor():
	for i in range(cap_index, cap_index + units.size()):
		if units[i % units.size()] == null:
			continue
			
		var unit_id = units[i % units.size()].id
		
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


func get_unit_pos(unit_id):
	var pos = get_node(str(unit_id)).get_position()
	
	if self.get_name() == "Allies":
		# Scene's scale is (-1, 1)
		pos.x = -pos.x
	pos += self.get_position()
	
	return pos


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
	
	var twn = get_node("Tween")
	var u1 = get_node(str(unit_id1))
	var u2 = get_node(str(unit_id2))
	var pos1 = u1.get_position()
	var pos2 = u2.get_position()
	
	u1.set_z(5)
	u2.set_z(5)
	twn.interpolate_property(u1, "position", pos1, pos2, SWAPTIME, 4, 2)
	twn.interpolate_property(u2, "position", pos2, pos1, SWAPTIME, 4, 2)
	twn.start()
	u1.set_z(0)
	u2.set_z(0)
	set_all_positions()


# Removes unit from all data
# Animates unit's escape
# Does not consider if unit is captain or not
func flee(unit_id):
	var found = false
	
	for i in range(units.size()):
		if units[i] == null:
			continue
		
		if units[i].id == unit_id:
			units[i] = null
			found = true
			unit_num -= 1
			break
	
	if not found:
		return 0
	
	var unit_node = get_node(str(unit_id))
	var twn = get_node("Tween")
	var pos = unit_node.get_position()
	var i = acted.find(unit_id)
	
	get_node(str(unit_id, "/AnimationPlayer")).play("walk")
	unit_node.set_scale(unit_node.get_scale() * Vector2(-1, 1))
	if i != -1:
		acted.remove(i)
	twn.interpolate_property(unit_node, "position", pos, Vector2(1000, pos.y), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	twn.start()
