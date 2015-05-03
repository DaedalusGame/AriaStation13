#define LIQUID_TRANSFER_THRESHOLD 0.05

var/liquid_delay = 15

var/list/datum/puddle/puddles = list()

var/datum/liquid_controller/puddle_controller = null

datum/liquid_controller
	var/processing = 0
	var/process_cost = 0
	var/iteration = 0

datum/liquid_controller/New()
	if(puddle_controller != src)
		puddle_controller = src

datum/liquid_controller/proc/process()
	processing = 1
	spawn(0)
		set background = 1
		while(1)
			if(processing)
				iteration++

				for(var/datum/puddle/PU in puddles)
					if(!PU.processing)
						PU.process()

			sleep(liquid_delay)

datum/puddle
	var/list/obj/effect/liquid/liquid_objects = list()
	var/processing = 0

datum/puddle/proc/process()
	//world << "DEBUG: Puddle process!"
	processing = 1

	var/cooldown = 0

	for(var/obj/effect/liquid/L in liquid_objects)
		if(cooldown > 20)
			sleep(10)
			cooldown = 0

		if(L)
			L.spread()
		if(L)
			L.apply_calculated_effect()
		if(L)
			L.apply_standard_effect()
		cooldown++

	processing = 0

	if(liquid_objects.len == 0)
		del(src)

datum/puddle/New()
	..()
	puddles += src

datum/puddle/Del()
	puddles -= src
	for(var/obj/O in liquid_objects)
		del(O)
	..()

client/proc/setliquiddelay(var/delay)
	if(isnum(delay) && delay > 0)
		liquid_delay = delay
		return liquid_delay

client/proc/splash()
	var/volume = input("Volume?","Volume?", 0 ) as num
	if(!isnum(volume)) return
	if(volume <= LIQUID_TRANSFER_THRESHOLD) return
	var/turf/T = get_turf(src.mob)
	if(!isturf(T)) return
	trigger_splash(T, volume)

client/proc/lavasplash()
	var/volume = input("Volume?","Volume?", 0 ) as num
	if(!isnum(volume)) return
	if(volume <= LIQUID_TRANSFER_THRESHOLD) return
	var/turf/T = get_turf(src.mob)
	if(!isturf(T)) return
	trigger_lava(T, volume)

proc/trigger_splash(turf/epicenter as turf, volume as num)
	if(!epicenter)
		return
	if(volume <= 0)
		return

	var/obj/effect/liquid/L = new/obj/effect/liquid(epicenter)
	if(!L)
		return
	L.volume = volume
	L.update_icon2()
	var/datum/puddle/P = new/datum/puddle()
	P.liquid_objects.Add(L)
	L.controller = P

proc/trigger_lava(turf/epicenter as turf, volume as num)
	if(!epicenter)
		return
	if(volume <= 0)
		return

	var/obj/effect/liquid/L = new/obj/effect/liquid/lava(epicenter)
	if(!L)
		return
	L.volume = volume
	L.update_icon2()
	var/datum/puddle/P = new/datum/puddle()
	P.liquid_objects.Add(L)
	L.controller = P



obj/effect/liquid
	icon = 'icons/effects/liquid.dmi'
	icon_state = "0"
	name = "liquid"
	layer = 2.9
	mouse_opacity = 0
	var/volume = 0
	var/new_volume = 0
	var/datum/puddle/controller
	var/liquidtype = ""

obj/effect/liquid/lava
	icon_state = "lava0"
	name = "lava"
	desc = "A sea of molten stone and metal."
	liquidtype = "lava"
	var/set_temperature = 30000		// in celcius, add T0C for kelvin
	blend_mode = BLEND_ADD

	apply_standard_effect()
		set background = 1

		..()

		//if(LuminosityRed != 5)
		//	ul_SetLuminosity(5,4,0)

		if(!loc)
			return

//		var/datum/gas_mixture/env = loc.return_air()
//		if(env)
//			var/datum/gas_mixture/flow = env.remove_ratio(0.25)
//			if(flow)
//				flow.temperature = max(set_temperature,flow.temperature)
//			loc.assume_air(flow) //Then put it back where you found it

		if(prob(10) && istype(loc,/turf/simulated/floor) && !istype(loc,/turf/simulated/floor/engine/molten) && !istype(loc,/turf/simulated/floor/engine/containment))
			new /turf/simulated/floor/engine/molten(src.loc)

		Incinerate()

	proc/Incinerate()
		set background = 1

		for(var/mob/living/M in src.loc)
			if(M && prob(66))
				M.apply_damage(100,BURN)
				M.updatehealth()
				if(M.getFireLoss() > 200)
					for(var/i=0, i<5, i++)
						new/obj/effect/decal/ash(loc)
					del(M)

		for(var/obj/I in src.loc)
			if(!I || prob(66))
				continue

			if(istype(I,/obj/item))
				new/obj/effect/decal/ash(loc)
				del(I)
			else if(!istype(loc,/turf/simulated/floor/engine/containment))
				if(istype(I,/obj/effect/decal) || istype(I,/obj/effect/glowshroom) || istype(I,/obj/effect/phazon) || istype(I,/obj/structure) || istype(I,/obj/machinery))
					del(I)

	Del()
//		if(LuminosityRed == 5)
//			ul_SetLuminosity(0,0,0)
		..()

obj/effect/liquid/New()
	..()

	if( !isturf(loc) )
		del(src)

	for( var/obj/effect/liquid/L in loc )
		if(L != src)
			L.volume += volume
			del(src)

	if(src)
		icon_state = "[liquidtype]8"

obj/effect/liquid/proc/spread()
	set background = 1

	//world << "DEBUG: liquid spread!"
	var/surrounding_volume = 0
	var/list/spread_directions = list(1,2,4,8)
	var/turf/loc_turf = loc
	for(var/direction in spread_directions)
		var/turf/T = get_step(src,direction)
		if(!T)
			spread_directions.Remove(direction)
			//world << "ERROR: Map edge!"
			continue //Map edge
		if(!loc_turf.can_leave_liquid(direction,src)) //Check if this liquid can leave the tile in the direction
			spread_directions.Remove(direction)
			continue
		if(!T.can_accept_liquid(turn(direction,180),src)) //Check if this liquid can enter the tile
			spread_directions.Remove(direction)
			T.on_deny_liquid(src)
			continue
		var/obj/effect/liquid/L = locate(/obj/effect/liquid) in T
		if(L)
			if(L.volume >= src.volume)
				spread_directions.Remove(direction)
				continue
			surrounding_volume += L.volume //If liquid already exists, add it's volume to our sum
		else
			var/obj/effect/liquid/NL = new src.type(T) //Otherwise create a new object which we'll spread to.

			NL.controller = src.controller
			controller.liquid_objects.Add(NL)
			T.on_accept_liquid(NL)

	if(!spread_directions.len)
		//world << "ERROR: No candidate to spread to."
		return //No suitable candidate to spread to

	var/average_volume = (src.volume + surrounding_volume) / (spread_directions.len + 10) //Average amount of volume on this and the surrounding tiles.
	var/volume_difference = src.volume - average_volume //How much more/less volume this tile has than the surrounding tiles.
	if(volume_difference <= (spread_directions.len*LIQUID_TRANSFER_THRESHOLD)) //If we have less than the threshold excess liquid - then there is nothing to do as other tiles will be giving us volume.or the liquid is just still.
		//world << "ERROR: transfer volume lower than THRESHOLD!"
		return

	var/volume_per_tile = volume_difference / spread_directions.len

	for(var/direction in spread_directions)
		var/turf/T = get_step(src,direction)
		if(!T)
			//world << "ERROR: Map edge 2!"
			continue //Map edge
		var/obj/effect/liquid/L = locate(/obj/effect/liquid) in T
		if(L)
			src.volume -= volume_per_tile //Remove the volume from this tile
			L.new_volume = L.new_volume + volume_per_tile //Add it to the volume to the other tile

obj/effect/liquid/proc/apply_standard_effect()
	return

obj/effect/liquid/proc/apply_calculated_effect()
	volume += new_volume

	if(volume < LIQUID_TRANSFER_THRESHOLD)
		del(src)
	new_volume = 0
	update_icon2()

obj/effect/liquid/Move()
	return 0

obj/effect/liquid/Del()
	if(src.controller)
		src.controller.liquid_objects.Remove(src)
	..()

obj/effect/liquid/proc/update_icon2()
	//icon_state = num2text( max(1,min(7,(floor(volume),10)/10)) )

	overlays = null

	icon_state = "[liquidtype]8"

	var/obj/effect/overlay = new/obj
	overlay.icon = 'liquid.dmi'
	overlay.layer = FLY_LAYER
	overlay.blend_mode = blend_mode
	overlay.icon_state = "[liquidtype]8"

	switch(volume)
		if(0 to 0.1)
			if(liquidtype != "lava")
				del(src)
			overlay.alpha = 0
		if(0.1 to 5)
			//overlay.icon_state = "[liquidtype]1"
			overlay.alpha = 16
		if(5 to 10)
			//overlay.icon_state = "[liquidtype]2"
			overlay.alpha = 32
		if(10 to 20)
			//overlay.icon_state = "[liquidtype]3"
			overlay.alpha = 64
		if(20 to 30)
			//overlay.icon_state = "[liquidtype]4"
			overlay.alpha = 80
		if(30 to 40)
			//overlay.icon_state = "[liquidtype]5"
			overlay.alpha = 96
		if(40 to 50)
			//overlay.icon_state = "[liquidtype]6"*/
			overlay.alpha = 112
		if(50 to INFINITY)
			//overlay.icon_state = "[liquidtype]8"
			overlay.alpha = 128

	if(src)
		overlays += overlay

turf/proc/can_accept_liquid(from_direction,var/obj/effect/liquid/l)
	return 0
turf/proc/can_leave_liquid(from_direction,var/obj/effect/liquid/l)
	return 0
turf/proc/on_accept_liquid(var/obj/effect/liquid/l)
	return 0
turf/proc/on_deny_liquid(var/obj/effect/liquid/l)
	return 0

turf/simulated/floor/plating/airless/lava/on_accept_liquid(var/obj/effect/liquid/l)
	del(l)

turf/simulated/wall/on_deny_liquid(var/obj/effect/liquid/l)
	if(l.liquidtype == "lava" && prob(20))
		if (prob(15))
			dismantle_wall()
		else if(prob(70))
			ReplaceWithPlating()
	return 0

turf/simulated/floor/can_accept_liquid(from_direction,var/obj/effect/liquid/l)
	for(var/obj/structure/window/W in src)
		if(W.dir in list(5,6,9,10))
			if(l.liquidtype == "lava" && prob(20))
				del(W)
			return 0
		if(W.dir & from_direction)
			if(l.liquidtype == "lava" && prob(20))
				del(W)
			return 0
	for(var/obj/O in src)
		if(!O.liquid_pass(l))
			return 0
	return 1

turf/simulated/floor/can_leave_liquid(to_direction,var/obj/effect/liquid/l)
	for(var/obj/structure/window/W in src)
		if(W.dir in list(5,6,9,10))
			if(l.liquidtype == "lava" && prob(20))
				del(W)
			return 0
		if(W.dir & to_direction)
			if(l.liquidtype == "lava" && prob(20))
				del(W)
			return 0
	for(var/obj/O in src)
		if(!O.liquid_pass(l))
			return 0
	return 1

turf/simulated/wall/can_accept_liquid(from_direction,var/obj/effect/liquid/l)
	return 0
turf/simulated/wall/can_leave_liquid(from_direction,var/obj/effect/liquid/l)
	return 0

obj/proc/liquid_pass(var/obj/effect/liquid/l)
	return 1

obj/machinery/door/liquid_pass(var/obj/effect/liquid/l)
	if(l.liquidtype == "lava" && prob(20))
		del(src)
		return 0

	return !density

/obj/effect/meteor/lava
	name = "small lavablob"
	icon_state = "lavablob1"
	pass_flags = PASSTABLE | PASSGRILLE
	var/volume = 10
	var/icon/preicon

	medium
		name = "lavablob"
		icon_state = "lavablob2"
		pass_flags = PASSTABLE
		volume = 100

	big
		name = "big lavablob"
		icon_state = "lavablob3"
		pass_flags = 0
		volume = 1000

/obj/effect/meteor/lava/New()
	..()

	spawn(1)
		update_icon()

/obj/effect/meteor/lava/update_icon()
	if(preicon)
		icon = preicon
	else
		var/icon/newicon = icon(icon,icon_state)
		var/icon/overlayicon = icon(icon,"[icon_state]o")
		newicon.Blend(overlayicon,ICON_OR)
		preicon = newicon
		icon = newicon

/obj/effect/meteor/lava/Bump(atom/A)
	spawn(0)
		//if (A)
			//A.meteorhit(src)
			//playsound(src.loc, 'meteorimpact.ogg', 40, 1)
		var/turf/epicenter = get_turf(src)
		trigger_lava(epicenter, volume)
		del(src)
	return

turf/space/can_accept_liquid(from_direction,var/obj/effect/liquid/l)
	return 1
turf/space/can_leave_liquid(from_direction,var/obj/effect/liquid/l)
	return 1

turf/space/on_accept_liquid(var/obj/effect/liquid/l)
	if(l.liquidtype == "lava" && prob(10))
		var/obj/effect/meteor/lava/M
		var/volume = rand(1,200)

		switch(volume)
			if(0.1 to 10)
				M = new /obj/effect/meteor/lava( src )
			if(10 to 100)
				M = new /obj/effect/meteor/lava/medium( src )
			if(100 to INFINITY)
				M = new /obj/effect/meteor/lava/big( src )

		if(M)
			var/list/spread_directions = list(1,2,4,5,6,8,9,10)

			var/newdir = pick(spread_directions)
			while(spread_directions.len && !istype(get_step(M,newdir),/turf/space))
				newdir = pick(spread_directions)
				spread_directions -= newdir

			if(istype(get_step(M,newdir),/turf/space))
				M.volume = volume
				M.SpinAnimation(10,-1)
				spawn(0)
					walk(M, newdir, 1)
	del(l)

#undef LIQUID_TRANSFER_THRESHOLD