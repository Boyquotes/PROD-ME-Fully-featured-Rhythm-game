extends Node

func read_json_file(file_path):
	var file = File.new()
	if not file.file_exists(file_path):
		print("File not found!", file_path)
		return 

	if file.open(file_path, File.READ) != OK:
		print("File openning error!", file_path)
		return 

	if not file.get_as_text():
		print("File is empty!", file_path)
		return 

	var json = JSON.parse(file.get_as_text())
	if json.error != OK:
		print("File JSON parse error!", file_path)
		return 

	return json.result
	
func write_json_file(file_path, data):
	var file = File.new()
	if file.open(file_path, File.WRITE) != OK:
		print("File cant be opened to write", file_path)
		return 
		
	file.store_line(JSON.print(data))
	file.close()
