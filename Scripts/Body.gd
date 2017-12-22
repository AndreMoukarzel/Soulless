
extends Node2D

func play_animation(name):
	get_node("AnimationPlayer").play(name)


func define_unit(name, race):
	var folder = str("res://Resources/Units/", race, "/", name, "/")
	define_textures(folder)
	define_anims(folder)
	# definir tamanho, animações e sons

func define_textures(folder):
	get_node("Torso").set_texture(load(str(folder, "torso.png")))
	get_node("Torso/Hip").set_texture(load(str(folder, "hip.png")))
	get_node("Torso/Hip/LegUpFront").set_texture(load(str(folder, "leg_up.png")))
	get_node("Torso/Hip/LegUpFront/LegDown").set_texture(load(str(folder, "leg_down.png")))
	get_node("Torso/Hip/LegUpFront/LegDown/Foot").set_texture(load(str(folder, "foot_back.png")))
	get_node("Torso/Hip/LegUpFront/LegDown/Foot/Tip").set_texture(load(str(folder, "foot_tip.png")))
	get_node("Torso/Hip/LegUpBack").set_texture(load(str(folder, "leg_up.png")))
	get_node("Torso/Hip/LegUpBack/LegDown").set_texture(load(str(folder, "leg_down.png")))
	get_node("Torso/Hip/LegUpBack/LegDown/Foot").set_texture(load(str(folder, "foot_back.png")))
	get_node("Torso/Hip/LegUpBack/LegDown/Foot/Tip").set_texture(load(str(folder, "foot_tip.png")))
	get_node("Torso/ArmUpFront").set_texture(load(str(folder, "arm_up_l.png")))
	get_node("Torso/ArmUpFront/ArmDown").set_texture(load(str(folder, "arm_down.png")))
	get_node("Torso/ArmUpBack").set_texture(load(str(folder, "arm_up_r.png")))
	get_node("Torso/ArmUpBack/ArmDown").set_texture(load(str(folder, "arm_down.png")))
	get_node("Torso/Head").set_texture(load(str(folder, "head.png")))

func define_anims(folder):
	var player = get_node("AnimationPlayer")
	
	player.add_animation("idle", load(str(folder, "idle.tres")))
	player.add_animation("melee", load(str(folder, "melee.tres")))
	
	player.play("idle")