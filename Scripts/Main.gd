extends Node

func restart():
	get_node("Combat").set_name("old_Combat")
	get_node("old_Combat").queue_free()
	var Cmb_scn = load("res://Scenes/Combat/Combat.tscn")
	var Cmb = Cmb_scn.instance()
	add_child(Cmb)