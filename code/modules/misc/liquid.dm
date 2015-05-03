/obj/machinery/liquidtank
	name = "liquid tank"

	icon = 'liquidtank.dmi'
	icon_state = "tank"
	density = 1

	flags = FPRINT | CONDUCT | OPENCONTAINER

	var/on = 0
	var/volume = 2500
	var/valve = 0

	var/reagenttype

	highcap
		volume = 100000
		name = "high-capacity tank"

		water
			name = "high-capacity water tank"
			reagenttype = "water"

		fuel
			name = "high-capacity fuel tank"
			reagenttype = "fuel"

/obj/machinery/liquidtank/New()
	var/datum/reagents/R = new/datum/reagents(volume)
	reagents = R
	R.my_atom = src

	if(reagenttype)
		reagents.add_reagent(reagenttype,volume)

	spawn(1)
		update_icon()

	..()

/obj/machinery/liquidtank/water
	name = "water tank"
	reagenttype = "water"

/obj/machinery/liquidtank/fuel
	name = "fuel tank"
	reagenttype = "fuel"

/obj/machinery/liquidtank/hydrogen
	name = "hydrogen tank"
	reagenttype = "hydrogen"

/obj/machinery/liquidtank/oxygen
	name = "oxygen tank"
	reagenttype = "oxygen"

/obj/machinery/liquidtank/nitrogen
	name = "nitrogen tank"
	reagenttype = "nitrogen"

/obj/machinery/liquidtank/potassium
	name = "potassium tank"
	reagenttype = "potassium"

/obj/machinery/liquidtank/mercury
	name = "mercury tank"
	reagenttype = "mercury"

/obj/machinery/liquidtank/sulfur
	name = "sulfur tank"
	reagenttype = "sulfur"

/obj/machinery/liquidtank/lithium
	name = "lithium tank"
	reagenttype = "lithium"

/obj/machinery/liquidtank/fluorine
	name = "fluorine tank"
	reagenttype = "fluorine"

/obj/machinery/liquidtank/sodium
	name = "sodium tank"
	reagenttype = "sodium"

/obj/machinery/liquidtank/aluminum
	name = "aluminum tank"
	reagenttype = "aluminum"

/obj/machinery/liquidtank/silicon
	name = "silicon tank"
	reagenttype = "silicon"

/obj/machinery/liquidtank/phosphorus
	name = "phosphorus tank"
	reagenttype = "phosphorus"

/obj/machinery/liquidtank/chlorine
	name = "chlorine tank"
	reagenttype = "chlorine"

/obj/machinery/liquidtank/tungsten
	name = "tungsten tank"
	reagenttype = "tungsten"

/obj/machinery/liquidtank/radium
	name = "radium tank"
	reagenttype = "radium"

/obj/machinery/liquidtank/copper
	name = "copper tank"
	reagenttype = "copper"

/obj/machinery/liquidtank/radium
	name = "radium tank"
	reagenttype = "radium"

/obj/machinery/liquidtank/ethanol
	name = "ethanol tank"
	reagenttype = "ethanol"

/obj/machinery/liquidtank/sugar
	name = "sugar tank"
	reagenttype = "sugar"

/obj/machinery/liquidtank/acid
	name = "sulphuric acid tank"
	reagenttype = "acid"

/obj/machinery/liquidtank/milk
	name = "milk tank"
	reagenttype = "milk"

/obj/machinery/liquidtank/phazon
	name = "phazon tank"
	reagenttype = "phazon"

/obj/machinery/liquidtank/lava
	name = "lava tank"
	reagenttype = "lava"

/obj/machinery/liquidtank/Del()
	del(reagents)
	..()

/obj/machinery/liquidtank/process()
	if(anchored)
		var/obj/machinery/liquidport/P = locate(/obj/machinery/liquidport) in loc
		if(P)
			P.valve = valve

	update_icon()

/obj/machinery/liquidtank/update_icon()
	icon_state = "tank"

	update_reagent()

	var/obj/effect/overlay = new/obj
	overlay.icon = 'liquidtank.dmi'
	overlay.layer = layer+0.1
	overlay.icon_state = "tank_glass"
	overlays += overlay

	return

/obj/machinery/liquidtank/proc/update_reagent()
	overlays = null

	if(reagents.total_volume)
		var/obj/effect/overlay = new/obj
		overlay.icon = 'liquidtank.dmi'
		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)		overlay.icon_state = "10"
			if(10 to 24) 	overlay.icon_state = "10"
			if(25 to 49)	overlay.icon_state = "25"
			if(50 to 74)	overlay.icon_state = "50"
			if(75 to 79)	overlay.icon_state = "75"
			if(80 to 90)	overlay.icon_state = "80"
			if(91 to 100)	overlay.icon_state = "100"

		if(reagents.get_reagent_amount("lava"))
			overlay.icon_state = "lava[overlay.icon_state]"
		else if(reagents.get_reagent_amount("phazon"))
			overlay.icon_state = "phazon[overlay.icon_state]"
		else
			var/list/rgbcolor = list(0,0,0)
			var/finalcolor
			for(var/datum/reagent/re in reagents.reagent_list) // natural color mixing bullshit/algorithm
				if(!finalcolor)
					rgbcolor = GetColors(re.color)
					finalcolor = re.color
				else
					var/newcolor[3]
					var/prergbcolor[3]
					prergbcolor = rgbcolor
					newcolor = GetColors(re.color)

					rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
					rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
					rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

					finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])
					// This isn't a perfect color mixing system, the more reagents that are inside,
					// the darker it gets until it becomes absolutely pitch black! I dunno, maybe
					// that's pretty realistic? I don't do a whole lot of color-mixing anyway.
					// If you add brighter colors to it it'll eventually get lighter, though.

			overlay.icon += finalcolor

		overlays += overlay

/obj/machinery/liquidtank/attack_ai(var/mob/user as mob)
	return 0

/obj/machinery/liquidtank/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/liquidtank/attack_hand(var/mob/user as mob)
	valve = !valve

	if(valve)
		user << "\blue You set the valve to output."
	else
		user << "\blue You set the valve to input."

/obj/machinery/liquidtank/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		if(anchored)
			user << "\blue You wrench the tank from the floor."
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			anchored = 0
		else
			var/turf/T = get_turf(src)

			if(!T)
				return

			if(!istype(T,/turf/simulated/floor) || istype(T,/turf/simulated/floor/plating/airless/lava))
				user << "\red You can't anchor the tank here!"
			else
				user << "\blue You wrench the tank to \the [T.name]"
				playsound(src.loc, 'Ratchet.ogg', 75, 1)
				anchored = 1

