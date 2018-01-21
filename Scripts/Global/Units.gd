
extends Node

const NAME = 0
const RACE = 1
const ATR = 2
const BASEATK = 3
const SKILLS = 4
const SIZE = 5


class Unit:
	var name
	var race
	var size
	var hp
	var hp_max
	var attributes = []
	var baseatk = []
	var skills = []


var unit_database = [
	{ # ID = 0
		NAME : "Bunny",
		RACE : "Kobold",
		ATR : [3, 1, 10], # [ATK, DEF, HP]
		BASEATK : "Bounce",
		SKILLS : [],
		SIZE : 0.7
	},
	{ # ID = 1
		NAME : "Soulless",
		RACE : "Soulless",
		ATR : [5, 5, 5], # [ATK, DEF, HP]
		BASEATK : "Bounce",
		SKILLS : ["Pounce", "Swiggity Swoogity"],
		SIZE : 1.5
	}
]

################# DATABASE HANDLING #################
var u_map = { }

func _ready():
	for id in range (unit_database.size()):
		u_map[unit_database[id][NAME]] = id

func get_unit_id(unit_name):
	return u_map[unit_name]

func get_unit_name(id):
	return unit_database[id][NAME]

func get_unit_race(id):
	return unit_database[id][RACE]

func get_unit_attributes(id):
	return unit_database[id][ATR]

func get_unit_baseatk(id):
	return unit_database[id][BASEATK]

func get_unit_skills(id):
	return unit_database[id][SKILLS]

func get_unit_size(id):
	return unit_database[id][SIZE]


################## CLASS HANDLING ##################
func new_unit(unit_name):
	var id = get_unit_id(unit_name)
	var u = Unit.new()
	var actions = []
	
	u.name = unit_name
	u.size = get_unit_size(id)
	u.race = get_unit_race(id)
	u.attributes = get_unit_attributes(id)
	u.baseatk = get_unit_baseatk(id)
	u.skills = get_unit_skills(id)
	
	return u


################# VISUAL HANDLING #################
func instance_body(unit_name, parent, pos, obj_name):
	var body_scn = load("res://Scenes/Body.tscn")
	var body = body_scn.instance()
	var id = get_unit_id(unit_name)
	var size = get_unit_size(id)
	var attacks = [get_unit_baseatk(id)]
	attacks += get_unit_skills(id)

	body.define_unit(unit_name, attacks) # Sets correct sprites, animations, sounds...
	body.set_scale(Vector2(size, size))
	body.set_position(pos)
	body.set_name(str(obj_name))
	parent.add_child(body)

	return body