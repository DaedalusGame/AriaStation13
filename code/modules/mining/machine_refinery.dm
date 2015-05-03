/obj/machinery/portable_atmospherics/refinery
	name = "refinery"
	icon = 'liquidmachinery.dmi'
	icon_state = "refinery"
	density = 1
	flags = FPRINT | CONDUCT

	var/sheets = 0
	var/maxsheets = 50

	var/filled = 0.5
	pressure_resistance = 7*ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = 0

	var/on = 0

/obj/machinery/portable_atmospherics/refinery/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/tank))
		src.add_fingerprint(user)
		return

	if(istype(W,/obj/item/stack/sheet/plasma))
		var/obj/item/stack/sheet/plasma/S = W
		var/sheetsneeded = min(maxsheets - sheets,S.amount)

		if(sheetsneeded)
			S.use(sheetsneeded)

			sheets += sheetsneeded
			user << "You add [sheetsneeded] sheets to the refinery."

	..()

/obj/machinery/portable_atmospherics/refinery/attack_ai(var/mob/user as mob)
	//return src.attack_hand(user)
	return 0

/obj/machinery/portable_atmospherics/refinery/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/refinery/attack_hand(var/mob/user as mob)
	if(!user || user.stat)
		return

	on = !on
	if(on)
		user << "\blue You turn on the refinery."
	else
		user << "\blue You turn off the refinery."

	src.add_fingerprint(user)
	update_icon()

/obj/machinery/portable_atmospherics/refinery/update_icon()
	overlays = null

	if(on)
		overlays += "refinery_on"

		if(sheets)
			overlays += "refinery_burn"

	if(connected_port)
		overlays += "refinery_pipe"

	var/tank_pressure = air_contents.return_pressure()

	if (tank_pressure < 10)
		overlays += image('liquidmachinery.dmi', "refinery_0")
	else if (tank_pressure < ONE_ATMOSPHERE)
		overlays += image('liquidmachinery.dmi', "refinery_1")
	else if (tank_pressure < 15*ONE_ATMOSPHERE)
		overlays += image('liquidmachinery.dmi', "refinery_2")
	else
		overlays += image('liquidmachinery.dmi', "refinery_3")

	return

/obj/machinery/portable_atmospherics/refinery/process()
	..()

	if(!on)
		return

	if(sheets)
		var/toxspace = src.maximum_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature) - air_contents.total_moles

		if(toxspace > 25)
			air_contents.toxins += 25
			air_contents.update_values()
			sheets--;
		else
			on = 0

/obj/machinery/portable_atmospherics/distillery
	name = "distillery"
	icon = 'liquidmachinery.dmi'
	icon_state = "still"
	density = 1
	flags = FPRINT | CONDUCT | OPENCONTAINER

	var/rvolume = 2500

	var/filled = 0.5
	pressure_resistance = 7*ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = 0

	var/on = 0
	var/mode = "evaporate"

	var/list/reagent_blacklist = list("lava")

/obj/machinery/portable_atmospherics/distillery/New()
	..()

	var/datum/reagents/R = new/datum/reagents(rvolume)
	reagents = R
	R.my_atom = src

	update_icon()

/obj/machinery/portable_atmospherics/distillery/attackby(var/obj/item/W as obj, var/mob/user as mob)
	update_icon()

	if(istype(W, /obj/item/weapon/tank))
		src.add_fingerprint(user)
		return

	if (W.is_open_container())
		return 1

	..()

/obj/machinery/portable_atmospherics/distillery/attack_ai(var/mob/user as mob)
	//return src.attack_hand(user)
	return 0

/obj/machinery/portable_atmospherics/distillery/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/distillery/attack_hand(var/mob/user as mob)
	if(!user || user.stat)
		return

	src.add_fingerprint(user)
	update_icon()

	user.machine = src
	var/output_text = {"<TT><B>[name]</B><BR>
Pressure: [air_contents.return_pressure()] KPa<BR>
Port Status: [(connected_port)?("Connected"):("Disconnected")]
<BR>
Operation: <A href='?src=\ref[src];toggle=1'>[on?("ON"):("OFF")]</A><BR>
Operation Mode: "}
	output_text += "[mode!="distill"?"<A href='?src=\ref[src];mode=distill'>Distillation</A>":"Distillation"]|"
	output_text += "[mode!="mix"?"<A href='?src=\ref[src];mode=mix'>Synthesis</A>":"Synthesis"]|"
	output_text += "[mode!="evaporate"?"<A href='?src=\ref[src];mode=evaporate'>Evaporation</A>":"Evaporation"]"
	output_text += {"<BR><HR>
<A href='?src=\ref[user];mach_close=still'>Close</A><BR>
"}

	user << browse("<html><head><title>[src]</title></head><body>[output_text]</body></html>", "window=still;size=600x300")
	onclose(user, "still")
	return

/obj/machinery/portable_atmospherics/distillery/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		usr.machine = src

		if(href_list["toggle"])
			on = !on
			if(on)
				usr << "\blue You turn on the distillery."
			else
				usr << "\blue You turn off the distillery."

		if (href_list["mode"])
			mode = href_list["mode"]

		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr << browse(null, "window=canister")
		return
	return

/obj/machinery/portable_atmospherics/distillery/update_icon()
	overlays.Cut()

	update_reagent()

	var/obj/effect/overlay = new/obj
	overlay.icon = 'liquidmachinery.dmi'
	overlay.layer = layer+0.1
	overlay.icon_state = "still_t"
	overlays += overlay

	/*if(on)
		overlays += "refinery_on"

	if(connected_port)
		overlays += "refinery_pipe"

	var/tank_pressure = air_contents.return_pressure()

	if (tank_pressure < 10)
		overlays += image('liquidmachinery.dmi', "refinery_0")
	else if (tank_pressure < ONE_ATMOSPHERE)
		overlays += image('liquidmachinery.dmi', "refinery_1")
	else if (tank_pressure < 15*ONE_ATMOSPHERE)
		overlays += image('liquidmachinery.dmi', "refinery_2")
	else
		overlays += image('liquidmachinery.dmi', "refinery_3")*/

	return

/obj/machinery/portable_atmospherics/distillery/proc/update_reagent()
	overlays = null

	if(reagents.total_volume)
		var/obj/effect/overlay = new/obj
		overlay.icon = 'liquidmachinery.dmi'
		overlay.icon_state = "still_f"


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


/obj/machinery/portable_atmospherics/distillery/process()
	..()

	if(!on)
		return

	if(mode == "evaporate")
		var/gasspace = src.maximum_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature) - air_contents.total_moles
		var/reagentamt = min(gasspace,reagents.total_volume * 0.10)

		//world << "Begin cycle: [reagentamt]/[gasspace]"

		for(var/datum/reagent/R in reagents.reagent_list)
			var/amt = R.volume * 0.10
			if(R.id == "oxygen")
				air_contents.adjust(o2 = amt)
			else if(R.id == "nitrogen")
				air_contents.adjust(n2 = amt)
			else if(R.id == "plasma")
				air_contents.adjust(tx = amt)
			else if(R.id == "carbon")
				air_contents.adjust(co2 = amt)
			else if(R.id == "fuel")
				var/datum/gas/volatile_fuel/trace_gas = new
				air_contents.add_tracegas(trace_gas,amt)
			else if(R.id == "water")
				var/datum/gas/rain/trace_gas = new
				air_contents.add_tracegas(trace_gas,amt)
			else if(R.id == "ice")
				var/datum/gas/snow/trace_gas = new
				air_contents.add_tracegas(trace_gas,amt)
			else if(R.id in reagent_blacklist)
				continue
			else
				var/datum/gas/reagent/trace_gas = new
				trace_gas.liquid = chemical_reagents_list[R.id]
				air_contents.add_tracegas(trace_gas,amt)
			air_contents.update_values()
			reagents.remove_reagent(R.id, amt)

		if(reagentamt < 0.1)
			on = 0

