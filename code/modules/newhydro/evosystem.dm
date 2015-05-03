/obj/machinery/evogenerator
	name = "EVO-Generator"
	desc = ""
	icon = 'biogenerator.dmi'
	icon_state = "evogen-stand"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 40
	var/obj/plantcontainer = null	//Object that contains plant data like a seed or a fruit
	var/datum/seed/tempseed = null 	//Currently editing seed
	var/menustat = ""
	var/list/abilityunits = list("endurance" = 5,
							"yield" = 5,
							"potency" = 3,
							"sterilerate" = 5,
							"maturation" = 10,
							"lifespan" = 10,
							"drinkspeed" = 0.5,
							"waterrequirement" = 0.005,
							"nutrientrequirement" = 0.005)
	var/list/acceptedtypes = list(/obj/item/seed,/obj/item/weapon/reagent_containers/food/snacks/fruit)

	proc/get_evopanel(var/mob/user)
		if(!user) return

		var/dat = text("<HR>")
		dat += get_evopanel_line("Endurance","","endurance",1)
		dat += get_evopanel_line("Yield","","yield",1)
		dat += get_evopanel_line("Potency","","potency",1)
		dat += get_evopanel_line("Sterility","%","sterilerate",1)
		dat += get_evopanel_line("Maturation Age"," cycles","maturation",1)
		dat += get_evopanel_line("Total Lifespan"," cycles","lifespan",1)
		dat += get_evopanel_line("Drink Speed","","drinkspeed",1)
		dat += get_evopanel_line("Hydration Requirement"," units/decacycle","waterrequirement",100)
		dat += get_evopanel_line("Nutrient Requirement"," units/decacycle","nutrientrequirement",100)

		for(var/datum/plantmutation/mut in tempseed.mutations)
			dat += get_evopanel_mutline(mut)

		return dat

	proc/get_evopanel_line(var/name,var/unit,var/param,var/factor)
		var/num = tempseed.vars[param] * factor
		var/change = abilityunits[param] * factor

		return "[name]: [num][unit] <A href='?src=\ref[src];add=[param]'>\[+[change]\]</A> <A href='?src=\ref[src];subtract=[param]'>\[-[change]\]</A></BR>"

	proc/get_evopanel_mutline(var/datum/plantmutation/mut)
		var/dat = ""
		var/name = mut.get_name()
		var/desc = mut.get_description()

		dat += "<B>[name]</B>: [desc]</BR>"
		dat += "<A href='?src=\ref[src];mutup=\ref[mut]'>\[level up\]</A> "
		dat += "<A href='?src=\ref[src];mutdown=\ref[mut]'>\[level down\]</A> "
		dat += "<A href='?src=\ref[src];mutrandom=\ref[mut]'>\[randomize\]</A> "
		dat += "<A href='?src=\ref[src];mutremove=\ref[mut]'>\[demutate\]</A> "
		dat += "</BR>"

		return dat

	proc/get_plant()
		if(!plantcontainer) return null

		if(istype(plantcontainer,/obj/item/seed))
			var/obj/item/seed/SO = plantcontainer

			return SO.internal
		else if(istype(plantcontainer,/obj/item/weapon/reagent_containers/food/snacks/fruit))
			var/obj/item/weapon/reagent_containers/food/snacks/fruit/FO = plantcontainer

			return FO.parentplant

	proc/set_plant(var/datum/seed/S)
		if(!plantcontainer) return

		if(istype(plantcontainer,/obj/item/seed))
			var/obj/item/seed/SO = plantcontainer

			SO.internal = S
		else if(istype(plantcontainer,/obj/item/weapon/reagent_containers/food/snacks/fruit))
			var/obj/item/weapon/reagent_containers/food/snacks/fruit/FO = plantcontainer

			FO.parentplant = S

	proc/scan()
		if(!plantcontainer) return

		var/datum/seed/S = get_plant()
		tempseed = S.copy()

		menustat = "SUCCESSFULLY SCANNED PLANT DATA"

	proc/eject()
		if(!plantcontainer) return

		set_plant(tempseed)
		tempseed = null

		menustat = "PLANTMATTER EJECTED"
		plantcontainer.loc = src.loc
		plantcontainer.update_icon()

	attack_hand(mob/user as mob)
		interact(user)

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(0)
			return
		else
			for(var/typepath in acceptedtypes)
				if(istype(O, typepath))
					user.before_take_item(O)
					O.loc = src
					plantcontainer = O
					updateUsrDialog()
					break

	proc/interact(mob/user as mob)
		if(stat & BROKEN)
			return

		user.machine = src

		var/dat = "</HR>"
		dat += menustat
		dat += "</HR>"

		if(tempseed)
			dat += get_evopanel(user)
			dat += "</HR>"
			dat += "<A href='?src=\ref[src];eject=1'>Eject</A> "
		else if(get_plant())
			dat += "<A href='?src=\ref[src];scan=1'>Scan</A> "
		else
			dat += "NO PLANTMATTER DETECTED"
		dat += "</HR>"

		user << browse("<HTML><HEAD><TITLE>EVO-Generator</TITLE></HEAD><BODY><TT>[dat]</TT></BODY></HTML>", "window=evogenerator")
		onclose(user, "evogenerator")

	proc/consume_evopoints(var/pts)
		if(tempseed.evopoints > pts)
			tempseed.evopoints -= pts
			return 1

		return 0

	Topic(href, href_list)
		if(stat & BROKEN) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		usr.machine = src

		if(href_list["mutup"])
			var/datum/plantmutation/mut = locate(href_list["mutup"])
			if(consume_evopoints(1))
				mut.upgrade()
		if(href_list["mutdown"])
			var/datum/plantmutation/mut = locate(href_list["mutdown"])
			if(consume_evopoints(1))
				mut.downgrade()
		if(href_list["mutrandom"])
			var/datum/plantmutation/mut = locate(href_list["mutrandom"])
			if(consume_evopoints(1))
				mut.randomize()
		if(href_list["mutremove"])
			var/datum/plantmutation/mut = locate(href_list["mutremove"])
			if(consume_evopoints(3))
				tempseed.removemutation(mut)
		if(href_list["add"])
			var/varname = href_list["add"]
			if(consume_evopoints(1))
				tempseed.vars[varname] += abilityunits[varname]
		if(href_list["subtract"])
			var/varname = href_list["subtract"]
			if(consume_evopoints(1))
				tempseed.vars[varname] -= abilityunits[varname]
		if(href_list["eject"])
			eject()
		if(href_list["scan"])
			scan()

		updateUsrDialog()