extends Node
# class parent for extending into states

class_name State

# reference to the state manager for this state
var state_manager : StateManager

func __internal__Enter(old_state:State) -> void:
	# called when the state is entered
	pass
	

func __internal__Exit(new_state:State) -> void:
	# called when the state is exited
	pass


func __internal__Update(delta) -> void:
	# called during each _process but only on an active state
	pass
	

func __internal__PhysicsUpdate(delta) -> void:
	# called during each _physics_process but only on an active state
	pass
	
