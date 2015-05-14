turf/simulated
	var/obj/effect/tile_overlay/olay

	New()
		..()

		//if(!olay)
		//	olay = new(src)

	proc/update_visuals()
		var/datum/gas_mixture/air = return_air()

		if(olay)
			olay.update_icon(air)
		else if(air && air.gas_icon)
			olay = locate() in src

			if(!olay)
				olay = new(src)

obj/effect/tile_overlay
	name = "Tile Overlay"
	unacidable = 1
	mouse_opacity = 0
	layer = FLY_LAYER


	var/turf/simulated/assignedturf

	New(loc)
		if(!istype(loc,/turf/simulated))
			del(src)

		..()

		verbs.Cut()

	//ex_act()
	//	return

	update_icon(var/datum/gas_mixture/air)
		if(!air || !air.gas_icon)
			invisibility = 101
		else
			invisibility = 0
			icon = air.gas_icon

datum/gas_mixture
	var/icon/gas_icon
	var/last_icon_update = 0

	proc/update_gas_icon()
		if(last_icon_update && last_icon_update > world.time-30)
			return 0

		last_icon_update = world.time

		gas_icon = icon('tile_effects.dmi',"base")

		var/list/reagentlist = list()
		var/fuelgas = 0
		var/n2o = 0
		var/rain = 0
		var/snow = 0

		for(var/datum/gas/g in trace_gases)
			if(istype(g,/datum/gas/reagent))
				reagentlist += g
			if(istype(g,/datum/gas/volatile_fuel))
				fuelgas += g.moles
			if(istype(g,/datum/gas/sleeping_agent))
				n2o += g.moles
			if(istype(g,/datum/gas/rain))
				rain += g.moles
			if(istype(g,/datum/gas/snow))
				snow += g.moles

		if(reagentlist.len)
			var/mixcolor = mix_color_from_gases(reagentlist)

			gas_icon.Blend(icon('tile_effects.dmi',"reagent_new") * mixcolor,ICON_OVERLAY)

		if(toxins > MOLES_PLASMA_VISIBLE)
			gas_icon.Blend(icon('tile_effects.dmi',"plasma_new"),ICON_OVERLAY)

		if(fuelgas > 1)
			gas_icon.Blend(icon('tile_effects.dmi',"fuel"),ICON_OVERLAY)

		if(n2o > 1)
			gas_icon.Blend(icon('tile_effects.dmi',"sleeping_agent"),ICON_OVERLAY)

		if(rain > 1)
			gas_icon.Blend(icon('tile_effects.dmi',"rain"),ICON_OVERLAY)

		if(snow > 1)
			gas_icon.Blend(icon('tile_effects.dmi',"snow"),ICON_OVERLAY)

		return 1

	proc/check_tile_graphic()
		return update_gas_icon()