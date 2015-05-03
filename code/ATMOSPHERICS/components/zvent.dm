obj/machinery/zvent
	icon = 'vent_pump.dmi'
	icon_state = "hoff"

	name = "Vent"
	desc = "Transfers air between decks."

	var/welded = 0

	process()
		if(welded)
			return 0

		var/datum/gas_mixture/enviroment = loc.return_air()
		//var/environment_pressure = environment.return_pressure()

		var/turf/simulated/zturf_conn = locate(x,y,z+1)
		if(zturf_conn)
			var/datum/gas_mixture/enviroment_bottom = zturf_conn.return_air()
			//var/environment_pressure_bottom = environment_bottom.return_pressure()
			if(enviroment && enviroment_bottom)
				enviroment.share(enviroment_bottom)

		return 1