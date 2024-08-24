extends Resource
class_name ResourceList

signal resource_loaded(list: Array)

@export_dir var resource_dir: String

var resource_list: Array

func _init() -> void:
	call_deferred("ready")

func ready() -> void:
	for fileName in DirAccess.get_files_at(resource_dir):
		# Regex Replace is weird.
		fileName = fileName.replace('.import', '')
		fileName = fileName.replace('.remap', '')
		var res: Resource = load(resource_dir + '/' + fileName)
		resource_list.push_back(res)

	resource_loaded.emit(resource_list)
