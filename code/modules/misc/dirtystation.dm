//Janitors!  Janitors, janitors, janitors!

//Todo: Blood may be a bad choice (virus runtimes?)

/turf/simulated/floor/New()
	..()
	if(prob(66) || usr) //usr check to prevent manually created floors from having dirt
		return			//prob() to keep the rate of creation down and do a fast exit

	// These look weird if you make them dirty
	if(istype(src,/turf/simulated/floor/plating/flesh) || istype(src,/turf/simulated/floor/mainframe) || istype(src,/turf/simulated/floor/carpet) || istype(src,/turf/simulated/floor/grass) || istype(src,/turf/simulated/floor/holofloor))
		return

	var/A = loc

				// zero dirt
	if(istype(A,/area/centcom) || istype(A,/area/holodeck) || istype(A,/area/library) || istype(A,/area/janitor) || istype(A,/area/chapel) || istype(A,/area/mine/explored) || istype(A,/area/mine/unexplored) || istype(A,/area/solar) || istype(A,/area/atmos))
		return

				// high dirt - 1/3
	if(istype(A,/area/mine/production) || istype(A,/area/mine/living_quarters) || istype(A,/area/mine/north_outpost) || istype(A,/area/mine/west_outpost) || istype(A,/area/wreck) || istype(A,/area/derelict))
		new/obj/effect/decal/cleanable/dirt(src) // vanilla, but it works
		return


	if(prob(90))// mid dirt  - 1/30
		return


	if(istype(A,/area/engine) || istype(A,/area/assembly) || istype(A,/area/maintenance) || istype(A,/area/construction) || istype(A,/area/skullfish))
	 	// Blood, sweat, and oil.  Oh, and dirt.
		if(prob(5))
			new/obj/effect/decal/cleanable/blood(src)
		else
			if(prob(55))
				if(prob(5))
					new/obj/effect/decal/cleanable/robot_debris(src)
				else
					new/obj/effect/decal/cleanable/oil(src)
			else
				new/obj/effect/decal/cleanable/dirt(src)
		return

	if(istype(A,/area/crew_quarters/toilet) || istype(A,/area/crew_quarters/locker/locker_toilet))
		if(prob(60))
			if(prob(80))
				new/obj/effect/decal/cleanable/vomit(src)
			else
				new/obj/effect/decal/cleanable/blood(src)
		else
			new/obj/effect/decal/cleanable/dirt(src)
		return

	if(istype(A,/area/quartermaster))
		if(prob(75))
			new/obj/effect/decal/cleanable/dirt(src)
		else
			new/obj/effect/decal/cleanable/oil(src)
		return



	if(prob(50))// low dirt  - 1/60
		return



	if(istype(A,/area/turret_protected) || istype(A,/area/security)) // chance of incident
		if(prob(25))
			if(prob(10))
				new/obj/effect/decal/cleanable/blood/gibs(src)
			else
				new/obj/effect/decal/cleanable/blood(src)
		else
			new/obj/effect/decal/cleanable/dirt(src)
		return


	if(istype(A,/area/crew_quarters/kitchen)) // Kitchen messes
		if(prob(60))
			if(prob(50))
				new/obj/effect/decal/cleanable/egg_smudge(src)
			else
				new/obj/effect/decal/cleanable/flour(src)
		else
			if(prob(33))
				new/obj/effect/decal/cleanable/dirt(src)
			else
				new/obj/effect/decal/cleanable/blood(src)
		return

	if(istype(A,/area/medical)) // Kept clean, but chance of blood
		if(prob(66))
			if(prob(10))
				new/obj/effect/decal/cleanable/blood/gibs(src)
			else
				new/obj/effect/decal/cleanable/blood(src)
		else
			if(prob(45))
				new/obj/effect/decal/cleanable/vomit(src)
			else
				new/obj/effect/decal/cleanable/dirt(src)
		return
	if(istype(A,/area/toxins))
		if(prob(80))
			new/obj/effect/decal/cleanable/dirt(src)
		//else
		//	new/obj/effect/decal/cleanable/greenglow(src) // this cleans itself up but it might startle you when you see it.
		return

	//default
	new/obj/effect/decal/cleanable/dirt(src)
	return