extends Node

class_name StateManager

@export var initialState : Node
signal Transitioned(oldState:State, newState:State)
var currentState : Node

func _ready():
	for child in get_children():
		if child is State:
			child.state_manager = self
	
	if initialState:
		initialState.__internal__Enter.call_deferred(initialState)
		currentState = initialState
		print("Initial state %s entered" % initialState.name)


func TransitionStates(old_state:State, new_state:State) -> void:
	currentState = new_state
	old_state.__internal__Exit(new_state)
	new_state.__internal__Enter(old_state)
	Transitioned.emit(old_state, new_state)


func _process(delta):
	if currentState:
		currentState.__internal__Update(delta)


func _physics_process(delta):
	if currentState:
		currentState.__internal__PhysicsUpdate(delta)
