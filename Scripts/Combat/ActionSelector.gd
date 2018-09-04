
extends Node2D

export (bool)var DEBUG = 0

const SPINSPD = 0.3
const RADIUS = 150

signal selected(name) # Selected action
signal changed_to(name) # Highlighted action changed

var Action_scn = preload("res://Combat/ActionSelector/Action.tscn")

var hl = 0 # highlighted action
var action_num = 0 # total number of actions
var rotation_step = 0


func _input(event):
	if event.is_action_pressed("ui_left"):
		change_action(false)
	elif event.is_action_pressed("ui_right"):
		change_action(true)
	
	if event.is_action_pressed("ui_accept"):
		if DEBUG:
			print ("Selected ", get_current_Action().get_name())
		emit_signal("selected", get_current_Action().get_name())

# Resets ActionSelector to initial state
func clear():
	var Actions = get_children()
	Actions.pop_front() # Discards Tween node
	for Action in Actions:
		Action.set_name("OldAction")
		Action.queue_free()
	
	hl = 0
	action_num = 0
	rotation_step = 0
	set_rotation_degrees(0)


func update_actions(action_list):
	clear()
	var angle = 0
	var angle_step = int(360 / action_list.size())
	for action in action_list:
		instance_Action(action, angle)
		angle += angle_step
	
	rotation_step = angle_step
	action_num = action_list.size()
	hl = action_num - 1


func instance_Action(action_name, angle):
	var Act = Action_scn.instance()
	var rad_angle = deg2rad(angle)
	Act.set_name(action_name)
	Act.set_position(RADIUS * Vector2(sin(rad_angle), -cos(rad_angle)))
	Act.get_node("Label").set_text(action_name)
	# set correct icon and stuff
	add_child(Act)


func get_current_Action():
	var Acts = get_children()
	Acts.pop_front() # Discards Tween node
	return Acts[action_num - hl - 1]


func enable():
	set_process_input(true)
	show()


func disable():
	set_process_input(false)
	hide()


func spin(clockwise = true):
	var Twn = $Tween
	var rot = rotation_step
	
	if not clockwise:
		rot *= -1
	
	set_process_input(false)
	Twn.interpolate_property(self, "rotation_degrees", get_rotation_degrees(), get_rotation_degrees() - rot, SPINSPD, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	var Acts = get_children()
	Acts.pop_front() # Discards Tween node
	for Act in Acts: # Rotates children in oposite direction, so the continue facing up
		Twn.interpolate_property(Act, "rotation_degrees", Act.get_rotation_degrees(), Act.get_rotation_degrees() + rot, SPINSPD, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	Twn.start()
	yield(Twn, "tween_completed")
	set_process_input(true)


func change_action(clockwise = true):
	if clockwise:
		hl -= 1
		if hl < 0:
			hl = action_num - 1
	else:
		hl = (hl + 1) % action_num
	spin(clockwise)
	emit_signal("changed_to", get_current_Action().get_name())
	if DEBUG:
		print ("Changed_to ", get_current_Action().get_name())
