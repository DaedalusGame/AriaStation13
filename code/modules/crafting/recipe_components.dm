datum/assemblerprint
	magnet
		typepath = /obj/item/weapon/stock_parts/scrap/magnet
		simplicity = 100
		liquidcomponents = list("iron" = 50)
		duration = 10
		powerusage = 20

	bolt
		typepath = /obj/item/weapon/stock_parts/scrap/bolt
		simplicity = 100
		liquidcomponents = list("iron" = 10)
		duration = 5
		powerusage = 5

	spring
		typepath = /obj/item/weapon/stock_parts/scrap/spring
		simplicity = 100
		liquidcomponents = list("iron" = 10)
		duration = 5
		powerusage = 5

	slide
		typepath = /obj/item/weapon/stock_parts/scrap/slide
		simplicity = 100
		liquidcomponents = list("iron" = 10)
		duration = 5
		powerusage = 5

	lens
		typepath = /obj/item/weapon/stock_parts/scrap/lens
		simplicity = 100
		liquidcomponents = list("glass" = 5)
		duration = 5
		powerusage = 5

	vacuum
		typepath = /obj/item/weapon/stock_parts/scrap/vacuum
		simplicity = 100
		liquidcomponents = list("glass" = 50,"iron" = 50,"copper" = 20,"gold" = 10)
		duration = 50
		powerusage = 100

	piston
		typepath = /obj/item/weapon/stock_parts/scrap/piston
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/spring,
		/obj/item/weapon/stock_parts/scrap/slide)
		liquidcomponents = list("iron" = 50)
		duration = 25
		powerusage = 5

	tape
		typepath = /obj/item/weapon/stock_parts/scrap/tape
		simplicity = 100
		liquidcomponents = list("iron" = 20)
		duration = 5
		powerusage = 20

	capacitor
		typepath = /obj/item/weapon/stock_parts/capacitor
		simplicity = 100
		liquidcomponents = list("copper" = 10,"iron" = 15,"glass" = 5)
		duration = 50
		powerusage = 30

	matterbin
		typepath = /obj/item/weapon/stock_parts/matter_bin
		simplicity = 100
		liquidcomponents = list("iron" = 30,"glass" = 10)
		duration = 50
		powerusage = 30

	manipulator
		typepath = /obj/item/weapon/stock_parts/manipulator
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/magnet)
		liquidcomponents = list("iron" = 15,"glass" = 5)
		duration = 50
		powerusage = 30

	microlaser
		typepath = /obj/item/weapon/stock_parts/micro_laser
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/lens)
		liquidcomponents = list("iron" = 10,"glass" = 5)
		duration = 60
		powerusage = 80

	scanning_module
		typepath = /obj/item/weapon/stock_parts/scanning_module
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/ribbon)
		liquidcomponents = list("iron" = 20,"glass" = 10)
		duration = 60
		powerusage = 80

	coppercoil
		typepath = /obj/item/weapon/stock_parts/scrap/coppercoil
		simplicity = 100
		liquidcomponents = list("copper" = 50)
		duration = 10
		powerusage = 5

	ribbon
		typepath = /obj/item/weapon/stock_parts/scrap/ribbon
		simplicity = 100
		liquidcomponents = list("copper" = 10,"rubber" = 5)
		duration = 5
		powerusage = 5

	cablecoil
		typepath = /obj/item/weapon/cable_coil
		simplicity = 100
		liquidcomponents = list("copper" = 20,"rubber" = 10)
		duration = 5
		powerusage = 5

	frame
		typepath = /obj/item/weapon/stock_parts/scrap/pdaframe
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/ribbon,
		/obj/item/weapon/stock_parts/scrap/slide)
		liquidcomponents = list("iron" = 50)
		duration = 25
		powerusage = 5

	pdascreen
		typepath = /obj/item/weapon/stock_parts/scrap/pdascreen
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/ribbon)
		liquidcomponents = list("glass" = 15)
		duration = 25
		powerusage = 5

	signaler
		typepath = /obj/item/device/assembly/signaler
		components = list(/obj/item/weapon/stock_parts/scrap/pdascreen,
		/obj/item/weapon/stock_parts/scrap/pdaframe,
		/obj/item/weapon/stock_parts/scrap/tape)
		liquidcomponents = list("glass" = 5,"copper" = 10)
		duration = 50
		powerusage = 100
		simplicity = 100

	infra
		typepath = /obj/item/device/assembly/infra
		components = list(/obj/item/weapon/stock_parts/scrap/lens)
		liquidcomponents = list("glass" = 5,"iron" = 10)
		duration = 50
		powerusage = 100
		simplicity = 100

	prox_sensor
		typepath = /obj/item/device/assembly/prox_sensor
		liquidcomponents = list("glass" = 5,"iron" = 10)
		duration = 50
		powerusage = 100
		simplicity = 100

	timer
		typepath = /obj/item/device/assembly/timer
		liquidcomponents = list("glass" = 10,"iron" = 10)
		duration = 50
		powerusage = 100
		simplicity = 100

	igniter
		typepath = /obj/item/device/assembly/igniter
		liquidcomponents = list("glass" = 10,"iron" = 10,"plasma" = 5)
		duration = 50
		powerusage = 100
		simplicity = 100

	meson
		typepath = /obj/item/weapon/stock_parts/scrap/meson
		simplicity = 70
		components = list(/obj/item/weapon/ore/gem/meson,/obj/item/weapon/stock_parts/scrap/slide)
		liquidcomponents = list("glass" = 50)
		duration = 50
		powerusage = 100

	thermal
		typepath = /obj/item/weapon/stock_parts/scrap/thermal
		simplicity = 70
		components = list(/obj/item/weapon/ore/gem/thermal,/obj/item/weapon/stock_parts/scrap/slide)
		liquidcomponents = list("glass" = 50)
		duration = 50
		powerusage = 100

	teleport
		typepath = /obj/item/weapon/stock_parts/scrap/teleport
		simplicity = 50
		components = list(/obj/item/weapon/ore/gem/megalith,
		/obj/item/weapon/stock_parts/scrap/vacuum,
		/obj/item/weapon/stock_parts/scrap/vacuum)
		liquidcomponents = list("diamond" = 5,"gold" = 10,"silver" = 10)
		duration = 600
		powerusage = 4000

	bombassembly
		typepath = /obj/item/device/bombassembly
		simplicity = 70
		components = list(/obj/item/weapon/stock_parts/scrap/spring,
		/obj/item/weapon/stock_parts/scrap/slide)
		liquidcomponents = list("iron" = 100)
		duration = 50
		powerusage = 100

	corobomb
		typepath = /obj/item/device/bombassembly/done
		simplicity = 70
		components = list(/obj/item/device/bombassembly,
		/obj/item/weapon/ore/gem/coronium,
		/obj/item/weapon/ore/gem/coronium)
		liquidcomponents = list("water" = 100)
		duration = 50
		powerusage = 100

	pda
		typepath = /obj/item/device/pda
		components = list(/obj/item/weapon/stock_parts/scrap/pdascreen,
		/obj/item/weapon/stock_parts/scrap/pdaframe,
		/obj/item/weapon/stock_parts/scrap/tape)
		duration = 50
		powerusage = 100
		simplicity = 80

	deployframe
		typepath = /obj/item/weapon/deployframe
		components = list(/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/metal)
		liquidcomponents = list("glass" = 100)
		duration = 60
		powerusage = 100
		simplicity = 95

	liquidtank
		typepath = /obj/machinery/liquidtank
		components = list(/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/glass)
		liquidcomponents = list("diamond" = 10,"coalfiber" = 80)
		duration = 120
		powerusage = 800
		simplicity = 85
		deploy = 1

	smes
		typepath = /obj/machinery/power/smes
		components = list(/obj/item/stack/rods,
		/obj/item/weapon/stock_parts/scrap/ribbon,
		/obj/item/weapon/stock_parts/scrap/vacuum,
		/obj/item/weapon/stock_parts/scrap/vacuum,
		/obj/item/weapon/stock_parts/scrap/coppercoil)
		liquidcomponents = list("iron" = 100,"coalfiber" = 80,"copper" = 80)
		duration = 120
		powerusage = 800
		simplicity = 70
		deploy = 1

	massdriver
		typepath = /obj/machinery/mass_driver
		components = list(/obj/item/weapon/stock_parts/scrap/magnet,
		/obj/item/weapon/stock_parts/scrap/piston,
		/obj/item/weapon/stock_parts/scrap/piston,
		/obj/item/weapon/stock_parts/scrap/coppercoil,
		/obj/item/weapon/deployframe)
		liquidcomponents = list("iron" = 100)
		duration = 120
		powerusage = 800
		simplicity = 80
		deploy = 1