extends Node

signal targets_selected
signal turn_completed

onready var unit_db = get_node("/root/Units")

var next_id = 0

var active_unit = null
var active_pos = Vector2(0, 0)
var active_targets = []
var active_targets_pos = []
var current_target_index = 0
var selected_targets = []
var target_num = 1
var change_group = false

class CombatUnit:
	var id
	var name
	var hp = 0
	var atk = [0, 0]
	var def = [0, 0]
	var actions = []
	var skills = []
	
	func _init(Unit, id):
		self.id = id
		self.name = Unit.name
		self.hp = Unit.attributes[2]
		self.atk[0] = Unit.attributes[0]
		self.def[0] = Unit.attributes[1]
		self.actions.append(str(Unit.baseatk))
		self.actions.append("Skills")
		self.actions.append("Swap")
		self.actions.append("Defend")
		if Unit.race == "Soulless":
			self.actions.append("Terrify")
		else:
			self.actions.append("Flee")
		self.skills = Unit.skills


func _ready():
	set_process_input(false)
	get_node("ParallaxBackground/TextureRect").set_size(OS.get_window_size())
	get_node("Enemies").set_position(Vector2(OS.get_window_size().x, 0))
	
	var allies = []
	allies.append(CombatUnit.new(unit_db.new_unit("Soulless"), 0))
	allies.append(CombatUnit.new(unit_db.new_unit("Auau"), 1))
	allies.append(CombatUnit.new(unit_db.new_unit("Auau"), 2))
	allies.append(CombatUnit.new(unit_db.new_unit("Auau"), 3))
	get_node("Allies").populate(allies, 0)
	
	var enemies = []
	enemies.append(CombatUnit.new(unit_db.new_unit("Auau"), 4))
	enemies.append(CombatUnit.new(unit_db.new_unit("Auau"), 5))
	enemies.append(CombatUnit.new(unit_db.new_unit("Auau"), 6))
	enemies.append(CombatUnit.new(unit_db.new_unit("Auau"), 7))
	get_node("Enemies").populate(enemies, 4)
	
	combat_loop()


func _input(event):
	var Pointer = get_node("CanvasLayer/Pointer")
	
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_right"):
		current_target_index = (current_target_index + 1) % active_targets.size()
		Pointer.set_position(active_targets_pos[current_target_index])
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("ui_left"):
		current_target_index -= 1
		if current_target_index < 0:
			current_target_index = active_targets.size() - 1
		Pointer.set_position(active_targets_pos[current_target_index])
	if event.is_action_pressed("ui_accept"):
		target_num -= 1
		selected_targets.append(active_targets[current_target_index])
	
	if target_num == 0:
		emit_signal("targets_selected")
		get_node("CanvasLayer/Pointer").hide()
		set_process_input(false)


func combat_loop():
	var combat_ended = 0
	
	while not combat_ended:
		while not change_group and not combat_ended:
			next_turn("Allies")
			yield(self, "turn_completed")
			combat_ended = battle_ended()
		change_group = false
		while not change_group and not combat_ended:
			next_turn("Enemies")
			combat_ended = battle_ended()
		change_group = false


func next_turn(group):
	active_unit = get_node(group).get_next_actor()
	active_pos = get_node(group).get_node(str(active_unit.id)).get_position()
	
	if group == "Allies":
		var ActSel = get_node("ActionSelector")
		
		active_pos.x = -active_pos.x + 20 # compensating because node Allies has scale (-1, 1)
		ActSel.set_position(active_pos)
		ActSel.update_actions(active_unit.actions, active_unit.skills)
		ActSel.enable()
	else:
		# Test only #
		get_node(str(group, "/", active_unit.id)).set_rotation(180)
		#############
		# choose enemy action here


func battle_ended():
	var dead_allies = get_node("Allies").get_dead_units()
	var dead_enemies = get_node("Enemies").get_dead_units()
	
	if dead_enemies.size() == get_node("Enemies").unit_num:
		# Enemies lost
		return 1
	if dead_allies.size() == get_node("Allies").unit_num:
		# Player lost
		return 2
	return 0


func get_targets(group, exclude_active = false, subgroup = null):
	var team = get_node(group)
	
	active_targets = []
	active_targets_pos = []
	current_target_index = 0
	selected_targets = []
	target_num = 1
	
	if not subgroup:
		active_targets = team.get_all_units()
	elif subgroup == "dead":
		active_targets = team.get_dead_units()
	elif subgroup == "targetable":
		active_targets = team.get_targetable_units()
	
	for target in active_targets:
		var pos = team.get_node(str(target.id)).get_position()
		
		if group == "Allies":
			active_targets_pos.append(Vector2(-pos.x, pos.y))
		else:
			active_targets_pos.append(Vector2(pos.x, pos.y))
	
	if exclude_active and active_unit in active_targets:
		var i = active_targets.find(active_unit)
		active_targets.remove(i)
		active_targets_pos.remove(i)
	
	get_node("CanvasLayer/Pointer").set_position(active_targets_pos[0])
	get_node("CanvasLayer/Pointer").show()
	set_process_input(true)


####################### EXTERNAL SIGNAL HANDLING #######################
# Player selected an action
func _on_ActionSelector_selected( name ):
	get_node("ActionSelector").disable()
	
	if name == "Swap":
		get_targets("Allies", true)
		yield(self, "targets_selected")
		get_node("Allies").swap(active_unit.id, selected_targets[0].id)
		yield(get_node("Allies/Tween"), "tween_completed")
	elif name == "Flee":
		# Define flee chance here
		get_node("Allies").flee(active_unit.id)
	
	# Animation and stuff here
	emit_signal("turn_completed")


func _on_Allies_all_acted():
	change_group = true


func _on_Enemies_all_acted():
	change_group = true
########################################################################
