
extends Node2D

func play_animation(anim_name):
	get_node("AnimationPlayer").play(anim_name)


func define_unit(unit_name, race, framenum, attacks):
	var folder = str("res://Resources/Units/", race, "/", unit_name, "/")
	
#	define_textures(unit_name, folder, framenum)
	define_anims(unit_name, attacks)
	# definir sons

#func define_textures(unit_name, folder, framenum):
#	get_node("Torso").set_texture(load(str(folder, unit_name, "_torso.png")))
#	get_node("Torso").set_hframes(framenum[0])
#	get_node("Torso/Head").set_texture(load(str(folder, unit_name, "_head.png")))
#	get_node("Torso/Head").set_hframes(framenum[1])
#	get_node("Torso/Head/EarFront").set_texture(load(str(folder, unit_name, "_ear.png")))
#	get_node("Torso/Head/EarFront").set_hframes(framenum[2])
#	get_node("Torso/Head/EarBack").set_texture(load(str(folder, unit_name, "_ear.png")))
#	get_node("Torso/Head/EarBack").set_hframes(framenum[2])
#	get_node("Torso/ArmFront").set_texture(load(str(folder, unit_name, "_arm.png")))
#	get_node("Torso/ArmFront").set_hframes(framenum[3])
#	get_node("Torso/ArmFront/Hand").set_texture(load(str(folder, unit_name, "_hand.png")))
#	get_node("Torso/ArmFront/Hand").set_hframes(framenum[4])
#	get_node("Torso/ArmBack").set_texture(load(str(folder, unit_name, "_arm.png")))
#	get_node("Torso/ArmBack").set_hframes(framenum[3])
#	get_node("Torso/ArmBack/Hand").set_texture(load(str(folder, unit_name, "_hand.png")))
#	get_node("Torso/ArmBack/Hand").set_hframes(framenum[4])
#	get_node("Torso/FootFront").set_texture(load(str(folder, unit_name, "_foot.png")))
#	get_node("Torso/FootFront").set_hframes(framenum[5])
#	get_node("Torso/FootBack").set_texture(load(str(folder, unit_name, "_foot.png")))
#	get_node("Torso/FootBack").set_hframes(framenum[5])
#	get_node("Torso/Tail").set_texture(load(str(folder, unit_name, "_tail.png")))
#	get_node("Torso/Tail").set_hframes(framenum[6])


func define_anims(unit_name, attacks):
	var player = get_node("AnimationPlayer")
	
	player.play("BasePose")
	player.play(str(unit_name, "_create"))
	
	player.rename_animation(str(unit_name, "_idle"), "idle")
	player.rename_animation(str(unit_name, "_walk"), "walk")
	player.rename_animation(str(unit_name, "_hit"), "hit")
	player.rename_animation(str(unit_name, "_die"), "die")
	
	for atk in attacks:
		player.rename_animation(str(unit_name, "_", atk), atk)
	
	player.play("idle")