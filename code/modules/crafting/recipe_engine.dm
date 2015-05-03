datum/assemblerprint/engine
	tech = "engineering"

	crowbar
		typepath = /obj/item/weapon/crowbar
		simplicity = 100
		liquidcomponents = list("iron" = 10)
		duration = 30
		powerusage = 25

	screwdriver
		typepath = /obj/item/weapon/screwdriver
		simplicity = 100
		liquidcomponents = list("iron" = 5)
		duration = 30
		powerusage = 25

	wirecutters
		typepath = /obj/item/weapon/wirecutters
		simplicity = 100
		liquidcomponents = list("iron" = 10)
		duration = 30
		powerusage = 25

	wrench
		typepath = /obj/item/weapon/wrench
		simplicity = 100
		liquidcomponents = list("iron" = 12)
		duration = 30
		powerusage = 25

	weldingtool
		typepath = /obj/item/weapon/weldingtool
		simplicity = 100
		liquidcomponents = list("iron" = 38,"fuel" = 20)
		duration = 30
		powerusage = 25

	weldpack
		typepath = /obj/item/weapon/weldpack
		simplicity = 90
		liquidcomponents = list("iron" = 72,"fuel" = 350)
		duration = 60
		powerusage = 50

	multitool
		typepath = /obj/item/device/multitool
		simplicity = 100
		liquidcomponents = list("iron" = 10,"copper" = 2,"glass" = 5)
		duration = 30
		powerusage = 25

	portalathe
		typepath = /obj/item/device/portalathe
		simplicity = 80
		components = list(/obj/item/weapon/stock_parts/scrap/teleport,
		/obj/item/weapon/cell)
		liquidcomponents = list("iron" = 25,"copper" = 10,"glass" = 20)
		duration = 120
		powerusage = 100

	t_scanner
		typepath = /obj/item/device/t_scanner
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/meson)
		liquidcomponents = list("iron" = 10,"copper" = 2,"glass" = 5)
		duration = 30
		powerusage = 25

	cell_crap
		typepath = /obj/item/weapon/cell/crap
		simplicity = 100
		liquidcomponents = list("copper" = 10,"plasma" = 5)
		duration = 60
		powerusage = 50

	cell
		typepath = /obj/item/weapon/cell
		simplicity = 100
		liquidcomponents = list("iron" = 10,"acid" = 10,"copper" = 5)
		duration = 70
		powerusage = 100

	cell_high
		typepath = /obj/item/weapon/cell/high
		simplicity = 85
		components = list(/obj/item/weapon/stock_parts/capacitor)
		liquidcomponents = list("iron" = 15,"acid" = 15,"copper" = 7)
		duration = 80
		powerusage = 200

	cell_super
		typepath = /obj/item/weapon/cell/super
		simplicity = 70
		components = list(/obj/item/weapon/stock_parts/capacitor/adv)
		liquidcomponents = list("iron" = 20,"pacid" = 10,"gold" = 7)
		duration = 90
		powerusage = 400

	cell_hyper
		typepath = /obj/item/weapon/cell/hyper
		simplicity = 55
		components = list(/obj/item/weapon/stock_parts/capacitor/super)
		liquidcomponents = list("iron" = 20,"uranium" = 10,"gold" = 10)
		duration = 100
		powerusage = 800

	module_airlock
		typepath = /obj/item/weapon/airlock_electronics
		simplicity = 100
		components = list()
		liquidcomponents = list("glass" = 20,"copper" = 5)
		duration = 70
		powerusage = 75

	module_card
		typepath = /obj/item/weapon/module/card_reader
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/beam)
		liquidcomponents = list("glass" = 20,"copper" = 10)
		duration = 70
		powerusage = 75

	module_cell
		typepath = /obj/item/weapon/module/cell_power
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/coppercoil)
		liquidcomponents = list("glass" = 20,"copper" = 10)
		duration = 70
		powerusage = 75

	module_id
		typepath = /obj/item/weapon/module/id_auth
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/beam)
		liquidcomponents = list("glass" = 20,"copper" = 10)
		duration = 70
		powerusage = 75

	module_power
		typepath = /obj/item/weapon/module/power_control
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/capacitor)
		liquidcomponents = list("glass" = 20,"copper" = 10)
		duration = 70
		powerusage = 75