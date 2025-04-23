extends Node

signal resource_changed(resource_type, new_value)

# Resource variables
var PRIMARY_RESOURCE: int = 100
var SECONDARY_RESOURCE: int = 0

# Constants for resource costs
const UNIT_PRIMARY_COST: int = 10
const UNIT_SECONDARY_COST: int = 0

const OUTPOST_PRIMARY_COST: int = 100
const OUTPOST_SECONDARY_COST: int = 0

# Update primary resource value
func update_primary_resource(amount: int) -> bool:
	# If subtracting resources, check if there's enough
	if amount < 0 and PRIMARY_RESOURCE + amount < 0:
		#print("ERROR: Not enough PRIMARY_RESOURCE available. Current: ", PRIMARY_RESOURCE, ", Requested: ", -amount)
		return false
		
	# Update resource value
	PRIMARY_RESOURCE += amount
	# Ensure resource doesn't go below zero
	PRIMARY_RESOURCE = max(PRIMARY_RESOURCE, 0)

	# Emit signal for resource change
	emit_signal("resource_changed", "primary", PRIMARY_RESOURCE)

	return true

# Update secondary resource value
func update_secondary_resource(amount: int) -> bool:
	# If subtracting resources, check if there's enough
	if amount < 0 and SECONDARY_RESOURCE + amount < 0:
		#print("ERROR: Not enough SECONDARY_RESOURCE available. Current: ", SECONDARY_RESOURCE, ", Requested: ", -amount)
		return false
		
	# Update resource value
	SECONDARY_RESOURCE += amount
	# Ensure resource stays between 0 and 5000
	SECONDARY_RESOURCE = clamp(SECONDARY_RESOURCE, 0, 5000)

	# Emit signal for resource change
	emit_signal("resource_changed", "secondary", SECONDARY_RESOURCE)

	return true

# Check if there are enough resources to spawn a unit
func can_spawn_unit() -> bool:
	if PRIMARY_RESOURCE >= UNIT_PRIMARY_COST and SECONDARY_RESOURCE >= UNIT_SECONDARY_COST:
		return true
	else:
		#print("ERROR: Not enough resources to spawn unit.")
		#print("Required: ", UNIT_PRIMARY_COST, " PRIMARY, ", UNIT_SECONDARY_COST, " SECONDARY")
		#print("Available: ", PRIMARY_RESOURCE, " PRIMARY, ", SECONDARY_RESOURCE, " SECONDARY")
		return false

# Try to use resources to spawn a unit
func try_spawn_unit() -> bool:
	# First sequester (reserve) the resources temporarily
	var temp_primary = PRIMARY_RESOURCE
	var temp_secondary = SECONDARY_RESOURCE
	
	# Check if we have enough resources
	if temp_primary >= UNIT_PRIMARY_COST and temp_secondary >= UNIT_SECONDARY_COST:
		# Use the resources
		if update_primary_resource(-UNIT_PRIMARY_COST) and update_secondary_resource(-UNIT_SECONDARY_COST):
			return true
	
	return false

# Try to use resources to spawn a unit
func try_spawn_outpost() -> bool:
	# First sequester (reserve) the resources temporarily
	var temp_primary = PRIMARY_RESOURCE
	var temp_secondary = SECONDARY_RESOURCE
	
	# Check if we have enough resources
	if temp_primary >= OUTPOST_PRIMARY_COST and temp_secondary >= OUTPOST_SECONDARY_COST:
		# Use the resources
		if update_primary_resource(-OUTPOST_PRIMARY_COST) and update_secondary_resource(-OUTPOST_SECONDARY_COST):
			return true
	
	return false

# Get current resource values
func get_resources() -> Dictionary:
	return {
		"primary": PRIMARY_RESOURCE,
		"secondary": SECONDARY_RESOURCE
	}
