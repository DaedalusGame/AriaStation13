/obj/item/weapon/memory
	name = "data"
	desc = "What?"
	gender = PLURAL
	icon = 'stock_parts.dmi'
	w_class = 2.0
	var/space = 0
	var/obj/machine = null
	var/datum/file/folder/root = null
	var/list/programs = list()
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

		root = new("")

/obj/item/weapon/memory/harddrive
	name = "harddrive"
	desc = "Stores data on a magnetic disk."
	icon_state = "hdd1"
	origin_tech = "materials=1;programming=1"
	space = 5120
	g_amt = 200

	computer
		New()
			..()

/obj/item/weapon/memory/flashdrive
	name = "flashdrive"
	desc = "Stores data in a most portable way."
	icon_state = "flash"
	origin_tech = "materials=2;programming=1"
	space = 512
	g_amt = 100

/obj/machinery
	var/obj/item/weapon/memory/net_memory