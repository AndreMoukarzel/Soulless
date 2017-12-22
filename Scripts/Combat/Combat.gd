extends Node

signal targets_selected

onready var unit_db = get_node("/root/Units")

var next_id = 0
var active_unit = null
var active_pos = Vector2(0, 0)
var time = []
var active_targets = []
var active_targets_pos = []
var current_target_index = 0
var selected_targets = []
var target_num = 1

class CombatUnit:
	var id
	var name
	var hp = [0, 0]
	var atk = [0, 0]
	var def = [0, 0]
	var skills = []
	
	func _init(Unit, id):
		self.id = id
		self.name = Unit.name
		self.hp[0] = Unit.attributes[2]
		self.atk[0] = Unit.attributes[0]
		self.def[0] = Unit.attributes[1]
		self.skills = Unit.skills


func _ready():
	get_node("ParallaxBackground/TextureRect").set_size(OS.get_window_size())
	set_process_input(false)
	
	time.append(CombatUnit.new(unit_db.new_unit("Soulless"), 0))
	time.append(CombatUnit.new(unit_db.new_unit("Auau"), 1))
	time.append(CombatUnit.new(unit_db.new_unit("Auau"), 2))
	time.append(CombatUnit.new(unit_db.new_unit("Auau"), 3))
	get_node("Allies").populate(time, 0)
	
	next_turn()
	
	var rodinha = get_node("ActionSelector")
	rodinha.set_position(active_pos)
	rodinha.update_actions(active_unit.skills)
	rodinha.enable()


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
#		if DEBUG:
#			print ("Targets remaining to be selected: ", target_num)
	
	if target_num == 0:
#		if DEBUG:
#			print ("Targets Selected")
		emit_signal("targets_selected")
		get_node("CanvasLayer/Pointer").hide()
		set_process_input(false)


func next_turn():
	var active_id = get_node("Allies").get_next_actor()
	active_pos = get_node("Allies").get_node(str(active_id)).get_position()
	
	active_pos.x = -active_pos.x + 10
	for u in time:
		if u != null and u.id == active_id:
			active_unit = u
			break


func _on_ActionSelector_selected( name ):
	var rodinha = get_node("ActionSelector")
	rodinha.disable()
	
	if name == "Swap":
		get_targets()
		yield(self, "targets_selected")
		get_node("Allies").swap(active_unit.id, selected_targets[0])
	next_turn()
	
	rodinha.set_position(active_pos)
	rodinha.update_actions(active_unit.skills)
	rodinha.enable()


func get_targets():
	var group = get_node("Allies")
	
	active_targets = []
	active_targets_pos = []
	current_target_index = 0
	selected_targets = []
	target_num = 1
	
	for id in group.units:
		active_targets.append(id)
		var pos = group.get_node(str(id)).get_position()
		active_targets_pos.append(Vector2(-pos.x, pos.y))
	
	get_node("CanvasLayer/Pointer").set_position(active_targets_pos[0])
	get_node("CanvasLayer/Pointer").show()
	set_process_input(true)
