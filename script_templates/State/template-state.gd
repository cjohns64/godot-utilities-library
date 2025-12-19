extends State

func __internal__Enter(old_state:State) -> void:
	super(old_state)
	
func __internal__Exit(new_state:State) -> void:
	super(new_state)
	
func __internal__Update(_delta) -> void:
	super(_delta)

func __internal__PhysicsUpdate(_delta) -> void:
	super(_delta)
