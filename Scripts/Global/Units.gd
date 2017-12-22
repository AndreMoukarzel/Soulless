
extends Node

const NAME = 0
const RACE = 1
const ATR = 2
const SKILLS = 3


class Unit:
	var name
	var hp
	var hp_max
	var attributes = []
	var skills = []


var unit_database = [
	{ # ID = 0
		NAME : "Auau",
		RACE : "Kobold",
		ATR : [3, 1, 10], # [ATK, DEF, HP]
		SKILLS : ["Bite", "Defense", "Swap", "Flee"]
	},
	{ # ID = 1
		NAME : "Soulless",
		RACE : "Soulless",
		ATR : [0, 0, 0], # [ATK, DEF, HP]
		SKILLS : ["Scratch", "Pounce", "Swap", "Defense", "Flee"]
	}
]

################# DATABASE HANDLING #################
var u_map = { }

func _ready():
	for id in range (unit_database.size()):
		u_map[unit_database[id][NAME]] = id

func get_unit_id(name):
	return u_map[name]

func get_unit_name(id):
	return unit_database[id][NAME]

func get_unit_race(id):
	return unit_database[id][RACE]

func get_unit_attributes(id):
	return unit_database[id][ATR]

func get_unit_skills(id):
	return unit_database[id][SKILLS]


################## CLASS HANDLING ##################
func new_unit(name):
	var id = get_unit_id(name)
	var u = Unit.new()
	
	u.name = name
	u.attributes = get_unit_attributes(id)
	u.skills = get_unit_skills(id)
	
	return u


################# VISUAL HANDLING #################
func instance_body(unit_name, parent, pos, obj_name):
	var body_scn = load("res://Scenes/Body.tscn")
	var body = body_scn.instance()
	var id = get_unit_id(unit_name)

	body.define_unit(unit_name, get_unit_race(id)) # Sets correct sprites, animations, sounds...
	body.set_position(pos)
#	body.set_scale(Vector2(1, 1) * get_unit_size(id))
	body.set_name(str(obj_name))
	parent.add_child(body)

	return body