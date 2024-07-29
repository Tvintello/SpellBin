extends VBoxContainer


var draw_menu : Control


func _ready():
	var file = FileAccess.open("res://src/spell/scripts/test.gd", FileAccess.WRITE)
	file.store_string("extends Node\nvar box = 5\nfunc _process(delta):\n	print(box)")
	
	%ManaConduitBtn.pressed.connect(_mana_conduit_pressed) 
	%ManaCollectorBtn.pressed.connect(_mana_collector_pressed)
	%SpellCircle.button_down.connect(_spell_circle_pressed)
	
	
func _spell_circle_pressed():
	if %SpellCircle.get_child(0).visible:
		%SpellCircle.get_child(0).visible = false
	else:
		%SpellCircle.get_child(0).visible = true
	#if draw_menu:	
		#var spell = Spell.new()
		#var index = FileManager.count_match(SpellCircle.circle_texture_dir, 
											#"untitled")
											#
		#var spell_dict = {
			#"name": "untitled" + index if index else "",
			#"description": %Description.text,
			#"circle_image": "res://assets/textures/drawings/magic_circle/empty_circle.png",
			#"inner_radius": 20,
			#"outer_radius": 60,
			#"commands": Spell.compile(%TextEdit.text)
		#}
		#spell.commands = 
		#spell.circle_radius = 120 * 4
			#
		#draw_menu.draw_mode.create_instance(PlaceableSpellCircle, {"spell": spell})
		#draw_menu.close()
		#draw_menu.draw_mode.open()
		
		
func _mana_collector_pressed():
	if draw_menu:
		draw_menu.draw_mode.create_instance(ManaCollector, {})
		draw_menu.close()
		draw_menu.draw_mode.open()
		
		
func _mana_conduit_pressed():
	if draw_menu:
		draw_menu.draw_mode.create_instance(ManaConduit, {})
		draw_menu.close()
		draw_menu.draw_mode.open()
