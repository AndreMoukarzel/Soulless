extends Node

signal attack_finished

const ATKDIST = 150 # Distance between attacker and target when attacking
const WALKTIME = 0.7

onready var dmg_scn = preload("res://Combat/Damage.tscn")


func attack(Attacker, Target, skill_name):
	var twn = get_node("Tween")
	var pos_origin = Attacker.get_global_position()
	
	twn.stop_all()
	Attacker.set_z_index(30)
	Attacker.get_node("HPBar").hide()
	move_Attacker_to_Target(Attacker, Target)
	yield(twn, "tween_completed")
	
	# Only for testing #
	execute_attack(Attacker, Target, skill_name)
	yield(Attacker.get_node("AnimationPlayer"), "animation_finished")
	####################
	
	Attacker.flip()
	move_Unit(Attacker, Attacker.get_global_position(), pos_origin)
	yield(twn, "tween_completed")
	Attacker.flip()
	Attacker.play_animation("idle")
	Attacker.get_node("HPBar").show()
	Attacker.set_z_index(0)
	
	emit_signal("attack_finished")


func execute_attack(Attacker, Target, skill_name):
	var skill_id = SkillDatabase.get_skill_id(skill_name)
	var skill_args = SkillDatabase.get_skill_arguments(skill_id)
	var AtkTeam = Attacker.get_parent()
	var AtkIter = instance_attack_interaction(skill_id)
	
	add_child(AtkIter)
	Attacker.play_animation(skill_name)
	AtkIter.start(skill_args[0])
	yield(AtkIter, "done")
	
	var hit = AtkIter.hit
	var super = AtkIter.super
	var dmg = define_damage(Attacker, Target)
	if AtkTeam.get_name() == "Allies": # Player is the attacker
		if super:
			shake_camera(0.4)
			dmg *= 2
		elif hit:
			dmg = int(dmg * 1.5)
	else: # Player is defending
		if super:
			dmg = 0
#			anim = "defend" # trocar para dodge quando eu fizer a animação
#			create_damage_box(dmg, target_team.get_unit_pos(target.id), "good", "Dodge")
		elif hit:
			dmg = int(dmg / 2)
#			anim = "defend"
#			create_damage_box(dmg, target_team.get_unit_pos(target.id), "good")
	create_damage_box(dmg, Target.get_global_position(), "good")
	Target.get_damaged(dmg)


func instance_attack_interaction(skill_id):
	var type = SkillDatabase.get_skill_type(skill_id)
	var AtkInter_scn = load(str("res://Combat/Attack/", type, ".tscn"))
	var AtkInter = AtkInter_scn.instance()
	return AtkInter


func define_damage(Attacker, Target):
	var damage = Attacker.ATK - Target.DEF

	if damage < 1:
		damage = 1 

	return damage


func create_damage_box(value, pos, animation, sound = "Hit"):
	var dmg = dmg_scn.instance()
	
	dmg.get_node("Visual/Label").set_text(str(value))
	dmg.set_position(Vector2(pos.x, pos.y - 100))
	dmg.set_z_index(35)
	dmg.get_node("AnimationPlayer").play(animation)
	dmg.get_node(str(sound, "Sound")).play()
	get_parent().add_child(dmg)
	yield(dmg.get_node("AnimationPlayer"), "animation_finished")
	dmg.queue_free()


func move_Unit(Unit, starting_pos, ending_pos):
	if not Unit:
		breakpoint
	
	$Tween.interpolate_property(Unit, "global_position", starting_pos, ending_pos, WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	Unit.play_animation("walk")

func move_Attacker_to_Target(Attacker, Target):
	var atkr_pos = Attacker.get_global_position()
	var trgt_pos = Target.get_global_position()
	var atk_dist = ATKDIST
	
	if trgt_pos.x > atkr_pos.x:
		atk_dist *= -1
	
	move_Unit(Attacker, atkr_pos, trgt_pos + Vector2(atk_dist, 0))

func camera_movement(pos_dif, attacker_pos, atk_team, reverse = false):
	var Cam = get_node("ScreenShake/Camera2D")
	
	if not reverse:
		var pos = attacker_pos
		
		pos.x += pos_dif.x
		pos.y += pos_dif.y
		
		get_node("Tween").interpolate_property(Cam, "zoom", Vector2(1, 1), Vector2(0.9, 0.9), WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		get_node("Tween").interpolate_property(Cam, "position", OS.get_window_size()/2, pos, WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	else:
		get_node("Tween").interpolate_property(Cam, "zoom", Vector2(0.9, 0.9), Vector2(1, 1), WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		get_node("Tween").interpolate_property(Cam, "position", Cam.get_position(), OS.get_window_size()/2, WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)


func shake_camera(intensity):
	get_node("ScreenShake").add_shake(intensity)