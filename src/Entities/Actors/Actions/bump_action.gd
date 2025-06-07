class_name BumpAction
extends ActionWithDirection
# Action -> ActionWithDirtection -> BumpAction


func perform() -> void:
	# Determines if we are going to bump (attack) a location or move to a location
	if get_target_actor():
		MeleeAction.new(entity, offset.x, offset.y).perform()
	else:
		MovementAction.new(entity, offset.x, offset.y).perform()
