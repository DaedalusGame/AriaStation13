#define SOLID 1
#define LIQUID 2
#define GAS 3

obj/floorchem
	//Liquid fuel is used for things that used to rely on volatile fuels or plasma being contained to a couple tiles.
	icon = 'icons/effects/effects.dmi'
	icon_state = "fuel"
	layer = TURF_LAYER+0.2
	anchored = 1
	var/volume = 1000

	New(newLoc)
		. = ..()

		//Be absorbed by any other liquid fuel in the tile.
		for(var/obj/floorchem/other in newLoc)
			if(other != src)
				spawn(1) other.Spread()
				. = other
				del src

		var/datum/reagents/R = new/datum/reagents(volume)
		reagents = R
		R.my_atom = src

		spawn(1) Spread()


	update_icon()
		update_reagent()

	proc/update_reagent()
		overlays.Cut()

		if(reagents.total_volume)
			var/solids = 0
			var/liquids = 0
			var/blood = 0

			for(var/datum/reagent/re in reagents.reagent_list) // natural color mixing bullshit/algorithm
				if(re.id == "blood")
					blood += re.volume
				if(re.reagent_state == SOLID)
					solids += re.volume
				if(re.reagent_state == LIQUID)
					liquids += re.volume

			var/regularchems = (solids + liquids) / 2

			if(blood > regularchems)
				icon_state = "blood"
			else if(solids > liquids)
				icon_state = "flour"
			else
				icon_state = "fuel"

			var/image/I = image(icon,icon_state = "glow")
			I.color = "#FFFFFF"
			I.blend_mode = BLEND_ADD

			overlays += I

			color = mix_color_from_reagents(reagents.reagent_list)

	proc/Spread()
		if(!src) return
		//Allows liquid fuels to sometimes flow into other tiles.
		if(reagents.total_volume < 0.1)
			del(src)
			return
		var/turf/simulated/S = loc
		if(!istype(S)) return
		for(var/d in cardinal)
			if(S.air_check_directions & d)
				if(rand(25))
					var/turf/simulated/O = get_step(src,d)
					//if(!locate(/obj/liquid_fuel) in O)
					var/obj/floorchem/N = locate(/obj/floorchem) in O
					if(!N)
						N = new/obj/floorchem(O)
					else
						spawn(1) N.Spread()

					reagents.trans_to(N,reagents.total_volume*0.25)
					N.update_icon()

		update_icon()

#undef SOLID
#undef LIQUID
#undef GAS