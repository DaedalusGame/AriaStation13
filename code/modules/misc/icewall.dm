/obj/structure/icewall
	icon = 'effects.dmi'
	icon_state = "icewall"
	density = 1
	opacity = 0 	// changed in New()
	layer = MOB_LAYER + 0.1
	anchored = 1
	name = "ice wall"
	desc = "A wall of ice."

	New()
		..()
		update_nearby_tiles(1)

	Del()
		density = 0
		update_nearby_tiles(1)
		..()

	ex_act(severity)
		del(src)

	attack_paw(var/mob/user)
		attack_hand(user)
		return

	attack_hand(var/mob/user)
		if ((HULK in user.mutations) || prob(5) || (SUPRSTR in user.augmentations))
			user << "\blue You smash through the ice wall."
			for(var/mob/O in oviewers(user))
				if ((O.client && !( O.blinded )))
					O << "\red [user] smashes through the ice wall."

			del(src)
		else
			user << "\blue You hit the ice wall, doing absolutely nothing."
		return


	attackby(var/obj/item/I, var/mob/user)

		if(prob(I.force*5))
			user << "\blue You smash through the ice wall with \the [I]."
			for(var/mob/O in oviewers(user))
				if ((O.client && !( O.blinded )))
					O << "\red [user] smashes through the ice wall."
			del(src)
		else
			user << "\blue You hit the ice wall to no effect."

	CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
		if(!istype(mover))
			return 0
		return !density

	proc/update_nearby_tiles(need_rebuild)
		if(!air_master) return 0

		var/turf/simulated/source = loc
		var/turf/simulated/north = get_step(source,NORTH)
		var/turf/simulated/south = get_step(source,SOUTH)
		var/turf/simulated/east = get_step(source,EAST)
		var/turf/simulated/west = get_step(source,WEST)

		if(istype(source)) air_master.tiles_to_update += source
		if(istype(north)) air_master.tiles_to_update += north
		if(istype(south)) air_master.tiles_to_update += south
		if(istype(east)) air_master.tiles_to_update += east
		if(istype(west)) air_master.tiles_to_update += west

		return 1