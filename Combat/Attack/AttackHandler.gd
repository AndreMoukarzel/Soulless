extends Node

signal attack_finished
signal attack_interaction_done

const ATKDIST = 150 # Distance between attacker and target when attacking
const WALKTIME = 0.7

export (bool)var DEBUG = 0

onready var dmg_scn = preload("res://Combat/Damage.tscn")


func attack(Attacker, Target, skill_name):
	var twn = get_node("Tween")
	var pos_origin = Attacker.get_global_position()
	
	twn.stop_all()
	Attacker.set_z_index(30)
	Attacker.get_node("HPBar").hide()
	if DEBUG:
		print("Moving ", Attacker.get_name(), " to ", Target.get_name())
	move_Attacker_to_Target(Attacker, Target)
	yield(twn, "tween_completed")
	############# Attack Processing ################
	if DEBUG:
		print("Starting ", Attacker.get_name(), "'s attack")
	execute_attack(Attacker, Target, skill_name)
	yield(Attacker.get_node("AnimationPlayer"), "animation_finished")
	################################################
	if DEBUG:
		print("Moving ", Attacker.get_name(), " back to position")
	Attacker.flip()
	move_Unit(Attacker, Attacker.get_global_position(), pos_origin)
	yield(twn, "tween_completed")
	Attacker.flip()
	Attacker.play_animation("idle")
	Attacker.get_node("HPBar").show()
	Attacker.set_z_index(0)
	
	if DEBUG:
		print("Attack handling finished")
	emit_signal("attack_finished")


func execute_attack(Attacker, Target, skill_name):
	var skill_id = SkillDatabase.get_skill_id(skill_name)
	var skill_args = SkillDatabase.get_skill_arguments(skill_id)
	var AtkTeam = Attacker.get_parent()
	var atk_type = SkillDatabase.get_skill_type(skill_id)
	
	if atk_type == "TimedHit":
		timedHit(Attacker, Target, skill_name, skill_args, AtkTeam.get_name() == "Allies")
	elif atk_type == "HoldRelease":
		HoldRelease(Attacker, Target, skill_name, skill_args, AtkTeam.get_name() == "Allies")
	yield(self, "attack_interaction_done")


func instance_attack_interaction(attack_type):
	var AtkInter_scn = load(str("res://Combat/Attack/", attack_type, ".tscn"))
	var AtkInter = AtkInter_scn.instance()
	
	return AtkInter


# if attacking = false, the player is defending against a hit
func timedHit(Attacker, Target, attack_name, time_array, attacking):
	var previous_time = 0
	var TimedHit = instance_attack_interaction("TimedHit")
	add_child(TimedHit)
	
	for time in time_array:
		Attacker.play_animation(attack_name)
		TimedHit.start(time - previous_time)
		previous_time = time
		yield(TimedHit, "done")
		
		var dmg = define_damage(Attacker, Target)
		if TimedHit.super:
			if attacking:
				shake_camera(0.4)
				create_damage_box(2 * dmg, Target.get_global_position(), "good")
				Target.get_damaged(2 * dmg)
			else:
				Target.dodge()
		elif TimedHit.regular:
			if attacking:
				create_damage_box(int(1.5 * dmg), Target.get_global_position(), "good")
				Target.get_damaged(int(1.5 * dmg))
			else:
				create_damage_box(dmg/2, Target.get_global_position(), "good")
				Target.defend(dmg, 0.5)
		else:
			create_damage_box(dmg, Target.get_global_position(), "good")
			Target.get_damaged(dmg)
	
	TimedHit.queue_free()
	emit_signal("attack_interaction_done")


# if attacking = false, the player is defending against a hit
func HoldRelease(Attacker, Target, attack_name, hold_time, attacking):
	var dmg = define_damage(Attacker, Target)
	Attacker.play_animation("idle")
	
	if attacking:
		var HoldRelease = instance_attack_interaction("HoldRelease")
		add_child(HoldRelease)
		HoldRelease.start(hold_time, Attacker, attack_name)
		yield(HoldRelease, "done")
		
		if HoldRelease.success:
			shake_camera(0.4)
			create_damage_box(dmg, Target.get_global_position(), "good")
			Target.get_damaged(dmg)
		else:
			print(HoldRelease.multiplier)
			create_damage_box(int(dmg * HoldRelease.multiplier), Target.get_global_position(), "good")
			Target.get_damaged(int(dmg * HoldRelease.multiplier))
		
		HoldRelease.queue_free()
	else:
		var TimedHit = instance_attack_interaction("TimedHit")
		var HoldRelease = instance_attack_interaction("HoldRelease")
		HoldRelease.get_node("HoldReleaseVisual").set_scale(Vector2(-1, 1))
		add_child(TimedHit)
		add_child(HoldRelease)
		HoldRelease.start(hold_time, Attacker, attack_name)
		HoldRelease.begin()
		TimedHit.start(hold_time)
		yield(TimedHit, "done")
		
		if TimedHit.super:
			Target.dodge()
		elif TimedHit.regular():
			create_damage_box(dmg/2, Target.get_global_position(), "good")
			Target.defend(dmg, 0.5)
		else:
			create_damage_box(dmg, Target.get_global_position(), "good")
			Target.get_damaged(dmg)
		
		TimedHit.queue_free()
	
	emit_signal("attack_interaction_done")


func define_damage(Attacker, Target):
	var damage = Attacker.ATK - Target.DEF
	if damage < 1:
		damage = 1 

	return damage


func create_damage_box(value, pos, animation, sound = "Hit"):
	var dmg = dmg_scn.instance()
	
	if DEBUG:
		print("Damage dealt: ", value)
	dmg.get_node("Visual/Label").set_text(str(value))
	dmg.set_position(Vector2(pos.x, pos.y - 100))
	dmg.set_z_index(35)
	dmg.get_node("AnimationPlayer").play(animation)
	dmg.get_node(str(sound, "Sound")).play()
	get_parent().add_child(dmg)
	yield(dmg.get_node("AnimationPlayer"), "animation_finished")
	dmg.queue_free()

####################### CHARACTER MOVEMENT #######################
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

######################## CAMERA MOVEMENT ########################
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