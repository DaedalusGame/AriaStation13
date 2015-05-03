datum/assemblerprint/mining
	tech = "mining"

	shovel
		typepath = /obj/item/weapon/shovel
		simplicity = 100
		liquidcomponents = list("iron" = 100)
		duration = 100
		powerusage = 400

	pickaxe
		typepath = /obj/item/weapon/pickaxe
		simplicity = 100
		liquidcomponents = list("iron" = 200)
		duration = 100
		powerusage = 400

	pickaxe_silver
		typepath = /obj/item/weapon/pickaxe/silver
		simplicity = 95
		liquidcomponents = list("iron" = 100, "silver" = 100)
		duration = 200
		powerusage = 800

	pickaxe_gold
		typepath = /obj/item/weapon/pickaxe/gold
		simplicity = 90
		liquidcomponents = list("iron" = 100, "gold" = 100)
		duration = 400
		powerusage = 1600

	pickaxe_diamond
		typepath = /obj/item/weapon/pickaxe/diamond
		simplicity = 85
		liquidcomponents = list("iron" = 100, "diamond" = 100)
		duration = 800
		powerusage = 3200

	drill
		typepath = /obj/item/weapon/pickaxe/drill
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/capacitor)
		liquidcomponents = list("iron" = 200)
		duration = 800
		powerusage = 3200

	drill_diamond
		typepath = /obj/item/weapon/pickaxe/diamonddrill
		simplicity = 80
		components = list(/obj/item/weapon/stock_parts/capacitor)
		liquidcomponents = list("iron" = 100, "diamond" = 100)
		duration = 1600
		powerusage = 6400

	jackhammer
		typepath = /obj/item/weapon/pickaxe/jackhammer
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/piston)
		liquidcomponents = list("iron" = 300)
		duration = 1000
		powerusage = 4000