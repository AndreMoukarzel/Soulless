extends Node

signal done

var t1
var t2
var ts
var regular = false
var super = false # Used a riskier button, with more precise timing than regular hit


func start(max_time, min_time = max_time - 0.12, super_time = max_time - 0.05):
	t1 = min_time
	t2 = max_time
	ts = super_time
	
	get_node("Timer").set_wait_time(max_time)
	get_node("Timer").start()
	set_process_input(true)


func _input(event):
	var t = get_node("Timer").time_left
	t = t2 - t # because timer goes backwards
	
	if event.is_action_pressed("ui_accept"):
		if t >= t1 and t <= t2:
			regular = true
		set_process_input(false)
	elif event.is_action_pressed("ui_cancel"):
		if t >= ts and t <= t2:
			super = true
		set_process_input(false)


func _on_Timer_timeout():
	emit_signal("done")
	set_process_input(false)