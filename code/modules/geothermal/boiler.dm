obj/machinery/atmospherics/pipe/simple/coil
	name="Copper-coiled pipe"
	pipecolor=""
	icon = 'coil_pipe.dmi'
	icon_state = "intact"
	level = 2
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT

	coiled
		color = "red"

	process()
		if(!parent)
			..()
			//world << "No parent to copper-coiled pipe"
		else
			var/environment_temperature = 0
			var/turf/T = loc

			if(!T)
				return

			if(istype(loc, /turf/simulated/))
				if(loc:blocks_air)
					environment_temperature = loc:temperature
				else
					var/datum/gas_mixture/environment = loc.return_air()
					environment_temperature = environment.temperature
			else
				environment_temperature = loc:temperature

			for(var/obj/effect/liquid/lava/L in loc)
				environment_temperature = 30000

			var/datum/gas_mixture/pipe_air = return_air()

			//world << "[environment_temperature] and [pipe_air.temperature]"

			if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
				parent.temperature_interact_specific(environment_temperature, loc:heat_capacity, volume, thermal_conductivity)

/obj/machinery/atmospherics/unary/boiler
	icon = 'liquidmachinery.dmi'
	icon_state = "boiler0"

	name = "Boiler"
	desc = "Produces power from hot gas"
	density = 1

	var/on = 0

	var/volume_rate = 50

	var/state = 0
	var/directwired = 1
	var/obj/structure/cable/attached		// the attached cable
	var/storevolume = 180.0*ONE_ATMOSPHERE

	var/current_temperature = T20C
	var/current_heat_capacity = 1000

	var/pulses = 200

	flags = FPRINT | CONDUCT
	use_power = 0

	level = 3
	layer = 3

	update_icon()
		if(state == 1)
			icon_state = "boiler1"
		else
			icon_state = "boiler0"

		return

	process()
		..()

		switch(state)
			if(0)
				if(air_contents.return_pressure() >= 0.80*storevolume)
					closevalve()
					state = 1
			if(1)
				power()
				pulses--
				if(pulses <= 0)
					pulses = initial(pulses)
					state = 2
			if(2)
				cooldown()
				if(air_contents.temperature <= 1.20*current_temperature)
					state = 3
			if(3)
				release()

				if(air_contents.return_pressure() < 0.10*storevolume)
					openvalve()
					state = 0

		update_icon()

		return 1

	proc/openvalve()
		if(network && !network.gases.Find(air_contents))
			network.gases += air_contents
			network.update = 1

	proc/closevalve()
		if(network)
			network.gases -= air_contents

	proc/release()
		if(air_contents.temperature > 0)
			var/transfer_moles = (air_contents.return_pressure())*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			loc.assume_air(removed)

			if(network)
				network.update = 1

	proc/cooldown()
		var/air_heat_capacity = air_contents.heat_capacity()
		var/combined_heat_capacity = current_heat_capacity + air_heat_capacity

		if(combined_heat_capacity > 0)
			var/combined_energy = current_temperature*current_heat_capacity + air_heat_capacity*air_contents.temperature
			air_contents.temperature = combined_energy/combined_heat_capacity

	proc/power()
		var/turf/T = src.loc
		var/obj/structure/cable/C = T.get_cable_node()
		var/net

		if (C)
			net = C.netnum		// find the powernet of the connected cable

		if(!net)
			return 0

		var/datum/powernet/PN = powernets[net]			// find the powernet. Magic code, voodoo code.

		if(PN)
			PN.newavail += air_contents.temperature

	initialize()
		..()

//	hide(var/i) //to make the little pipe section invisible, the icon changes.
//		return