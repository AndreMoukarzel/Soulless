extends Node

signal done

var holdt
var Atkr
var atk_name
var success = false


func start(hold_time, Attacker, attack_name):
	holdt = hold_time + 0.12
	Atkr = Attacker
	atk_name = attack_name
	$Timer.set_wait_time(holdt)
	set_physics_process(false)
	if Input.is_action_pressed("ui_left"):
		begin()

func begin():
	Atkr.play_animation(atk_name)
	$Timer.start()
	set_physics_process(true)
	set_process_input(false)

func _input(event):
	if event.is_action_pressed("ui_left"):
		begin()

func _physics_process(delta):
	if Input.is_action_just_released("ui_left"):
		var t = $Timer.time_left
		
		if t <= 0.24:
			success = true
		set_physics_process(false)

func _on_Timer_timeout():
	set_physics_process(false)
	emit_signal("done")