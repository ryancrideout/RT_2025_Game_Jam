extends TextureProgressBar

func _ready():
	call_deferred("initialize_progress_bar")

func initialize_progress_bar():
	# Get the root node of the Reaper UI scene
	var reaper_root = get_node("/root/Game/GameManager/GrimReaper")  # Adjust this path to match your hierarchy
	print("Reaper root: ", reaper_root)
	if not reaper_root:
		print("ERROR: Reaper UI root not found!")
		return

	# Navigate to the SkeletonAgent's Resources node from the Reaper UI root
	var skeleton_agent_resources = reaper_root.get_parent().get_node("SkeletonAgent/Resources")
	if not skeleton_agent_resources:
		print("ERROR: SkeletonAgent Resources node not found!")
		return

	# Connect the resource_changed signal
	skeleton_agent_resources.connect("resource_changed", Callable(self, "_on_secondary_resource_changed"))

func _on_secondary_resource_changed(resource_type, new_value):

	if resource_type == "secondary":
		value = new_value
