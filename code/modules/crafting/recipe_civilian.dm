datum/assemblerprint/civil
	tech = "civilian"

	taperecorder
		typepath = /obj/item/device/taperecorder
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/tape,
		/obj/item/weapon/stock_parts/scrap/tape)
		liquidcomponents = list("iron" = 10,"copper" = 2,"glass" = 5)
		duration = 30
		powerusage = 25

	bulb
		typepath = /obj/item/weapon/light/bulb
		simplicity = 100
		components = list()
		liquidcomponents = list("glass" = 5)
		duration = 30
		powerusage = 25
		tech = ""

	tube
		typepath = /obj/item/weapon/light/tube
		simplicity = 100
		components = list()
		liquidcomponents = list("glass" = 10)
		duration = 50
		powerusage = 40
		tech = ""

	largetube
		typepath = /obj/item/weapon/light/tube/large
		simplicity = 100
		components = list()
		liquidcomponents = list("glass" = 20)
		duration = 70
		powerusage = 55
		tech = ""

	flashlight
		typepath = /obj/item/device/flashlight
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/lens,
		/obj/item/weapon/cell/crap)
		liquidcomponents = list("iron" = 7,"copper" = 2,"glass" = 5)
		duration = 30
		powerusage = 25
		tech = ""

	destTagger
		typepath = /obj/item/device/destTagger
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/pdaframe)
		liquidcomponents = list("copper" = 2,"glass" = 5)
		duration = 30
		powerusage = 25

	hand_labeler
		typepath = /obj/item/weapon/hand_labeler
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/pdaframe)
		liquidcomponents = list("copper" = 2,"glass" = 5)
		duration = 30
		powerusage = 25

	pda
		typepath = /obj/item/device/pda
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/pdaframe,
		/obj/item/weapon/stock_parts/scrap/pdascreen)
		liquidcomponents = list("copper" = 2,"glass" = 5)
		duration = 30
		powerusage = 25

	radio
		typepath = /obj/item/device/radio
		simplicity = 100
		components = list(/obj/item/weapon/stock_parts/scrap/pdaframe,
		/obj/item/device/assembly/signaler)
		liquidcomponents = list("copper" = 2,"glass" = 5)
		duration = 30
		powerusage = 25
		tech = ""

	headset
		typepath = /obj/item/device/radio/headset
		simplicity = 100
		components = list(/obj/item/device/assembly/signaler)
		liquidcomponents = list("iron" = 7,"copper" = 2,"glass" = 5)
		duration = 30
		powerusage = 25

	bucket
		typepath = /obj/item/weapon/reagent_containers/glass/bucket
		simplicity = 100
		liquidcomponents = list("iron" = 12)
		duration = 45
		powerusage = 42

	cantister
		typepath = /obj/item/weapon/reagent_containers/glass/cantister
		simplicity = 100
		liquidcomponents = list("iron" = 20)
		duration = 60
		powerusage = 50

	extinguisher
		typepath = /obj/item/weapon/extinguisher
		simplicity = 100
		liquidcomponents = list("iron" = 20,"water" = 50)
		duration = 60
		powerusage = 50
		tech = ""