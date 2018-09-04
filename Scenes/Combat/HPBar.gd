extends ProgressBar

func add_to_unit(Unit):
	set_position(Unit.get_position() + Vector2(-50, 120))
#	if self.get_name() == "Allies":
#				bar_pos.x = -bar_pos.x
	set_max(Unit.HP)
	set_value(Unit.HP)
	get_node("Label").set_text(str(Unit.HP, "/", Unit.HP))
	Unit.add_child(self)