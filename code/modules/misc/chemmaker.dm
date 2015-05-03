/obj/item/chemmaker
	var/chemid = "water"
	var/chemammount = 10
	icon = 'stock_parts.dmi'
	icon_state = "cartridge"
	invisibility = 101

	New()
		var/atom/A = loc
		if(A && A.reagents)
			A.reagents.add_reagent(chemid,chemammount)

	iron
		name = "200 units of Iron"
		chemid = "iron"
		chemammount = 200

	copper
		name = "100 units of Copper"
		chemid = "copper"
		chemammount = 100

	glass
		name = "200 units of Glass"
		chemid = "glass"
		chemammount = 200

	gold
		name = "200 units of Gold"
		chemid = "gold"
		chemammount = 200

	silver
		name = "200 units of Silver"
		chemid = "silver"
		chemammount = 200

	uranium
		name = "100 units of Uranium"
		chemid = "uranium"
		chemammount = 100

	diamond
		name = "100 units of Diamond"
		chemid = "diamond"
		chemammount = 100

	adamantine
		name = "100 units of Adamantine"
		chemid = "adamantine"
		chemammount = 100

	phazon
		name = "100 units of Phazon"
		chemid = "phazon"
		chemammount = 100

	plasma
		name = "200 units of Plasma"
		chemid = "plasma"
		chemammount = 200

	coalfiber
		name = "400 units of Carbonfiber"
		chemid = "coalfiber"
		chemammount = 400

	fiber
		name = "400 units of Fiber"
		chemid = "fiber"
		chemammount = 400

	rubber
		name = "400 units of Rubber"
		chemid = "rubber"
		chemammount = 400

	latex
		name = "400 units of Latex"
		chemid = "latex"
		chemammount = 400

	coal
		name = "100 units of Coal"
		chemid = "coal"
		chemammount = 100

