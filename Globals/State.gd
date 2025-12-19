extends Node

class_name State

var state_manager : StateManager

func __internal__Enter(old_state:State) -> void:
	# called when the state is entered
	pass
	

func __internal__Exit(new_state:State) -> void:
	# called when the state is exited
	pass


func __internal__Update(delta) -> void:
	pass
	

func __internal__PhysicsUpdate(delta) -> void:
	pass
	
