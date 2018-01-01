extends Node

onready var dmg_scn = preload("res://Scenes/Combat/Damage.tscn")

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
	var value = attacker.atk[0] - target.def[0]
	target.hp -= value
	create_damage(value, target_team.get_unit_pos(target.id))
	####################


func create_damage(value, pos):
	var dmg = dmg_scn.instance()
	
	dmg.get_node("Label").set_text(str(value))
	dmg.set_position(pos)
	get_parent().get_node("CanvasLayer").add_child(dmg)
	yield(dmg.get_node("AnimationPlayer"), "animation_finished")
	dmg.queue_free()