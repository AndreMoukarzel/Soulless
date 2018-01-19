extends Node

signal attack_finished

const ATKDIST = 150
const WALKTIME = 0.7

onready var skill_db = get_node("/root/Skills")
onready var dmg_scn = preload("res://Scenes/Combat/Damage.tscn")

var attacker
var atk_team
var atk_node
var target
var target_team
var target_node

var pos_origin

# atk_info is [Attacker, Attacker's Team, Target, Target's Team]
func attack(atk_info, skill_info):
	var twn = get_node("Tween")
	
	attacker = atk_info[0]
	atk_team = get_parent().get_node(str(atk_info[1]))
	atk_node = atk_team.get_node(str(attacker.id))
	# Before getting target, we must check in skill_info if the skill is actually multi-target
	target = atk_info[2]
	target_team = get_parent().get_node(str(atk_info[3]))
	target_node = target_team.get_node(str(target.id))
	
	pos_origin = atk_node.get_position()

	twn.stop_all()
	atk_node.get_node("HPBar").hide()
	unit_movement()
	atk_node.get_node("AnimationPlayer").play("walk")
	twn.start()
	yield(twn, "tween_completed")
	
	# Only for testing #
	action_event(skill_info)
	yield(atk_node.get_node("AnimationPlayer"), "animation_finished")
	####################
	
	unit_movement(true)
	atk_node.get_node("AnimationPlayer").play("walk")
	twn.start()
	yield(twn, "tween_completed")
	atk_node.get_node("HPBar").show()
	atk_node.get_node("AnimationPlayer").play("idle")
	
	emit_signal("attack_finished")


func action_event(skill_name):
	var id = skill_db.get_skill_id(skill_name)
	var type = skill_db.get_skill_type(id)
	var act_scn = load(str("res://Scenes/Combat/", type, ".tscn"))
	var act = act_scn.instance()
	var anim = null
	var dmg
	
	if atk_team.get_name() == "Allies": # Player Attack
		var atk_time = skill_db.get_skill_atktime(id)
		
		atk_node.get_node("AnimationPlayer").play(skill_name)
		act.start(atk_time)
		add_child(act)
		yield(act, "done")
		
		var hit = act.hit
		var super = act.super
		
		dmg = define_damage()
		if super:
			shake_camera(10, 0.5)
			dmg *= 2
		elif hit:
			dmg = int(dmg * 1.5)
		create_damage_box(dmg, target_team.get_unit_pos(target.id), "evil")
	
	else: # Player Defend
		var def_time = skill_db.get_skill_deftime(id)
		
		atk_node.get_node("AnimationPlayer").play(skill_name)
		act.start(def_time)
		add_child(act)
		yield(act, "done")
		
		var hit = act.hit
		var super = act.super
		
		dmg = define_damage()
		if super:
			dmg = 0
			anim = "defend" # trocar para dodge quando eu fizer a animação
			create_damage_box(dmg, target_team.get_unit_pos(target.id), "good", "Dodge")
		elif hit:
			dmg = int(dmg / 1.5)
			anim = "defend"
			create_damage_box(dmg, target_team.get_unit_pos(target.id), "good")
		else:
			create_damage_box(dmg, target_team.get_unit_pos(target.id), "good")
		
	target_team.damage(dmg, target, anim)


func define_damage():
	var damage = attacker.atk[0] - target.def[0]
	
	if damage < 0:
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


func unit_movement(reverse = false):
	var pos_final = Vector2(0, 0)
	
	if target_node:
		var attacker_pos = atk_team.get_unit_pos(int(atk_node.get_name()))
		var target_pos = target_team.get_unit_pos(int(target_node.get_name()))
		var pos_dif = target_pos - attacker_pos
		
		if pos_dif.x > 0:
			pos_dif.x -= ATKDIST
			pos_final.x = pos_origin.x - pos_dif.x
		elif pos_dif.x < 0:
			pos_dif.x += ATKDIST
			pos_final.x = pos_origin.x + pos_dif.x
		pos_final.y = pos_origin.y + pos_dif.y
		
		if not reverse:
			camera_movement(pos_dif, attacker_pos, atk_team)
			get_node("Tween").interpolate_property(atk_node, "position", atk_node.get_position(), pos_final, WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		else:
			camera_movement(null, null, null, true)
			get_node("Tween").interpolate_property(atk_node, "position", atk_node.get_position(), pos_origin, WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)


func camera_movement(pos_dif, attacker_pos, atk_team, reverse = false):
	var Cam = get_node("Camera2D")
	
	if not reverse:
		var pos = attacker_pos
		
		pos.x += pos_dif.x
		pos.y += pos_dif.y
		
		get_node("Tween").interpolate_property(Cam, "zoom", Vector2(1, 1), Vector2(0.9, 0.9), WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		get_node("Tween").interpolate_property(Cam, "position", OS.get_window_size()/2, pos, WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	else:
		get_node("Tween").interpolate_property(Cam, "zoom", Vector2(0.9, 0.9), Vector2(1, 1), WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		get_node("Tween").interpolate_property(Cam, "position", Cam.get_position(), OS.get_window_size()/2, WALKTIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)


func shake_camera(intensity, duration):
	var twn = get_node("ShakeTween")
	var Cam = get_node("Camera2D")
	var init_pos = Cam.get_position()
	
	for i in range(5):
		var pos = Vector2(0, 0)
		
		pos.x = (randi() % intensity) - (randi() % intensity)
		pos.y = (randi() % intensity) - (randi() % intensity)
		pos += init_pos
		
		twn.interpolate_property(Cam, "position", Cam.get_position(), pos, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		twn.start()
		yield(twn, "tween_completed")
	
	twn.interpolate_property(Cam, "position", Cam.get_position(), init_pos, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	twn.start()