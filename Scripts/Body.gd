
extends Node2D


func define_unit(unit_name, attacks):
	define_anims(unit_name, attacks)
	# definir sons


func define_anims(unit_name, attacks):
	var player = get_node("AnimationPlayer")
	
	player.play("BasePose")
	player.play(str(unit_name, "_create"))
	
	player.rename_animation(str(unit_name, "_idle"), "idle")
	player.rename_animation(str(unit_name, "_walk"), "walk")
	player.rename_animation(str(unit_name, "_hit"), "hit")
	player.rename_animation(str(unit_name, "_defend"), "defend")
	player.rename_animation(str(unit_name, "_die"), "die")
	
	for atk in attacks:
		player.rename_animation(str(unit_name, "_", atk), atk)
	
	player.play("idle")