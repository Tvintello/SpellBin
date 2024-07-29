extends Node


func is_in_dir(dir_path: String, file_name: String) -> bool:
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var f = dir.get_next()
		while f != "":
			if not dir.current_is_dir() and f == file_name:
				return true
				
			f = dir.get_next()
		return false
	else:
		push_error("An error occurred when trying to access the path.")
		return false
		
		
func read_dir(dir_path: String, only_files: bool = true) -> Array:
	var dir = DirAccess.open(dir_path)
	var list = []
	if dir:
		dir.list_dir_begin()
		var f = dir.get_next()
		while f != "":
			if only_files and not dir.current_is_dir():
				list.append(load(dir_path + f))
			elif not only_files:
				list.append(load(dir_path + f))
			f = dir.get_next()
		return list
	else:
		push_error("An error occurred when trying to access the path.")
		return []
		
		
func count_match(dir_path: String, match_string: String, leave_import := true,
				 only_files := true) -> int:
	var dir = DirAccess.open(dir_path)
	var count = 0
	if dir:
		dir.list_dir_begin()
		var f = dir.get_next()
		while f != "":
			if only_files and not dir.current_is_dir() and f == match_string:
				count += 1
			elif not only_files and f == match_string:
				count += 1
			f = dir.get_next()
		return count
	else:
		push_error("An error occurred when trying to access the path.")
		return 0
	
	
func load_json_file(file_path : String):
	if FileAccess.file_exists(file_path):
		var data = FileAccess.open(file_path, FileAccess.READ)
		var result = JSON.parse_string(data.get_as_text())
		
		return result
		
		
		
	
	
