extends Node

signal done

const EXTRA = 0.12 # Extra time to make success a little easier

var holdt
var Atkr
var atk_name
var multiplier = 0.0 # If not success, the closer to succes the higher the damage, to a max of 0.8
var success = false


func start(hold_time, Attacker, attack_name):
	holdt = hold_time + EXTRA
	Atkr = Attacker
	atk_name = attack_name
	$Timer.set_wait_time(holdt)
	$HoldReleaseVisual.set_position(Attacker.get_global_position() - Vector2(150, 0))
	set_physics_process(false)
	if Input.is_action_pressed("ui_left"):
		begin()

func begin():
	Atkr.play_animation(atk_name)
	$HoldReleaseVisual.start(holdt - EXTRA)
	$Timer.start()
	set_physics_process(true)
	set_process_input(false)

func _input(event):
	if event.is_action_pressed("ui_left"):
		begin()

func _physics_process(delta):
	if Input.is_action_just_released("ui_left"):
		var t = $Timer.time_left
		
		if t <= EXTRA * 2: # EXTRA is doubled here so player have success margin before and after hit time
			success = true
		else:
			too_early()
			if t < EXTRA * 2.5:
				multiplier = 0.8
			elif t < EXTRA * 4:
				multiplier = 0.5
			else:
				multiplier = 0.3
		set_physics_process(false)

func too_early():
	$Buzz.play()
	$HoldReleaseVisual/Timer.stop()
	$HoldReleaseVisual._on_Timer_timeout()

func _on_Timer_timeout():
	set_physics_process(false)
	emit_signal("done")