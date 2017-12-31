extends Node

# atk_info is [Attacker, Attacker's Team, Target, Target's Team]
func attack(atk_info, skill_info):
	var attacker = atk_info[0]
	var atk_team = get_parent().get_node(str(atk_info[1]))
	var atk_node = atk_team.get_node(str(attacker.id))
	# Before getting target, we must check in skill_info if the skill is actually multi-target
	var target = atk_info[2]
	var target_team = get_parent().get_node(str(atk_info[3]))
	var target_node = target_team.get_node(str(target.id))
	
	# Only for testing #
	target.hp -= (attacker.atk[0] - target.def[0])
	####################