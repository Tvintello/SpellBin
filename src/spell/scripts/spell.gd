class_name Spell extends Node3D


const computation_symbols = ["+", "-", "*", "/", "(", ")"]
const functions = ["create"]

var instance
var spell_name : String
var commands : Array  # [[command_name, {pars}], [command_name, {pars}]]

@onready var file_type : String = ".png"
@onready var basic_proj = preload("res://src/projectile/scenes/projectile.tscn")


static func compile(text: String):
	# Compiling a text to a set of commands that can be used at any time
	var commands : Array  # [[command_name, {pars}], [command_name, {pars}]]
	var stack : String
	var word : String
	var type : int # 0 - function; 1 - property name; 2 - value
	var command : Array
	var pars : Dictionary
	var prev_word : String
	
	for char in text:
		char
	
	#for char in text:
		#if char.is_valid_int() or char in computation_symbols \
				#or char.is_valid_float():
			#if not stack:
				#word = ""
			#stack += char
		#elif stack and char != " ":
			#var exp = Expression.new()
			#var error = exp.parse(stack)
			#if error != OK:
				#push_error(exp.get_error_text())
				#break
			#var result = exp.execute()
			#if not exp.has_execute_failed():
				#pars[prev_word] = str(result)
				#prev_word = str(result)
				#word = char
				#type = 1
			#stack = ""
		##elif char == ":":
			##if word:
				### word:      future word
				##if word in functions:
					##type = 0  # function
			##else:
				### prev_word  :  future_word
				##if prev_word in functions:
					##type = 0
		#elif char != " ":
			## found a part of the word
			#word += char
		#elif char == " " and word:
			## the word finding is ended
			#if word in functions:
				#type = 0
			#if type == 0:
				## if type == function
				#command.append(word)
				#prev_word = word
				#word = ""
				#type = 1
			#elif type == 1:
				## if type == property_name
				#prev_word = word
				#word = ""
				#type = 2
			#elif type == 2:
				## if type == property_value
				#pars[prev_word] = word
				#prev_word = word
				#word = ""
				#type = 1
				#command.insert(1, pars)
				#
	#commands.append(command)
				#
	#return commands
		

func execute():
	for com in commands:
		call(com[0], com[1])
	if basic_proj:	
		instance = basic_proj.instantiate()
		instance.position = global_position
		instance.transform.basis = Basis(transform.basis)
		instance.direction = Vector3(0, 0, 1)
		instance.SPEED = 14
		Global.world.add_child(instance)


func create(pars: Dictionary):
	var ins = MeshInstance3D.new()
	var mesh_name = pars["shape"].capitalize() + "Mesh"
	if not mesh_name in ClassDB.get_inheriters_from_class(&"PrimitiveMesh"):
		return
		
	for m in ClassDB.get_inheriters_from_class(&"PrimitiveMesh"):
		if m == mesh_name:
			# ClassDB.get_properties()
			ins.mesh = ClassDB.instantiate(m)
			break
			
	add_child(ins)
	print(get_children())
