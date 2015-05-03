/obj/effect/expl_particles
	name = "fire"
	icon = 'effects.dmi'
	icon_state = "explosion_particle"
	opacity = 1
	anchored = 1
	mouse_opacity = 0

/obj/effect/expl_particles/New()
	..()
	spawn (15)
		del(src)
	return

/obj/effect/expl_particles/Move()
	..()
	return

/datum/effect/system/expl_particles
	var/number = 10
	var/turf/location
	var/total_particles = 0

/datum/effect/system/expl_particles/proc/set_up(n = 10, loca)
	number = n
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)

/datum/effect/system/expl_particles/proc/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		spawn(0)
			var/obj/effect/expl_particles/expl = new /obj/effect/expl_particles(src.location)
			var/direct = pick(alldirs)
			for(i=0, i<pick(1;25,2;50,3,4;200), i++)
				sleep(1)
				step(expl,direct)

/obj/effect/explosion
	name = "fire"
	icon = '96x96.dmi'
	icon_state = "explosion"
	opacity = 1
	anchored = 1
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -32
	layer = FLY_LAYER+1

	big
		pixel_x = -80
		pixel_y = -80
		icon = '192x192.dmi'

/obj/effect/explosion/New()
	..()
	spawn (10)
		del(src)
	return

/datum/effect/system/explosion
	var/turf/location
	//var/big = 0
	var/size = 0

/datum/effect/system/explosion/proc/set_up(loca)
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)

/datum/effect/system/explosion/proc/start()
	var/datum/effect/system/expl_particles/P = new/datum/effect/system/expl_particles()
	P.set_up(10,location)
	P.start()
	spawn(5)
		var/datum/effect/effect/system/harmless_smoke_spread/S = new/datum/effect/effect/system/harmless_smoke_spread()
		S.set_up(5,0,location,null)
		S.start()
	spawn(1)
		if(size > 0)
			new/obj/effect/explosion/big( location )
		else
			new/obj/effect/explosion( location )

		playsound(location.loc, "explosion", 100, 1, round(size,1) )

		var/close = range(world.view+round(size,1), location)
		// to all distanced mobs play a different sound
		for(var/mob/M in world) if(M.z == location.z) if(!(M in close))
			// check if the mob can hear
			if(M.ear_deaf <= 0 || !M.ear_deaf) if(!istype(M.loc,/turf/space))
				M << 'explosionfar.ogg'