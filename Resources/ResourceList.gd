extends Resource
class_name ResourceList

@export_dir var resource_dir: String

var resource_list: Array

func _init() -> void:
	call_deferred("ready")

func ready() -> void:
	for fileName in DirAccess.get_files_at(self.resource_dir):
		resource_list.push_back(load(self.resource_dir + '/' + fileName))
