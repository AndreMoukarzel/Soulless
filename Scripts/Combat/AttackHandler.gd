extends Node

signal attack_finished

const WALKTIME = 0.6

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
	
	var twn = get_node("Tween")
	var pos_origin = atk_node.get_position()
	var pos_destiny = pos_origin - target_node.get_position()
	
	pos_destiny.x -= target_team.get_position().x + pos_origin.x - 50
	if atk_info[1] == "Enemies":
		pos_destiny.x -= atk_team.get_position().x
	pos_destiny.y = pos_origin.y - pos_destiny.y
	
	twn.interpolate_property(atk_node, "position", pos_origin, pos_destiny, WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	atk_node.get_node("AnimationPlayer").play("walk")
	twn.start()
	yield(twn, "tween_completed")
	
	# Only for testing #
	atk_node.get_node("AnimationPlayer").play("idle")
	var value = define_damage(attacker, target)
	target.hp -= value
	create_damage(value, target_team.get_unit_pos(target.id))
	if target.hp <= 0:
		target_node.get_node("AnimationPlayer").play("die")
	####################
	
	twn.interpolate_property(atk_node, "position", pos_destiny, pos_origin, WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	atk_node.get_node("AnimationPlayer").play("walk")
	twn.start()
	yield(twn, "tween_completed")
	atk_node.get_node("AnimationPlayer").play("idle")
	
	emit_signal("attack_finished")


func define_damage(attacker, target):
	var damage = attacker.atk[0] - target.def[0]
	
	if damage < 0:
		damage = 1 
	
	return damage


func create_damage(value, pos):
	var dmg = dmg_scn.instance()
	
	dmg.get_node("Label").set_text(str(value))
	dmg.set_position(pos)
	get_parent().get_node("CanvasLayer").add_child(dmg)
	yield(dmg.get_node("AnimationPlayer"), "animation_finished")
	dmg.queue_free()