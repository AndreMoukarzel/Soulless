
extends Node2D

func play_animation(anim_name):
	get_node("AnimationPlayer").play(anim_name)


func define_unit(unit_name, race, framenum, attacks):
	var folder = str("res://Resources/Units/", race, "/", unit_name, "/")
	define_textures(unit_name, folder, framenum)
	define_anims(folder, attacks)
	# definir sons

func define_textures(unit_name, folder, framenum):
	get_node("Torso").set_texture(load(str(folder, unit_name, "_torso.png")))
	get_node("Torso").set_hframes(framenum[0])
	get_node("Torso/Head").set_texture(load(str(folder, unit_name, "_head.png")))
	get_node("Torso/Head").set_hframes(framenum[1])
	get_node("Torso/Head/EarFront").set_texture(load(str(folder, unit_name, "_ear.png")))
	get_node("Torso/Head/EarFront").set_hframes(framenum[2])
	get_node("Torso/Head/EarBack").set_texture(load(str(folder, unit_name, "_ear.png")))
	get_node("Torso/Head/EarBack").set_hframes(framenum[2])
	get_node("Torso/ArmFront").set_texture(load(str(folder, unit_name, "_arm.png")))
	get_node("Torso/ArmFront").set_hframes(framenum[3])
	get_node("Torso/ArmFront/Hand").set_texture(load(str(folder, unit_name, "_hand.png")))
	get_node("Torso/ArmFront/Hand").set_hframes(framenum[4])
	get_node("Torso/ArmBack").set_texture(load(str(folder, unit_name, "_arm.png")))
	get_node("Torso/ArmBack").set_hframes(framenum[3])
	get_node("Torso/ArmBack/Hand").set_texture(load(str(folder, unit_name, "_hand.png")))
	get_node("Torso/ArmBack/Hand").set_hframes(framenum[4])
	get_node("Torso/FootFront").set_texture(load(str(folder, unit_name, "_foot.png")))
	get_node("Torso/FootFront").set_hframes(framenum[5])
	get_node("Torso/FootBack").set_texture(load(str(folder, unit_name, "_foot.png")))
	get_node("Torso/FootBack").set_hframes(framenum[5])
	get_node("Torso/Tail").set_texture(load(str(folder, unit_name, "_tail.png")))
	get_node("Torso/Tail").set_hframes(framenum[6])


func define_anims(folder, attacks):
	var player = get_node("AnimationPlayer")
	
	player.add_animation("idle", load(str(folder, "idle.tres")))
	player.add_animation("walk", load(str(folder, "walk.tres")))
	player.add_animation("hit", load(str(folder, "hit.tres")))
	player.add_animation("die", load(str(folder, "die.tres")))
	for atk in attacks:
		player.add_animation(str(atk), load(str(folder, atk, ".tres")))
	
	player.play("idle")