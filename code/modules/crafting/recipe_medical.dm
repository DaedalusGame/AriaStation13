datum/assemblerprint/medical
	tech = "medical"

	beaker
		typepath = /obj/item/weapon/reagent_containers/glass/beaker
		simplicity = 100
		liquidcomponents = list("glass" = 10)
		duration = 30
		powerusage = 25

	largebeaker
		typepath = /obj/item/weapon/reagent_containers/glass/large
		simplicity = 100
		liquidcomponents = list("glass" = 20)
		duration = 60
		powerusage = 50

	syringe
		typepath = /obj/item/weapon/reagent_containers/syringe
		simplicity = 100
		liquidcomponents = list("glass" = 5)
		duration = 20
		powerusage = 30

	syringegun
		typepath = /obj/item/weapon/gun/syringe
		simplicity = 100
		liquidcomponents = list("glass" = 15,"iron" = 25)
		duration = 100
		powerusage = 90

	syringegun_rapid
		typepath = /obj/item/weapon/gun/syringe/rapidsyringe
		simplicity = 90
		components = list(/obj/item/weapon/gun/syringe,/obj/item/weapon/stock_parts/scrap/spring)
		liquidcomponents = list("iron" = 5)
		duration = 300
		powerusage = 100

	dropper
		typepath = /obj/item/weapon/reagent_containers/dropper
		simplicity = 100
		liquidcomponents = list("glass" = 2)
		duration = 10
		powerusage = 5

	scalpel
		typepath = /obj/item/weapon/scalpel
		simplicity = 100
		liquidcomponents = list("iron" = 10)
		duration = 40
		powerusage = 80

	saw
		typepath = /obj/item/weapon/circular_saw
		simplicity = 100
		liquidcomponents = list("iron" = 50)
		duration = 60
		powerusage = 180

	cautery
		typepath = /obj/item/weapon/cautery
		simplicity = 100
		liquidcomponents = list("iron" = 10)
		duration = 40
		powerusage = 80

	retractor
		typepath = /obj/item/weapon/retractor
		simplicity = 100
		liquidcomponents = list("iron" = 10)
		duration = 40
		powerusage = 80

	bonesetter
		typepath = /obj/item/weapon/surgical_tool/bonesetter
		simplicity = 100
		liquidcomponents = list("iron" = 10)
		duration = 40
		powerusage = 80

	drill
		typepath = /obj/item/weapon/surgicaldrill
		simplicity = 100
		liquidcomponents = list("iron" = 40)
		duration = 40
		powerusage = 80

	bruise_pack
		typepath = /obj/item/stack/medical/bruise_pack
		simplicity = 100
		liquidcomponents = list("fiber" = 10)
		duration = 10
		powerusage = 40

	ointment
		typepath = /obj/item/stack/medical/ointment
		simplicity = 100
		liquidcomponents = list("glass" = 5,"water" = 10)
		duration = 10
		powerusage = 40

	bruise_pack_adv
		typepath = /obj/item/stack/medical/advanced/bruise_pack
		simplicity = 100
		liquidcomponents = list("fiber" = 50)
		duration = 20
		powerusage = 600

	ointment_adv
		typepath = /obj/item/stack/medical/advanced/ointment
		simplicity = 100
		liquidcomponents = list("fiber" = 30,"glass" = 10,"water" = 10,"sodium" = 10)
		duration = 20
		powerusage = 600

	splint
		typepath = /obj/item/stack/medical/splint
		simplicity = 100
		liquidcomponents = list("fiber" = 30,"iron" = 5)
		duration = 10
		powerusage = 40