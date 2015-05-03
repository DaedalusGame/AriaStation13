/atom
	var/last_thunder = 0

/obj/item/projectile/beam/thunder
	name = "shock"
	icon_state = ""
	pass_flags = PASSTABLE
	flag = "thunder"
	var/thunderpower = 10000

	New()
		..()
		animate(src, alpha = 0, time = 10)

	fired()
		main = 1
		ID = rand(0,1000)
		var/first = 1
		var/last = 0
		var/obj/effect/effect/laserdealer/lasor = new /obj/effect/effect/laserdealer(null)

		var/xdiff = xo * 32
		var/ydiff = yo * 32
		var/vectordist = sqrt(xdiff * xdiff + ydiff * ydiff)

		var/xunit = 0
		var/yunit = 0
		if(vectordist)
			xunit = xdiff / vectordist
			yunit = ydiff / vectordist

		var/i = 0

		var/failsafe = 1000

		spawn(0)
			lasor.setup(ID)
		spawn(0)
			while(!bumped)
				step_towards(src, current)
				for(var/mob/living/M in loc)
					Bump(M)
				if(!current || loc == current)
					current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
				if(loc == current)
					last += 1
				if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
					del(src)
					return

				var/xoff = (src.x - starting.x) * 32
				var/yoff = (src.y - starting.y) * 32

				var/obj/item/projectile/beam/new_beam

				if(!first)
					new_beam = new src.type(loc)
					processing_objects.Remove(new_beam)
					new_beam.dir = get_dir(starting, current)
					new_beam.ID = ID
					new_beam.icon_state = "thunder[i%2]"
					new_beam.blend_mode = BLEND_ADD
					new_beam.color = rgb(128,192,255)

				if(!first && last != 2)
					var/angle = Get_Angle(starting, current)
					new_beam.transform = turn(new_beam.transform,angle)

					var/xoffexact = xunit * (i * 32)
					var/yoffexact = yunit * (i * 32)
					new_beam.pixel_x = xoffexact - xoff
					new_beam.pixel_y = yoffexact - yoff
				else if(first)
					first = 0
					/*
					new_beam.icon_state = "thunderimpact"
					new_beam.density = 0

					var/xoffexact = xunit * 16
					var/yoffexact = yunit * 16
					new_beam.pixel_x = xoffexact - xoff
					new_beam.pixel_y = yoffexact - yoff*/
				else if(last == 2)
					new_beam.icon_state = "thunderimpact"
					new_beam.density = 0

					var/xoffexact = xunit * (i * 32 + 16)
					var/yoffexact = yunit * (i * 32 + 16)
					new_beam.pixel_x = xoffexact - xoff
					new_beam.pixel_y = yoffexact - yoff


				i+=1
				failsafe -= 1
				if(!failsafe || last == 2)
					bumped = 1
					Bump(get_turf(src))
					break
		return

	on_hit(var/atom/target, var/blocked = 0)
		if(!ismob(target))
			new/obj/effect/effect/thunderfloor(get_turf(target))

			if(prob(60))
				target.emp_act(2)

			//world << "non-mob zapped by [src]"

			thunderpower -= rand(1000,20000)

			spawn(2) target.do_arc(thunderpower)
		else
			var/mob/living/M = target

			var/healthdrain = M.electrocute_act(get_electrocute_damage(), src)
			var/powerdrain = healthdrain * 200

			M.updatehealth()
			if(healthdrain > 100)
				if(M.getFireLoss() > 200)
					for(var/i=0, i<5, i++)
						new/obj/effect/decal/ash(loc)
					del(M)
				if(M.getBruteLoss() > 200)
					M.gib()

			if(powerdrain)
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

			//thunderpower -= powerdrain

			//world << "mob zapped by [src]"

			if(M)
				spawn(2) M.do_arc(thunderpower)
		return 1

	proc/get_electrocute_damage()
		switch(thunderpower)
			if (2000000 to INFINITY) //Enough to destroy missiles, enough to destroy a weak flesh body
				return min(rand(250,360),rand(250,360))
			if (1000000 to INFINITY)
				return min(rand(50,160),rand(50,160))
			if (200000 to 1000000-1)
				return min(rand(25,80),rand(25,80))
			if (100000 to 200000-1)//Ave powernet
				return min(rand(20,60),rand(20,60))
			if (50000 to 100000-1)
				return min(rand(15,40),rand(15,40))
			if (1000 to 50000-1)
				return min(rand(10,20),rand(10,20))
			else
				return 0

/atom/proc/do_arc(var/thunderpower)
	if(!src || !thunderpower)
		return

	var/turf/curloc = get_turf(src)

	if(!curloc) return

	if(curloc.last_thunder > world.time-30)
		return

	curloc.last_thunder = world.time

	//world << "trying to arc..."
	var/arcrange = get_arc_range(thunderpower)
	var/list/targets = list()

	for(var/atom/pottarget in orange(arcrange,curloc))
		if(isarea(pottarget)) continue
		if(curloc == get_turf(pottarget)) return //Infinite laser length for some reason.
		if(pottarget && (prob(10) || pottarget.flags & CONDUCT))
			targets += pottarget
			//world << "maybe arcing to [pottarget]"

	if(!targets.len) return

	var/atom/pickedtarget = pick(targets)

	var/turf/targloc = get_turf(pickedtarget)

	//world << "arcing to [pickedtarget]"

	playsound(curloc, 'stealthoff.ogg', 50, 1)

	var/obj/item/projectile/beam/thunder/newarc = new(curloc)
	newarc.original = targloc
	newarc.starting = curloc
	newarc.current = curloc
	newarc.yo = targloc.y - curloc.y
	newarc.xo = targloc.x - curloc.x
	newarc.thunderpower = thunderpower
	spawn() newarc.fired()

/atom/proc/get_arc_range(var/thunderpower)
	switch(thunderpower)
		if (1000000 to INFINITY)
			return 7
		if (200000 to 1000000-1)
			return 5
		if (100000 to 200000-1)
			return 4
		if (50000 to 100000-1)
			return 3
		if (1000 to 50000-1)
			return 2
		else
			return 1

/turf/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam/thunder))
		var/obj/item/projectile/beam/thunder/zap = Proj
		var/thunderpower = zap.thunderpower
		thunderpower -= rand(100,2000)

		new/obj/effect/effect/thunderfloor(src)

		if(prob(30))
			thunderpower -= rand(1000,4000)
			src.emp_act(2)

		spawn(2) src.do_arc(thunderpower)
		return 1
	..()
	return 0

/obj/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam/thunder))
		var/obj/item/projectile/beam/thunder/zap = Proj
		var/thunderpower = zap.thunderpower
		thunderpower -= rand(100,2000)

		new/obj/effect/effect/thunderfloor(get_turf(src))

		if(prob(30))
			thunderpower -= rand(1000,4000)
			src.emp_act(2)

		spawn(2) src.do_arc(thunderpower)
		return 1
	..()
	return 0

/obj/effect/effect/thunderfloor
	name = "sparks"
	icon = 'tile_effects.dmi'
	icon_state = "thunder"
	blend_mode = BLEND_ADD
	color = rgb(128,192,255)

	var/amount = 6.0
	anchored = 1.0
	mouse_opacity = 0

/obj/effect/effect/thunderfloor/process()
	if(alpha <= 10)
		del(src)
	return

/obj/effect/effect/thunderfloor/New()
	..()
	processing_objects.Add(src)

	playsound(src.loc, "sparks", 100, 1)
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)
	animate(src, alpha = 0, time = 10)
	spawn (100)
		del(src)
	return

/obj/effect/effect/thunderfloor/Del()
	processing_objects.Remove(src)

	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)
	..()
	return

/obj/effect/effect/thunderfloor/Move()
	..()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)
	return