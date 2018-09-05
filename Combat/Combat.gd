extends Node

const FLEECHANCE = 70

signal targets_selected
signal turn_completed

onready var EnemyAI = preload("res://Combat/EnemyAI.gd")

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
	var race
	var size
	var hp = 0
	var hp_max
	var atk = [0, 0]
	var def = [0, 0]
	var actions = []
	var skills = []
	
	func _init(Unit, id):
		self.id = id
		self.name = Unit.name
		self.race = Unit.race
		self.size = Unit.size
		self.hp = Unit.attributes[2]
		self.hp_max = self.hp
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
	get_node("BackGround").set_size(OS.get_window_size())
	get_node("CanvasLayer/End/Black").set_size(OS.get_window_size())
	get_node("CanvasLayer/End/Label").set_position(OS.get_window_size()/2)
	get_node("AttackHandler/ScreenShake/Camera2D").set_position(OS.get_window_size()/2)
	get_node("Enemies").set_position(Vector2(OS.get_window_size().x, 0))
	
	var allies = []
	allies.append("Bunny")
	allies.append("Mole")
	
	get_node("Allies").populate(allies, true)
	
	var enemies = []
	enemies.append("Bunny")
	get_node("Enemies").populate(enemies, false)
	
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
	elif event.is_action_pressed("ui_cancel"):
		get_node("ActionSelector").enable()
		get_node("CanvasLayer/Pointer").hide()
		set_process_input(false)
	
	if target_num == 0:
		emit_signal("targets_selected")
		get_node("CanvasLayer/Pointer").hide()
		set_process_input(false)


func player_turn():
	active_unit = get_node("Allies").get_next_actor()
	active_pos = active_unit.get_global_position()
	
	if active_unit.HP > 0:
		var ActSel = get_node("ActionSelector")
		var action_list = []
		
		ActSel.set_position(active_pos)
		action_list.append(active_unit.Signature1)
		action_list.append(active_unit.Signature2)
		action_list = action_list + ["Flee", "Swap", "Item"]
		ActSel.update_actions(action_list)
		ActSel.enable()
		yield(self, "turn_completed")
	
	var result = battle_ended()
	if result == 1:
		victory()
		return
	elif result == 2:
		defeat()
		return
	
	if active_group == "Allies":
		player_turn()
	else:
		enemy_turn()


func enemy_turn():
	var unit = get_node("Enemies").get_next_actor()
	var act = EnemyAI.choose_action(unit, get_node("Allies").units, get_node("Enemies").units, get_node("Allies").cap_index, get_node("Enemies").cap_index)
	
	active_unit.def[1] = 0 # in case active_unit defended last turn
	
	if act != null:
		if act[0] == "Attack":
			get_node("AttackHandler").attack([unit, "Enemies", act[1], "Allies"], unit.actions[0])
			yield(get_node("AttackHandler"), "attack_finished")
	
	var result = battle_ended()
	if result == 1:
		victory()
		return
	elif result == 2:
		defeat()
		return
	
	if active_group == "Enemies":
		enemy_turn()
	else:
		player_turn()


func battle_ended():
	var dead_allies = get_node("Allies").get_dead_units()
	var dead_enemies = get_node("Enemies").get_dead_units()
	
	if dead_enemies.size() == get_node("Enemies").get_all_units().size():
		# Enemies lost
		return 1
	if dead_allies.size() == get_node("Allies").get_all_units().size():
		# Player lost
		return 2
	return 0


func victory():
	var End = get_node("CanvasLayer/End")
	
	End.get_node("Label").set_text("You Won")
	End.get_node("AnimationPlayer").play("end")
	yield(End.get_node("AnimationPlayer"), "animation_finished")
	get_parent().restart()


func defeat():
	var End = get_node("CanvasLayer/End")
	
	End.get_node("Label").set_text("IS THIS LOSS?")
	End.get_node("AnimationPlayer").play("end")
	yield(End.get_node("AnimationPlayer"), "animation_finished")
	get_parent().restart()


func get_targets(group, exclude_active = false, subgroup = null):
	var team = get_node(group)
	
	active_targets = []
	active_targets_pos = []
	current_target_index = 0
	selected_targets = []
	target_num = 1
	
	if not subgroup:
		active_targets = team.get_all_units()
	elif subgroup == "targetable":
		active_targets = team.get_front_unit()
	
	for target in active_targets:
		active_targets_pos.append(target.get_global_position())
	
	if exclude_active and active_unit in active_targets:
		var i = active_targets.find(active_unit)
		active_targets.remove(i)
		active_targets_pos.remove(i)
	
	get_node("CanvasLayer/Pointer").set_position(active_targets_pos[0])
	get_node("CanvasLayer/Pointer").show()
	set_process_input(true)


####################### EXTERNAL SIGNAL HANDLING #######################
# Player selected an action
func _on_ActionSelector_selected( action ):
	get_node("ActionSelector").disable()
	
	if action == "Swap":
		get_targets("Allies", true)
		yield(self, "targets_selected")
		swap("Allies", active_unit, selected_targets[0])
		yield(get_node("Allies/Tween"), "tween_completed")
	elif action == "Flee":
		if flee_succeeded():
			flee("Allies", active_unit)
		else:
			print("Flee failed")
	elif action == "Terrify":
		if terrify_succeeded():
			var enemies = get_node("Enemies").get_all_units()
			
			for u in enemies:
				if u.hp > 0:
					flee("Enemies", u.id)
		else:
			print("Terrify failed")
	else:
		get_targets("Enemies", false, "targetable")
		yield(self, "targets_selected")
		get_node("AttackHandler").attack(active_unit, selected_targets[0], action)
		yield(get_node("AttackHandler"), "attack_finished")
	
	# Animation and stuff here
	emit_signal("turn_completed")


func flee_succeeded():
	var r = randi() % 100
	
	if r < FLEECHANCE:
		return true
	return false


func terrify_succeeded():
	var all = get_node("Enemies").get_all_units()
	var total = 0
	
	for unit in all:
		total += unit.hp
	
	if total > FLEECHANCE:
		return 0
	
	var r = randi() % 100
	
	if r < FLEECHANCE - total:
		return true
	return false


func _on_Allies_all_acted():
	active_group = "Enemies"


func _on_Enemies_all_acted():
	active_group = "Allies"
########################################################################
########################## AUXILIARY FUNCTIONS #########################

func swap(group, Unit1, Unit2):
	get_node(group).swap(Unit1, Unit2)

func flee(group, Unit):
	get_node(group).flee(Unit)

########################################################################