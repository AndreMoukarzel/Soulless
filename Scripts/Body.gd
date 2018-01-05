
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
	get_node("Torso/Head").set_texture(load(str(folder, "head.png")))
	get_node("Torso/Head/EarFront").set_texture(load(str(folder, "ear.png")))
	get_node("Torso/Head/EarBack").set_texture(load(str(folder, "ear.png")))
	get_node("Torso/ArmFront").set_texture(load(str(folder, "arm.png")))
	get_node("Torso/ArmFront/Hand").set_texture(load(str(folder, "hand.png")))
	get_node("Torso/ArmBack").set_texture(load(str(folder, "arm.png")))
	get_node("Torso/ArmBack/Hand").set_texture(load(str(folder, "hand.png")))
	get_node("Torso/FootFront").set_texture(load(str(folder, "foot.png")))
	get_node("Torso/FootBack").set_texture(load(str(folder, "foot.png")))
	get_node("Torso/Tail").set_texture(load(str(folder, "tail.png")))


func define_anims(folder):
	var player = get_node("AnimationPlayer")
	
	player.add_animation("idle", load(str(folder, "idle.tres")))
	player.add_animation("melee", load(str(folder, "melee.tres")))
	
	player.play("idle")