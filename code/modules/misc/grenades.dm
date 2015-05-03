/obj/item/weapon/chem_grenade/dirt
	name = "Dirty Grenade"
	desc = "From the makers of BLAM! brand foaming space cleaner, this bomb guarantees steady work for any janitor."
	active = 2
	path = 1

	New()
		..()
		attached_device = new /obj/item/device/assembly/timer(src)
		attached_device.master = src
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/list/muck = list("blood","carbon","flour","radium")
		var/filth = pick(muck - "radium") // not usually radioactive

		B1.reagents.add_reagent(filth,25)
		if(prob(25))
			B1.reagents.add_reagent(pick(muck - filth,25)) // but sometimes...

		beaker_one = B1
		icon_state = "chemg_locked"

/obj/item/weapon/chem_grenade/meat
	name = "Meat Grenade"
	desc = "Not always as messy as the name implies."
	active = 2
	path = 1

	New()
		..()
		attached_device = new /obj/item/device/assembly/timer(src)
		attached_device.master = src
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("blood",50)
		if(prob(5))
			B1.reagents.add_reagent("blood",1) // Quality control problems, causes a big mess
		B2.reagents.add_reagent("clonexadone",10)

		beaker_two = B1
		beaker_one = B2
		icon_state = "chemg_locked"

/*
/obj/item/weapon/grenade/chem_grenade/soap
	name = "Soap Grenade"
	desc = "Not necessarily as clean as the name implies."
	active = 2
	path = 1
	New()
		..()
		attached_device = new /obj/item/device/assembly/timer(src)
		attached_device.master = src
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("cornoil",60)
		B2.reagents.add_reagent("enzyme",5)
		B2.reagents.add_reagent("ammonia",30)

		beaker_two = B1
		beaker_one = B2
		icon_state = "chemg_locked"*/