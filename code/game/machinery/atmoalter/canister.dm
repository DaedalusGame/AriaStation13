/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'atmos.dmi'
	icon_state = "yellow"
	density = 1
	var/health = 100.0
	flags = FPRINT | CONDUCT

	var/valve_open = 0
	var/release_pressure = ONE_ATMOSPHERE

	var/cancolor = "yellow"
	var/can_label = 1
	var/filled = 0.5
	pressure_resistance = 7*ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = 0
	var/release_log = ""

/obj/machinery/portable_atmospherics/canister/snow
	name = "Canister: \[Snow\]"
	icon_state = "snow"
	cancolor = "snow"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/rain
	name = "Canister: \[Condensed Water\]"
	icon_state = "rain"
	cancolor = "rain"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/coolant
	name = "Canister: \[Coolant\]"
	icon_state = "coolant"
	cancolor = "coolant"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "Canister: \[N2O\]"
	icon_state = "redws"
	cancolor = "redws"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "red"
	cancolor = "red"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue"
	cancolor = "blue"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/toxins
	name = "Canister \[Toxin (Bio)\]"
	icon_state = "orange"
	cancolor = "orange"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black"
	cancolor = "black"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/air
	name = "Canister \[Air\]"
	icon_state = "grey"
	cancolor = "grey"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/acid
	name = "Canister: \[ACID\]"
	desc = "SULPHURIC ACID MOTHERFUCKER."
	icon_state = "yellow"
	cancolor = "yellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/phazon
	name = "Canister: \[PHAZON\]"
	desc = "PHAZON GAS MOTHERFUCKER."
	icon_state = "yellow"
	cancolor = "yellow"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/update_icon()
	src.overlays = 0

	if (src.destroyed)
		src.icon_state = text("[]-1", src.cancolor)

	else
		icon_state = "[cancolor]"
		if(holding)
			overlays += "can-open"

		if(connected_port)
			overlays += "can-connector"

		var/tank_pressure = air_contents.return_pressure()

		if (tank_pressure < 10)
			overlays += image('atmos.dmi', "can-o0")
		else if (tank_pressure < ONE_ATMOSPHERE)
			overlays += image('atmos.dmi', "can-o1")
		else if (tank_pressure < 15*ONE_ATMOSPHERE)
			overlays += image('atmos.dmi', "can-o2")
		else
			overlays += image('atmos.dmi', "can-o3")
	return

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		health -= 5
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck()
	if(destroyed)
		return 1

	if (src.health <= 10)
		var/atom/location = src.loc
		location.assume_air(air_contents)

		src.destroyed = 1
		playsound(src.loc, 'spray.ogg', 10, 1, -3)
		src.density = 0
		update_icon()

		if (src.holding)
			src.holding.loc = src.loc
			src.holding = null

		return 1
	else
		return 1

/obj/machinery/portable_atmospherics/canister/var/integrity = 3
/obj/machinery/portable_atmospherics/canister/proc/check_status()
	//Handle exploding, leaking, and rupturing of the tank

	if(!air_contents)
		return 0

	var/pressure = air_contents.return_pressure()
	if(pressure > TANK_FRAGMENT_PRESSURE * 600)
		if(!istype(src.loc,/obj/item/device/transfer_valve))
			message_admins("Explosive tank rupture! last key to touch the tank was [fingerprintslast].")
			log_game("Explosive tank rupture! last key to touch the tank was [fingerprintslast].")
		//world << "\blue[x],[y] tank is exploding: [pressure] kPa"
		//Give the gas a chance to build up more pressure through reacting
		air_contents.react()
		air_contents.react()
		air_contents.react()
		pressure = air_contents.return_pressure()

		var/range = (pressure-TANK_FRAGMENT_PRESSURE*600)/(TANK_FRAGMENT_SCALE*600)
		range = min(range, MAX_EXPLOSION_RANGE)		// was 8 - - - Changed to a configurable define -- TLE
		var/turf/epicenter = get_turf(loc)

		//world << "\blue Exploding Pressure: [pressure] kPa, intensity: [range]"

		explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5))
		del(src)

	/*else if(pressure > TANK_RUPTURE_PRESSURE * 600)
		//world << "\blue[x],[y] tank is rupturing: [pressure] kPa, integrity [integrity]"
		if(integrity <= 0)
			loc.assume_air(air_contents)
			//TODO: make pop sound
			del(src)
		else
			integrity--*/

	else if(pressure > TANK_LEAK_PRESSURE * 600)
		//world << "\blue[x],[y] tank is leaking: [pressure] kPa, integrity [integrity]"
		if(integrity <= 0)
			var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
			loc.assume_air(leaked_gas)
		else
			integrity--

	else if(integrity < 3)
		integrity++

/obj/machinery/portable_atmospherics/canister/process()
	if (destroyed)
		return

	..()

	air_contents.react(null)
	check_status()

	if(valve_open)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()

		var/env_pressure = environment.return_pressure()
		var/pressure_delta = min(release_pressure - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure

		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			if(holding)
				environment.merge(removed)
			else
				loc.assume_air(removed)
			src.update_icon()

	if(air_contents.return_pressure() < 1)
		can_label = 1
	else
		can_label = 0

	src.updateDialog()
	return

/obj/machinery/portable_atmospherics/canister/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/canister/proc/return_temperature()
	var/datum/gas_mixture/GM = src.return_air()
	if(GM && GM.volume>0)
		return GM.temperature
	return 0

/obj/machinery/portable_atmospherics/canister/proc/return_pressure()
	var/datum/gas_mixture/GM = src.return_air()
	if(GM && GM.volume>0)
		return GM.return_pressure()
	return 0

/obj/machinery/portable_atmospherics/canister/blob_act()
	src.health -= 200
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/meteorhit(var/obj/O as obj)
	src.health = 0
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(!istype(W, /obj/item/weapon/wrench) && !istype(W, /obj/item/weapon/tank) && !istype(W, /obj/item/device/analyzer) && !istype(W, /obj/item/device/pda))
		for(var/mob/V in viewers(src, null))
			V.show_message(text("\red [user] hits the [src] with a [W]!"))
		src.health -= W.force
		src.add_fingerprint(user)
		healthcheck()

	if(istype(user, /mob/living/silicon/robot) && istype(W, /obj/item/weapon/tank/jetpack))
		var/datum/gas_mixture/thejetpack = W:air_contents
		var/env_pressure = thejetpack.return_pressure()
		var/pressure_delta = min(10*ONE_ATMOSPHERE - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure
		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*thejetpack.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			thejetpack.merge(removed)
			user << "You pulse-pressurize your jetpack from the tank."
		return

	..()

/obj/machinery/portable_atmospherics/canister/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_hand(var/mob/user as mob)
	if (src.destroyed)
		return

	user.machine = src
	var/holding_text
	if(holding)
		holding_text = {"<BR><B>Tank Pressure</B>: [holding.air_contents.return_pressure()] KPa<BR>
<A href='?src=\ref[src];remove_tank=1'>Remove Tank</A><BR>
"}
	var/output_text = {"<TT><B>[name]</B>[can_label?" <A href='?src=\ref[src];relabel=1'><small>relabel</small></a>":""]<BR>
Pressure: [air_contents.return_pressure()] KPa<BR>
Port Status: [(connected_port)?("Connected"):("Disconnected")]
[holding_text]
<BR>
Release Valve: <A href='?src=\ref[src];toggle=1'>[valve_open?("Open"):("Closed")]</A><BR>
Release Pressure: <A href='?src=\ref[src];pressure_adj=-1000'>-</A> <A href='?src=\ref[src];pressure_adj=-100'>-</A> <A href='?src=\ref[src];pressure_adj=-10'>-</A> <A href='?src=\ref[src];pressure_adj=-1'>-</A> [release_pressure] <A href='?src=\ref[src];pressure_adj=1'>+</A> <A href='?src=\ref[src];pressure_adj=10'>+</A> <A href='?src=\ref[src];pressure_adj=100'>+</A> <A href='?src=\ref[src];pressure_adj=1000'>+</A><BR>
<HR>
<A href='?src=\ref[user];mach_close=canister'>Close</A><BR>
"}

	user << browse("<html><head><title>[src]</title></head><body>[output_text]</body></html>", "window=canister;size=600x300")
	onclose(user, "canister")
	return

/obj/machinery/portable_atmospherics/canister/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		usr.machine = src

		if(href_list["toggle"])
			if (valve_open)
				if (holding)
					release_log += "Valve was <b>closed</b> by [usr], stopping the transfer into the [holding]<br>"
				else
					release_log += "Valve was <b>closed</b> by [usr], stopping the transfer into the <font color='red'><b>air</b></font><br>"
			else
				if (holding)
					release_log += "Valve was <b>opened</b> by [usr], starting the transfer into the [holding]<br>"
				else
					release_log += "Valve was <b>opened</b> by [usr], starting the transfer into the <font color='red'><b>air</b></font><br>"
			valve_open = !valve_open

		if (href_list["remove_tank"])
			if(holding)
				holding.loc = loc
				holding = null

		if (href_list["pressure_adj"])
			var/diff = text2num(href_list["pressure_adj"])
			if(diff > 0)
				release_pressure = min(10*ONE_ATMOSPHERE, release_pressure+diff)
			else
				release_pressure = max(ONE_ATMOSPHERE/10, release_pressure+diff)

		if (href_list["relabel"])
			if (can_label)
				var/list/colors = list(\
					"\[N2O\]" = "redws", \
					"\[N2\]" = "red", \
					"\[O2\]" = "blue", \
					"\[Toxin (Bio)\]" = "orange", \
					"\[CO2\]" = "black", \
					"\[Air\]" = "grey", \
					"\[CAUTION\]" = "yellow", \
				)
				var/label = input("Choose canister label", "Gas canister") as null|anything in colors
				if (label)
					src.cancolor = colors[label]
					src.icon_state = colors[label]
					src.name = "Canister: [label]"
		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr << browse(null, "window=canister")
		return
	return

/obj/machinery/portable_atmospherics/canister/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	if(Proj.flag == "bullet")
		src.health = 0
		spawn( 0 )
			healthcheck()
			return
	..()
	return

/obj/machinery/portable_atmospherics/canister/toxins/New()

	..()

	src.air_contents.toxins = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/oxygen/New()

	..()

	src.air_contents.oxygen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/snow/New()

	..()

	var/datum/gas/snow/trace_gas = new
	air_contents.trace_gases += trace_gas
	trace_gas.moles = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/rain/New()

	..()

	var/datum/gas/rain/trace_gas = new
	air_contents.trace_gases += trace_gas
	trace_gas.moles = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/coolant/New()

	..()

	var/datum/gas/coolant/trace_gas = new
	air_contents.temperature = 0.1
	air_contents.trace_gases += trace_gas
	trace_gas.moles = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1


/obj/machinery/portable_atmospherics/canister/sleeping_agent/New()

	..()

	var/datum/gas/sleeping_agent/trace_gas = new
	air_contents.trace_gases += trace_gas
	trace_gas.moles = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/nitrogen/New()

	..()

	src.air_contents.nitrogen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/New()

	..()
	src.air_contents.carbon_dioxide = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1


/obj/machinery/portable_atmospherics/canister/air/New()

	..()
	src.air_contents.oxygen = (O2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	src.air_contents.nitrogen = (N2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/acid/New()

	..()

	var/datum/gas/reagent/trace_gas = new
	trace_gas.liquid = chemical_reagents_list["acid"]
	air_contents.add_tracegas(trace_gas,(src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature))
	air_contents.update_values()

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/phazon/New()

	..()

	var/datum/gas/reagent/trace_gas = new
	trace_gas.liquid = chemical_reagents_list["phazon"]
	air_contents.add_tracegas(trace_gas,(src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature))
	air_contents.update_values()

	src.update_icon()
	return 1
