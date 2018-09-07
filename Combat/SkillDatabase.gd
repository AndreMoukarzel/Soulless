extends Node

const NAME = 0
const TYPE = 1
const ARGUMENTS = 2 # Arguments change depending on the TYPE of skill
const DESCRIPTION = 3 # Info that shows while player is hovering over the skill in ActionSelector

# ARGUMENTS #
# TimedHit: An array of float values. Each float is the time of a hit (could be a multi-hit attack).

var skill_database = [
	{
		NAME : "Kick",
		TYPE : "TimedHit",
		ARGUMENTS : [0.5],
		DESCRIPTION : "I like trains"
	},
	{
		NAME : "Wait",
		TYPE : null,
		ARGUMENTS : null,
		DESCRIPTION : "Wait until your next turn"
	},
	{
		NAME : "Swap",
		TYPE : null,
		ARGUMENTS : null,
		DESCRIPTION : "Swap places with a buddy, so they can take the beating for you!"
	},
	{
		NAME : "Flee",
		TYPE : null,
		ARGUMENTS : null,
		DESCRIPTION : "Run for it! Has a chance to fail..."
	},
	{
		NAME : "Item",
		TYPE : null,
		ARGUMENTS : null,
		DESCRIPTION : "Lol this doesn't even exist yet."
	}
]

################# DATABASE HANDLING #################
var s_map = { }

func _ready():
	for id in range (skill_database.size()):
		s_map[skill_database[id][NAME]] = id

func get_skill_id(skill_name):
	if s_map.has(skill_name):
		return s_map[skill_name]
	else:
		return -1

func get_skill_name(id):
	return skill_database[id][NAME]

func get_skill_type(id):
	return skill_database[id][TYPE]

func get_skill_arguments(id):
	return skill_database[id][ARGUMENTS]

func get_skill_description(id):
	return skill_database[id][DESCRIPTION]