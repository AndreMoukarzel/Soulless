extends Node

signal animations_finished

var Chars = ["Bunny", "Mole"]

func _ready():
	get_node("Display").set_position(OS.window_size/2 + Vector2(0, 200))
	
	# Test each char
	for c in Chars:
		var unit = instance_unit(c)
		display_unit_info(unit)
		print_unit_info(unit)
		display_animations(unit)
		yield(self, "animations_finished")
		unit.queue_free()


func instance_unit(unit_name):
	var path = "res://Characters/" + unit_name + "/" + unit_name + ".tscn"
	var l = load(path)
	var unit = l.instance()
	unit.set_position(OS.window_size/2)
	add_child(unit)
	
	return unit

func display_unit_info(unit):
	get_node("Display/VBoxContainer/Name").set_text(unit.name)
	get_node("Display/VBoxContainer/HP").set_text(str(unit.HP))
	get_node("Display/VBoxContainer/ATK").set_text(str(unit.ATK))
	get_node("Display/VBoxContainer/DEF").set_text(str(unit.DEF))

func print_unit_info(unit):
	var unit_info = unit.name + ":\nHP: %s\nATK: %s\nDEF: %s\n"
	unit_info = unit_info % [str(unit.HP), str(unit.ATK), str(unit.DEF)]
	print(unit_info)

func display_animations(unit):
	var anim_player = unit.get_node("AnimationPlayer")
	var anim_list = anim_player.get_animation_list()
	
	for anim in anim_list:
		$AnimationTimer.start()
		anim_player.play(anim)
		yield($AnimationTimer, "timeout")
	emit_signal("animations_finished")