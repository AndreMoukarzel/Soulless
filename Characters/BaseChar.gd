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
onready var HPmax = HP

func _ready():
	set_scale(Vector2(Size, Size))

# Invert should be true if unit is on Allies team
func set_HPBar(invert):
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

func update_HPBar(new_value):
	var Twn = $"HPBar/Tween"
	Twn.interpolate_property($HPBar, "value", $HPBar.get_value(), new_value, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	Twn.start()
	$"HPBar/Label".set_text(str(HP, "/", HPmax))

func get_damaged(damage, play_anim = true):
	HP -= int(damage)
	update_HPBar(HP)
	if play_anim:
		play_animation("hit")
		yield($AnimationPlayer, "animation_finished")
		play_animation("idle")
	if HP <= 0:
		die()

func defend(base_damage, percentage_of_damage_taken):
	get_damaged(base_damage * percentage_of_damage_taken, false)
	play_animation("defend")
	yield($AnimationPlayer, "animation_finished")
	if HP > 0:
		play_animation("idle")

func dodge():
	flip()
	yield($Tween, "tween_completed")
	flip()

func flee():
	flip()
	get_node("AnimationPlayer").play("walk")

func die():
	play_animation("died")
	emit_signal("died")

func play_animation(name):
	get_node("AnimationPlayer").play(name)

func flip():
	var end_scale = Vector2(1, 1)
	if $Body.scale.x > 0:
		end_scale = Vector2(-1, 1)
	$Tween.interpolate_property($Body, "scale", $Body.get_scale(), end_scale, FLIPTIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
