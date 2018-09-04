extends Node2D

signal all_acted() # All units were selected as next actor in this iteration

const BODYSIZE = 0.7
const SWAPTIME = 0.3
var TOPMARGIN = 600
var BOTMARGIN = -100
var HORMARGIN = 200

var act_queue = []


func populate(all_units, invert_interface):
	for u in all_units:
		var u_scn = load("res://Characters/" + u + "/" + u + ".tscn")
		var unit = u_scn.instance()
		unit.set_HpBar(invert_interface)
		add_child(unit)
	
	set_all_positions()


func set_all_positions():
	var center = Vector2(-OS.get_window_size().x/4, (OS.get_window_size().y - TOPMARGIN - BOTMARGIN)/2 + TOPMARGIN/2)
	var units = get_all_units()
	var i = 0
	
	for u in units:
		u.set_position(center + Vector2(i * 200, 0))
		i += 1


# Search for next unit that will act
func get_next_actor():
	if act_queue.empty():
		act_queue = get_idle_units()
	
	return act_queue.pop_front()


#func get_targetable_units():
#	var all = []
#
#	for i in range(1, units.size()):
#		if units[i] != null and units[i].hp > 0:
#			all.append(units[i])
#
#	if all.size() < 1: # No units in the front row
#		all.append(units[0]) # Unit in the back is targetable
#
#	return all


func get_all_units():
	var all = get_children()
	all.pop_front()
	
	return all

func get_idle_units():
	var idle = []
	
	for u in get_all_units():
		if u.HP >= 0: # ignores dead and stunned units
			idle.append(u)
	
	return idle

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


#func swap(unit_id1, unit_id2):
#	var i1 = -1
#	var i2 = -1
#
#	for i in range(units.size()):
#		if units[i] == null:
#			continue
#
#		if units[i].id == unit_id1:
#			i1 = i
#		elif units[i].id == unit_id2:
#			i2 = i
#
#	if i1 == -1 or i2 == -1:
#		print("ERROS: UNIT NOT FOUND IN TEAM")
#		return
#
#	var temp = units[i1]
#	units[i1] = units[i2]
#	units[i2] = temp
#	get_cap_index()
#
#	var twn = get_node("Tween")
#	var u1 = get_node(str(unit_id1))
#	var u2 = get_node(str(unit_id2))
#	var pos1 = u1.get_position()
#	var pos2 = u2.get_position()
#
#	u1.set_z_index(35)
#	u2.set_z_index(40)
#	twn.interpolate_property(u1, "position", pos1, pos2, SWAPTIME, 4, 2)
#	twn.interpolate_property(u2, "position", pos2, pos1, SWAPTIME, 4, 2)
#	twn.start()
#	set_all_positions()


# Removes unit from all data
# Animates unit's escape
# Does not consider if unit is captain or not
#func flee(unit_id):
#	var found = false
#
#	for i in range(units.size()):
#		if units[i] == null:
#			continue
#
#		if units[i].id == unit_id:
#			units[i] = null
#			found = true
#			unit_num -= 1
#			break
#
#	if not found:
#		return 0
#
#	var unit_node = get_node(str(unit_id))
#	var twn = get_node("Tween")
#	var pos = unit_node.get_position()
#	var i = acted.find(unit_id)
#
#	get_node(str(unit_id, "/AnimationPlayer")).play("walk")
#	unit_node.set_scale(unit_node.get_scale() * Vector2(-1, 1))
#	if i != -1:
#		acted.remove(i)
#	twn.interpolate_property(unit_node, "position", pos, Vector2(1000, pos.y), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
#	twn.start()


func damage(value, unit, animation = null):
	var hp_bar = get_node(str(unit.id)).get_node("HPBar")
	var anim = get_node(str(unit.id)).get_node("AnimationPlayer")
	var label = hp_bar.get_node("Label")
	var twn = hp_bar.get_node("Tween")
	
	if animation:
		anim.play(animation)
	else:
		anim.play("hit")
	unit.hp -= value
	twn.interpolate_property(hp_bar, "value", hp_bar.get_value(), unit.hp, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	twn.start()
	label.set_text(str(max(unit.hp, 0), "/", unit.hp_max))
	
	yield(anim, "animation_finished")
	get_node(str(unit.id)).get_node("AnimationPlayer").play("idle")
	if unit.hp <= 0:
		get_node(str(unit.id)).get_node("AnimationPlayer").play("die")
