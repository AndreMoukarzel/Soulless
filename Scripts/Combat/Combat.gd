extends Node

signal targets_selected
signal turn_completed

onready var unit_db = get_node("/root/Units")
onready var EnemyAI = preload("res://Scripts/Combat/EnemyAI.gd")

var next_id = 0

var active_unit = null
var active_pos = Vector2(0, 0)
var active_targets = []
var active_targets_pos = []
var current_target_index = 0
var selected_targets = []
var target_num = 1
var active_group = "Allies"

class CombatUnit:
	var id
	var name
	var size
	var hp = 0
	var atk = [0, 0]
	var def = [0, 0]
	var actions = []
	var skills = []
	
	func _init(Unit, id):
		self.id = id
		self.name = Unit.name
		self.size = Unit.size
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
	randomize()
	set_process_input(false)
	get_node("ParallaxBackground/TextureRect").set_size(OS.get_window_size())
	get_node("Enemies").set_position(Vector2(OS.get_window_size().x, 0))
	
	var allies = []
	allies.append(CombatUnit.new(unit_db.new_unit("Soulless"), 0))
	allies.append(CombatUnit.new(unit_db.new_unit("Bunny"), 1))
	allies.append(CombatUnit.new(unit_db.new_unit("Bunny"), 2))
	allies.append(CombatUnit.new(unit_db.new_unit("Bunny"), 3))
	get_node("Allies").populate(allies, 0)
	
	var enemies = []
	enemies.append(CombatUnit.new(unit_db.new_unit("Bunny"), 4))
	enemies.append(CombatUnit.new(unit_db.new_unit("Bunny"), 5))
	enemies.append(CombatUnit.new(unit_db.new_unit("Bunny"), 6))
	enemies.append(CombatUnit.new(unit_db.new_unit("Bunny"), 7))
	get_node("Enemies").populate(enemies, 4)
	
	player_turn()


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


func player_turn():
	active_unit = get_node("Allies").get_next_actor()
	active_pos = get_node("Allies").get_node(str(active_unit.id)).get_position()
	
	active_unit.def[1] = 0 # in case active_unit defended last turn
	
	if active_unit.hp > 0:
		var ActSel = get_node("ActionSelector")
		
		active_pos.x = -active_pos.x + 20 # compensating because node Allies has scale (-1, 1)
		ActSel.set_position(active_pos)
		ActSel.update_actions(active_unit.actions, active_unit.skills)
		ActSel.enable()
		yield(self, "turn_completed")
	
	if active_group == "Allies":
		player_turn()
	else:
		enemy_turn()


func enemy_turn():
	var unit = get_node("Enemies").get_next_actor()
	var act = EnemyAI.choose_action(unit, get_node("Allies").units, get_node("Enemies").units, get_node("Allies").cap_index, get_node("Enemies").cap_index)
	
	if act != null:
		if act[0] == "Attack":
			get_node("AttackHandler").attack([unit, "Enemies", act[1], "Allies"], null)
			yield(get_node("AttackHandler"), "attack_finished")
	
	if active_group == "Enemies":
		enemy_turn()
	else:
		player_turn()


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
		var pos = team.get_unit_pos(target.id)
		
		active_targets_pos.append(pos)
	
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
	
	if name == "Defend":
		active_unit.def[1] += 1
	elif name == "Swap":
		get_targets("Allies", true)
		yield(self, "targets_selected")
		swap("Allies", active_unit.id, selected_targets[0].id)
		yield(get_node("Allies/Tween"), "tween_completed")
	elif name == "Flee":
		# Define flee chance here
		flee("Allies", active_unit.id)
	elif name == "Terrify":
		pass
	else:
		get_targets("Enemies", false, "targetable")
		yield(self, "targets_selected")
		get_node("AttackHandler").attack([active_unit, "Allies", selected_targets[0], "Enemies"], null)
		yield(get_node("AttackHandler"), "attack_finished")
	
	# Animation and stuff here
	emit_signal("turn_completed")


func _on_Allies_all_acted():
	active_group = "Enemies"


func _on_Enemies_all_acted():
	active_group = "Allies"
########################################################################
########################## AUXILIARY FUNCTIONS #########################

func swap(group, unit_id1, unit_id2):
	get_node(group).swap(unit_id1, unit_id2)

func flee(group, unit_id):
	get_node(group).flee(unit_id)

########################################################################