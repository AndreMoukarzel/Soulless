
extends Node

const NAME = 0
const TYPE = 1
const ATKTIME = 2
const DEFTIME = 3

var skill_database = [
	{ # ID = 0
		NAME : "Bounce",
		TYPE : "BonusDmg",
		ATKTIME : 0.5,
		DEFTIME : 0.5
	}
]

################# DATABASE HANDLING #################
var s_map = { }

func _ready():
	for id in range (skill_database.size()):
		s_map[skill_database[id][NAME]] = id

func get_skill_id(skill_name):
	return s_map[skill_name]

func get_skill_name(id):
	return skill_database[id][NAME]

func get_skill_type(id):
	return skill_database[id][TYPE]

func get_skill_atktime(id):
	return skill_database[id][ATKTIME]

func get_skill_deftime(id):
	return skill_database[id][DEFTIME]