
extends Node2D

export var DEBUG = 0

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
var action_num = 2
var actions = []
var skills = []


func _input(event):
	if event.is_action_pressed("ui_up"):
		change_action(-1)
	elif event.is_action_pressed("ui_down"):
		change_action(1)
	
	if event.is_action_pressed("ui_accept"):
		emit_signal("selected", actions[hl])
		if DEBUG:
			print ("Selected ", actions[hl])
	elif event.is_action_pressed("ui_cancel"): # Equivalent to selecting "Back"
		pass


func relable():
	get_node("ActionCenter/Label").set_text(actions[hl])
	get_node("ActionTop/Label").set_text(actions[(hl + 1) % action_num])
	
	if hl - 1 < 0:
		get_node("ActionBot/Label").set_text(actions[action_num - 1])
	else:
		get_node("ActionBot/Label").set_text(actions[hl - 1])
		
	if hl - 2 < 0:
		if action_num - 2 < 0:
			get_node("ActionTopOcult/Label").set_text(actions[action_num - 1])
		else:
			get_node("ActionTopOcult/Label").set_text(actions[action_num - 2])
	else:
		get_node("ActionTopOcult/Label").set_text(actions[hl - 2])
		
	get_node("ActionBotOcult/Label").set_text(actions[(hl + 2) % action_num])


func update_actions(action_list, skill_list):
	action_num = action_list.size()
	actions = action_list
	
	relable()
	
	get_node("ActionCenter").set_position(POSCENTER)
	get_node("ActionTop").set_position(POSTOP)
	get_node("ActionBot").set_position(POSBOT)
	get_node("ActionTopOcult").set_position(POSTOPOC)
	get_node("ActionBotOcult").set_position(POSBOTOC)


func enable():
	set_process_input(true)
	show()


func disable():
	set_process_input(false)
	hide()


func spin(add):
	var twn = get_node("Tween")
	var center = get_node("ActionCenter")
	var top = get_node("ActionTop")
	var bot = get_node("ActionBot")
	var top_oc = get_node("ActionTopOcult")
	var bot_oc = get_node("ActionBotOcult")
	
	if add == 1: # Spin Down
		twn.interpolate_property(center, "position", POSCENTER, POSBOT, 0.4, 0, 2)
		twn.interpolate_property(top, "position", POSTOP, POSCENTER, 0.4, 0, 2)
		twn.interpolate_property(bot, "position", POSBOT, POSBOTOC, 0.4, 0, 2)
		twn.interpolate_property(bot, "modulate",Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.4, 0, 2)
		twn.interpolate_property(top_oc, "position", POSTOPOC, POSTOP, 0.4, 0, 2)
		twn.interpolate_property(top_oc, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.4, 0, 2)

		twn.start()
		
		center.set_name("temp")
		top.set_name("ActionCenter")
		top_oc.set_name("ActionTop")
		bot_oc.set_name("ActionTopOcult")
		bot.set_name("ActionBotOcult")
		center.set_name("ActionBot")
	else: # Spin Up
		twn.interpolate_property(center, "position", POSCENTER, POSTOP, 0.4, 0, 2)
		twn.interpolate_property(top, "position", POSTOP, POSTOPOC, 0.4, 0, 2)
		twn.interpolate_property(top, "modulate",Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.4, 0, 2)
		twn.interpolate_property(bot, "position", POSBOT, POSCENTER, 0.4, 0, 2)
		twn.interpolate_property(bot_oc, "position", POSBOTOC, POSBOT, 0.4, 0, 2)
		twn.interpolate_property(bot_oc, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.4, 0, 2)

		twn.start()
		
		center.set_name("temp")
		bot.set_name("ActionCenter")
		bot_oc.set_name("ActionBot")
		top_oc.set_name("ActionBotOcult")
		top.set_name("ActionTopOcult")
		center.set_name("ActionTop")
	
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