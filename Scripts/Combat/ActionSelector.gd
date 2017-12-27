
extends Node2D

export var DEBUG = 0

const SPINSPD = 0.3
const HORDIST = 50
const VERDIST = 80
var POSCENTER = Vector2( HORDIST, 0 )
var POSTOP = Vector2( 0, -VERDIST )
var POSBOT = Vector2( 0, VERDIST )
var POSTOPOC = Vector2( -HORDIST * 0.4, -VERDIST * 1.3 )
var POSBOTOC = Vector2( -HORDIST * 0.4, VERDIST * 1.3 )

signal selected(name) # Selected action
signal changed_to(name) # Highlighted action changed

var hl = 0 # highlighted action
var shl = 0 # submenu highlighted action
var action_num = 0
var actions = []
var skills = []
var in_skills = false


func _input(event):
	if not in_skills:
		if event.is_action_pressed("ui_up"):
			change_action(-1)
		elif event.is_action_pressed("ui_down"):
			change_action(1)
		
		if event.is_action_pressed("ui_accept"):
				if actions[hl] == "Skills":
					open_skills_submenu()
				else:
					emit_signal("selected", actions[hl])
					if DEBUG:
						print ("Selected ", actions[hl])
						
	else: # In skills submenu
		if event.is_action_pressed("ui_up"):
			change_skill(-1)
		elif event.is_action_pressed("ui_down"):
			change_skill(1)
		
		if event.is_action_pressed("ui_accept"):
			close_skills_submenu()
			emit_signal("selected", skills[shl])
			if DEBUG:
				print ("Selected ", skills[shl])
		elif event.is_action_pressed("ui_cancel"): # Equivalent to selecting "Back"
			if in_skills:
				close_skills_submenu()


func update_actions(action_list, skill_list):
	action_num = action_list.size()
	actions = action_list
	hl = 0
	print(action_list) # test
	
	relable()
	
	get_node("ActionCenter").set_position(POSCENTER)
	get_node("ActionTop").set_position(POSTOP)
	get_node("ActionBot").set_position(POSBOT)
	get_node("ActionTopOcult").set_position(POSTOPOC)
	get_node("ActionBotOcult").set_position(POSBOTOC)
	
	update_skills(skill_list)


func update_skills(skill_list):
	skills = skill_list
	shl = 0
	
	var i = 0
	for skill in skill_list:
		var skill_node = get_node(str("SkillsSubmenu/Skill", i, "/Node2D"))
		
		skill_node.get_node("Name").set_text(skill)
		
		i += 1
	
	for j in range(3):
		var node = get_node(str("SkillsSubmenu/Skill", j))
		
		if j > i - 1:
			node.hide()
		else:
			node.show()


func enable():
	set_process_input(true)
	show()


func disable():
	set_process_input(false)
	hide()


func relable():
	get_node("ActionCenter/Label").set_text(actions[hl])
	get_node("ActionTop/Label").set_text(actions[(hl + 1) % action_num])
	get_node("ActionTopOcult/Label").set_text(actions[(hl + 2) % action_num])
	
	if hl - 1 < 0:
		get_node("ActionBot/Label").set_text(actions[action_num - 1])
	else:
		get_node("ActionBot/Label").set_text(actions[hl - 1])
		
	if hl - 2 < 0:
		get_node("ActionBotOcult/Label").set_text(actions[action_num + (hl - 2)])
	else:
		get_node("ActionBotOcult/Label").set_text(actions[hl - 2])


func spin(add):
	var twn = get_node("Tween")
	var center = get_node("ActionCenter")
	var top = get_node("ActionTop")
	var bot = get_node("ActionBot")
	var top_oc = get_node("ActionTopOcult")
	var bot_oc = get_node("ActionBotOcult")
	
	set_process_input(false)
	
	if add == 1: # Spin Down
		twn.interpolate_property(center, "position", POSCENTER, POSBOT, SPINSPD, 0, 2)
		twn.interpolate_property(top, "position", POSTOP, POSCENTER, SPINSPD, 0, 2)
		twn.interpolate_property(bot, "position", POSBOT, POSBOTOC, SPINSPD, 0, 2)
		twn.interpolate_property(bot, "modulate",Color(1, 1, 1, 1), Color(1, 1, 1, 0), SPINSPD, 0, 2)
		twn.interpolate_property(top_oc, "position", POSTOPOC, POSTOP, SPINSPD, 0, 2)
		twn.interpolate_property(top_oc, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), SPINSPD, 0, 2)

		twn.start()
		
		center.set_name("temp")
		top.set_name("ActionCenter")
		top_oc.set_name("ActionTop")
		bot_oc.set_name("ActionTopOcult")
		bot.set_name("ActionBotOcult")
		center.set_name("ActionBot")
	else: # Spin Up
		twn.interpolate_property(center, "position", POSCENTER, POSTOP, SPINSPD, 0, 2)
		twn.interpolate_property(top, "position", POSTOP, POSTOPOC, SPINSPD, 0, 2)
		twn.interpolate_property(top, "modulate",Color(1, 1, 1, 1), Color(1, 1, 1, 0), SPINSPD, 0, 2)
		twn.interpolate_property(bot, "position", POSBOT, POSCENTER, SPINSPD, 0, 2)
		twn.interpolate_property(bot_oc, "position", POSBOTOC, POSBOT, SPINSPD, 0, 2)
		twn.interpolate_property(bot_oc, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), SPINSPD, 0, 2)

		twn.start()
		
		center.set_name("temp")
		bot.set_name("ActionCenter")
		bot_oc.set_name("ActionBot")
		top_oc.set_name("ActionBotOcult")
		top.set_name("ActionTopOcult")
		center.set_name("ActionTop")
	
	yield(twn, "tween_completed")
	set_process_input(true)
	
	relable()


func change_action(add):
	if add == 1:
		hl = (hl + 1) % action_num
	else:
		hl -= 1
		if hl < 0:
			hl = action_num - 1
	spin(add)
	emit_signal("changed_to", actions[hl])
	if DEBUG:
		print ("Changed_to ", actions[hl])


func change_skill(add):
	get_node(str("SkillsSubmenu/Skill", shl, "/AnimationPlayer")).play("idle")
	shl = (shl + add) % skills.size()
	if shl < 0:
		shl = skills.size() - 1
	get_node(str("SkillsSubmenu/Skill", shl, "/AnimationPlayer")).play("highlight")


func open_skills_submenu():
	if skills.size() == 0:
		# Unit has no skills
		return 0
	
	in_skills = true
	get_node(str("SkillsSubmenu/Skill", shl, "/AnimationPlayer")).play("highlight")
	get_node("SkillsSubmenu").show()


func close_skills_submenu():
	in_skills = false
	get_node(str("SkillsSubmenu/Skill", shl, "/AnimationPlayer")).play("idle")
	get_node("SkillsSubmenu").hide()
