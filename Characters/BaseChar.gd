extends Node2D

signal died

const FLIPTIME = 0.15

export(float, 0.1, 10.0, 0.1) var Size = 1.0
export(int) var HP = 1
export(int) var ATK = 1
export(int) var DEF = 1
export(String, "Bunny", "Mole", "Ent") var Race
export(String) var Signature1
export(String) var Signature2

var HpBar_scn = preload("res://Combat/HPBar.tscn")

func _ready():
	set_scale(Vector2(Size, Size))

# Invert should be true if unit is on Allies team
func set_HpBar(invert):
	var HpBar = HpBar_scn.instance()
	var scale = 1/Size
	
	if invert:
		HpBar.set_scale(Vector2(-scale, scale))
		HpBar.set_position(Vector2(50, 120))
	else:
		HpBar.set_scale(Vector2(scale, scale))
		HpBar.set_position(Vector2(-50, 120))
	HpBar.set_max(HP)
	HpBar.set_value(HP)
	HpBar.get_node("Label").set_text(str(HP, "/", HP))
	
	add_child(HpBar)

func get_damaged(damage, play_anim = true):
	HP -= int(damage)
	if play_anim:
		$AnimationPlayer.play("hit")
		yield($AnimationPlayer, "animation_finished")
	if HP <= 0:
		die()

func defend(base_damage, percentage_of_damage_taken):
	get_damaged(base_damage * percentage_of_damage_taken, false)
	$AnimationPlayer.play("defend")
	yield($AnimationPlayer, "animation_finished")

func flee():
	set_scale(Vector2(-Size, Size))
	get_node("AnimationPlayer").play("walk")

func die():
	$AnimationPlayer.play("die")
	emit_signal("died")

func play_animation(name):
	get_node("AnimationPlayer").play(name)

func flip():
	var end_scale = Vector2(1, 1)
	if $Body.scale.x > 0:
		end_scale = Vector2(-1, 1)
	$Tween.interpolate_property($Body, "scale", $Body.get_scale(), end_scale, FLIPTIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
