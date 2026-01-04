extends Node

class_name StateManager

@export var initialState : Node
signal Transitioned(oldState:State, newState:State)
# the current active state of the state manager
var currentState : Node

func _ready():
	# add the state manager to all states in its domain
	for child in get_children():
		if child is State:
			child.state_manager = self
	
	# enter into the initial state if one is defined
	if initialState:
		initialState.__internal__Enter.call_deferred(initialState)
		currentState = initialState
		print("Initial state %s entered" % initialState.name)


func TransitionStates(old_state:State, new_state:State) -> void:
	# Handle a transition from the old_state to the new_state,
	# including calling exit on the old_state and enter on the new_state
	currentState = new_state
	old_state.__internal__Exit(new_state)
	new_state.__internal__Enter(old_state)
	Transitioned.emit(old_state, new_state)


func _process(delta):
	# run internal update function on only the current state
	if currentState:
		currentState.__internal__Update(delta)


func _physics_process(delta):
	# run internal physics update function on only the current state
	if currentState:
		currentState.__internal__PhysicsUpdate(delta)
