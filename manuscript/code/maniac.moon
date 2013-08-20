class Maniac
	add_gun: (gun) ->
		table.insert @armory, gun

inv = Maniac!
inv\add_gun "bazooka"
