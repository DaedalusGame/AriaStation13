
obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'heat.dmi'
	icon_state = "intact"
	level = 1
	var/initialize_directions_he

	minimum_temperature_difference = 20
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT

	var/icon_temperature = T20C

	// BubbleWrap
	New()
		..()
		initialize_directions_he = initialize_directions	// The auto-detection from /pipe is good enough for a simple HE pipe
	// BubbleWrap END

	initialize()
		normalize_dir()
		var/node1_dir
		var/node2_dir

		for(var/direction in cardinal)
			if(direction&initialize_directions_he)
				if (!node1_dir)
					node1_dir = direction
				else if (!node2_dir)
					node2_dir = direction

		for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,node1_dir))
			if(target.initialize_directions_he & get_dir(target,src))
				node1 = target
				break
		for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,node2_dir))
			if(target.initialize_directions_he & get_dir(target,src))
				node2 = target
				break

		var/turf/T = src.loc			// hide if turf is not intact
		if(T)
			hide(T.intact)

		update_icon()
		return

	hide(var/i)
		if(level == 1 && istype(loc, /turf/simulated))
			invisibility = i ? 101 : 0
		update_icon()


	process()
		var/datum/gas_mixture/pipe_air = return_air()

		if(!parent)
			..()
		else
			var/environment_temperature = 0
			if(istype(loc, /turf/simulated/))
				if(loc:blocks_air)
					environment_temperature = loc:temperature
				else
					var/datum/gas_mixture/environment = loc.return_air()
					environment_temperature = environment.temperature
			else
				environment_temperature = loc:temperature
			if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
				parent.temperature_interact(loc, volume, thermal_conductivity)

		//Heat causes pipe to glow
		if(pipe_air.temperature && (icon_temperature > 500 || pipe_air.temperature > 500)) //glow starts at 500K
			if(abs(pipe_air.temperature - icon_temperature) > 10)
				icon_temperature = pipe_air.temperature

				var/h_r = heat2colour_r(icon_temperature)
				var/h_g = heat2colour_g(icon_temperature)
				var/h_b = heat2colour_b(icon_temperature)

				if(icon_temperature < 2000)//scale glow until 2000K
					var/scale = (icon_temperature - 500) / 1500
					h_r = 64 + (h_r - 64) * scale
					h_g = 64 + (h_g - 64) * scale
					h_b = 64 + (h_b - 64) * scale

				animate(src, color = rgb(h_r, h_g, h_b), time = 20, easing = SINE_EASING)



obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction
	icon = 'junction.dmi'
	icon_state = "intact"
	level = 1
	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	// BubbleWrap
	New()
		.. ()
		switch ( dir )
			if ( SOUTH )
				initialize_directions = NORTH
				initialize_directions_he = SOUTH
			if ( NORTH )
				initialize_directions = SOUTH
				initialize_directions_he = NORTH
			if ( EAST )
				initialize_directions = WEST
				initialize_directions_he = EAST
			if ( WEST )
				initialize_directions = EAST
				initialize_directions_he = WEST
	// BubbleWrap END

	hide(var/i)
		if(level == 1 && istype(loc, /turf/simulated))
			invisibility = i ? 101 : 0
		update_icon()

	update_icon()
		if(node1&&node2)
			icon_state = "intact"
		else
			var/have_node1 = node1?1:0
			var/have_node2 = node2?1:0
			icon_state = "exposed[have_node1][have_node2]"
		if(!node1&&!node2)
			del(src)

	initialize()
		for(var/obj/machinery/atmospherics/target in get_step(src,initialize_directions))
			if(target.initialize_directions & get_dir(target,src))
				node1 = target
				break
		for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,initialize_directions_he))
			if(target.initialize_directions_he & get_dir(target,src))
				node2 = target
				break

		var/turf/T = src.loc			// hide if turf is not intact
		if(T)
			hide(T.intact)

		update_icon()
		return