#define LIQUIDPORT_SUCTION 10
#define LIQUIDPUMP_SUCTION 20

var/datum/liquidnet/liquidnet_controller = null
var/liquidpipes = list()

/datum/liquidnet

	var/processing = 0
	var/process_cost = 0
	var/iteration = 0

	New()
		if(liquidnet_controller != src)
			liquidnet_controller = src

	proc/process()
		processing = 1
		spawn(0)
			set background = 1
			while(1)
				if(processing)
					iteration++

					for(var/obj/structure/liquidpipe/LP in liquidpipes)
						LP.transfer()

				sleep(liquid_delay)

/obj/machinery/liquidport
	icon = 'liquidpipe.dmi'
	name = "liquid port"
	desc = "A connector to an underfloor liquid pipe."
	icon_state = "port"
	anchored = 1
	density = 0
	flags = NOREACT
	level = 2			// overfloor only
	layer = 2.4
	var/valve = 0

	New()
		..()

		//spawn(100) changevalve(valve)

	proc/get_reagents()
		var/obj/structure/liquidpipe/trunk/TR = locate() in src.loc

		if(TR)
			return TR.reagents
		else
			return null

	//proc/changevalve(var/newvalve)
	//	for(var/obj/structure/liquidpipe/trunk/TR in src.loc)
	//		if(valve)
	//			TR.changesuction(0)
	//		else
	//			TR.changesuction(LIQUIDPORT_SUCTION)

	process()
		var/datum/reagents/R = get_reagents()

		for(var/obj/structure/liquidpipe/trunk/TR in src.loc)
			if(valve)
				TR.changesuction(0)
			else
				TR.changesuction(LIQUIDPORT_SUCTION)

		if(!R) return

		for(var/obj/machinery/M in src.loc)
			if(M != src && M.anchored)
				if(!M.reagents) continue
				if(!valve)
					R.trans_to(M,100)
					//world << "transferring reagents from port to machine"
				else
					M.reagents.trans_to(R.my_atom,100)
					//world << "transferring reagents from machine to port"
	injector
		name = "injection port"

		New()
			..()

			var/datum/reagents/R = new/datum/reagents(100)
			reagents = R
			R.my_atom = src

		process()
			var/datum/reagents/R = get_reagents()

			if(!R) return

			R.trans_to(src,100)
			reagents.reaction(loc)

			for(var/obj/structure/liquidpipe/trunk/TR in src.loc)
				TR.changesuction(LIQUIDPORT_SUCTION)
			//reagents.remove_any(2500)

/obj/structure/liquidpipe
	icon = 'liquidpipe.dmi'
	name = "liquid pipe"
	desc = "An underfloor liquid pipe."
	anchored = 1
	density = 0
	flags = NOREACT

	level = 1			// underfloor only
	var/dpdir = 0		// bitmask of pipe directions
	dir = 0				// dir will contain dominant direction for junction pipes
	var/health = 10 	// health points 0-10
	layer = 2.3			// slightly lower than wires and other pipes
	var/base_icon_state	// initial icon state on map

	var/transferamt = 100
	var/volume = 2500
	var/pump = 0
	var/suction = 0
	var/pumpsuction = 0

	proc/changesuction(var/newsuction)
		suction = newsuction

		if(pumpsuction == newsuction)
			return

		resetsuction(suction)
		pumpsuction = newsuction

	proc/resetsuction(var/limit,var/fromdir = 0)
		set background = 1

		if(limit <= 0)
			return

		suction = 0

		var/list/spread_directions = list(1,2,4,8)

		spread_directions -= fromdir

		for(var/d in spread_directions)
			if(d & dpdir)
				var/turf/T = get_step(src,d)
				if(!T)
					continue
				for(var/obj/structure/liquidpipe/P in T)
					if(P && P.dpdir & turn(d,180))
						spawn(0)
							P.resetsuction(limit-1,turn(d,180))

	proc/getsuction(var/fromdir)
		return suction


	// new pipe, set the icon_state as on map
	New()
		..()

		var/datum/reagents/R = new/datum/reagents(volume)
		reagents = R
		R.my_atom = src

		base_icon_state = icon_state
		liquidpipes += src
		return


	// pipe is deleted
	// ensure if holder is present, it is expelled
	Del()
		expel()
		del(reagents)
		liquidpipes -= src
		..()

	// transfer the holder through this pipe segment
	// overriden for special behaviour
	//
	proc/transfer()
		var/list/spread_directions = list(1,2,4,8)
		//var/surrounding_volume = 0

		for(var/d in spread_directions)
			if(d & dpdir)
				var/turf/T = get_step(src,d)
				if(!T)
					continue
				for(var/obj/structure/liquidpipe/P in T)
					if(!P)
						spread_directions -= d
					else if(P.dpdir & turn(d,180))
						suction = max(suction,P.getsuction(turn(d,180))-1)
						if(P.getsuction(turn(d,180)) <= suction)
							spread_directions -= d
					//surrounding_volume += P.reagents.total_volume

		if(!spread_directions.len)
			return //No suitable candidate to spread to

		/*var/average_volume = (src.reagents.total_volume + surrounding_volume) / (spread_directions.len + 1)
		var/volume_difference = src.reagents.total_volume - average_volume
		//if(volume_difference <= (spread_directions.len*0.05))
		//	return

		var/volume_per_tile = volume_difference / spread_directions.len

		for(var/direction in spread_directions)
			if(direction & dpdir)
				var/turf/T = get_step(src,direction)
				if(!T)
					continue
				var/obj/structure/liquidpipe/P = locate(/obj/structure/liquidpipe) in T
				if(P && (P.dpdir & turn(direction,180)))
					reagents.trans_to(P,volume_per_tile)

		updateicon()

		return volume_difference*/

		updateicon()

		for(var/direction in spread_directions)
			if(direction & dpdir)
				var/turf/T = get_step(src,direction)
				if(!T)
					continue
				for(var/obj/structure/liquidpipe/P in T)
					if(P && (P.dpdir & turn(direction,180)))
						reagents.trans_to(P,transferamt / spread_directions.len)


	// update the icon_state to reflect hidden status
	proc/update()
		var/turf/T = src.loc
		hide(T.intact && !istype(T,/turf/space))	// space never hides pipes

	// hide called by levelupdate if turf intact status changes
	// change visibility status and force update of icon
	hide(var/intact)
		invisibility = intact ? 101: 0	// hide if floor is intact
		updateicon()

	// update actual icon_state depending on visibility
	// if invisible, append "f" to icon_state to show faded version
	// this will be revealed if a T-scanner is used
	// if visible, use regular icon_state
	proc/updateicon()
		icon_state = base_icon_state

		update_reagent()

		var/obj/effect/overlay = new/obj
		overlay.icon = 'liquidpipe.dmi'
		overlay.icon_state = "glass[icon_state]"
		overlay.layer = layer+0.01

		overlays += overlay

		return

	proc/update_reagent()
		overlays = null

		if(reagents.total_volume)
			var/obj/effect/overlay = new/obj
			overlay.icon = 'liquidpipe.dmi'
			overlay.layer = layer

			if(reagents.get_reagent_amount("lava"))
				overlay.icon_state = "lava[icon_state]"
	//		else if(reagents.get_reagent_amount("phazon"))
	//			overlay.icon_state = "phazon[overlay.icon_state]"
			else
				overlay.icon_state = "fill[icon_state]"
				var/list/rgbcolor = list(0,0,0)
				var/finalcolor
				for(var/datum/reagent/re in reagents.reagent_list) // natural color mixing bullshit/algorithm
					if(!finalcolor)
						rgbcolor = GetColors(re.color)
						finalcolor = re.color
					else
						var/newcolor[3]
						var/prergbcolor[3]
						prergbcolor = rgbcolor
						newcolor = GetColors(re.color)

						rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
						rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
						rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

						finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])
						// This isn't a perfect color mixing system, the more reagents that are inside,
						// the darker it gets until it becomes absolutely pitch black! I dunno, maybe
						// that's pretty realistic? I don't do a whole lot of color-mixing anyway.
						// If you add brighter colors to it it'll eventually get lighter, though.

				overlay.icon += finalcolor

			overlays += overlay

	// expel the held objects into a turf
	// called when there is a break in the pipe
	//

	proc/expel()
		reagents.reaction(loc)
		return

	// call to break the pipe
	// will expel any holder inside at the time
	// then delete the pipe
	// remains : set to leave broken pipe pieces in place
	proc/broken(var/remains = 0)
		if(remains)
			for(var/D in cardinal)
				if(D & dpdir)
					var/obj/structure/liquidpipe/broken/P = new(src.loc)
					P.dir = D

		spawn(2)	// delete pipe after 2 ticks to ensure expel proc finished
			del(src)


	// pipe affected by explosion
	ex_act(severity)

		switch(severity)
			if(1.0)
				broken(0)
				return
			if(2.0)
				health -= rand(5,15)
				healthcheck()
				return
			if(3.0)
				health -= rand(0,15)
				healthcheck()
				return


	// test health for brokenness
	proc/healthcheck()
		if(health < -2)
			broken(0)
		else if(health<1)
			broken(1)
		return

	//attack by item
	//weldingtool: unfasten and convert to obj/disposalconstruct

/*	attackby(var/obj/item/I, var/mob/user)

		var/turf/T = src.loc
		if(T.intact)
			return		// prevent interaction with T-scanner revealed pipes

		if(istype(I, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/W = I

			if(W.remove_fuel(0,user))
				playsound(src.loc, 'Welder2.ogg', 100, 1)
				// check if anything changed over 2 seconds
				var/turf/uloc = user.loc
				var/atom/wloc = W.loc
				user << "Slicing the disposal pipe."
				sleep(30)
				if(!W.isOn()) return
				if(user.loc == uloc && wloc == W.loc)
					welded()
				else
					user << "You must stay still while welding the pipe."
			else
				user << "You need more welding fuel to cut the pipe."
				return */

	// called when pipe is cut with welder
/*	proc/welded()

		var/obj/structure/disposalconstruct/C = new (src.loc)
		switch(base_icon_state)
			if("pipe-s")
				C.ptype = 0
			if("pipe-c")
				C.ptype = 1
			if("pipe-j1")
				C.ptype = 2
			if("pipe-j2")
				C.ptype = 3
			if("pipe-y")
				C.ptype = 4
			if("pipe-t")
				C.ptype = 5

		C.dir = dir
		C.density = 0
		C.anchored = 1
		C.update()

		del(src) */

// *** TEST verb
//client/verb/dispstop()
//	for(var/obj/structure/disposalholder/H in world)
//		H.active = 0

// a straight or bent segment
/obj/structure/liquidpipe/segment
	icon_state = "pipe-s"

	New()
		..()
		if(icon_state == "pipe-s")
			dpdir = dir | turn(dir, 180)
		else
			dpdir = dir | turn(dir, -90)

		update()
		return

/obj/structure/liquidpipe/pump
	icon_state = "pipe-v0"

	var/on = 0

	New()
		..()

		dpdir = dir | turn(dir, 180)

		if(on)
			changesuction(LIQUIDPUMP_SUCTION)
		else
			changesuction(0)

		update()
		return

	updateicon()
		icon_state = "pipe-v[on]"

		update_reagent()

		var/obj/effect/overlay = new/obj
		overlay.icon = 'liquidpipe.dmi'
		overlay.icon_state = "glass[icon_state]"
		overlay.layer = layer+0.01

		overlays += overlay

		return

	getsuction(var/fromdir)
		if(fromdir == turn(dir,180))
			return suction
		else
			return 0

	transfer()
		var/turf/T = get_step(src,turn(dir,180))
		/*if(T)
			var/obj/structure/liquidpipe/P = locate(/obj/structure/liquidpipe) in T
			if(P && P.dpdir & dir)
				suction = max(suction,P.getsuction(dir)-1)*/

		if(on)
			changesuction(LIQUIDPUMP_SUCTION)
		else
			changesuction(0)

		updateicon()

		T = get_step(src,dir)
		if(T)
			var/obj/structure/liquidpipe/P = locate(/obj/structure/liquidpipe) in T
			if(P && (P.dpdir & turn(dir,180)))
				reagents.trans_to(P,transferamt)

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		on = !on

		if(on)
			changesuction(LIQUIDPUMP_SUCTION)
		else
			changesuction(0)

		updateicon()



//a three-way junction with dir being the dominant direction
/obj/structure/liquidpipe/junction
	icon_state = "pipe-y"

	New()
		..()
		dpdir = dir | turn(dir,90) | turn(dir, -90)
		update()
		return

//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/liquidpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked = null

/obj/structure/liquidpipe/trunk/New()
	..()
	dpdir = dir
	spawn(1)
		getlinked()

	update()
	return

/obj/structure/liquidpipe/trunk/proc/getlinked()
	linked = null
	var/obj/machinery/mineral/pump/P = locate() in src.loc
	if(P && P.anchored)
		linked = P

	var/obj/machinery/liquidtank/T = locate() in src.loc
	if(T && T.anchored)
		linked = T

	update()
	return

	// Override attackby so we disallow trunkremoval when somethings ontop
/*
/obj/structure/disposalpipe/trunk/attackby(var/obj/item/I, var/mob/user)

	//Disposal constructors
	var/obj/structure/disposalconstruct/C = locate() in src.loc
	if(C && C.anchored)
		return



	var/turf/T = src.loc
	if(T.intact)
		return		// prevent interaction with T-scanner revealed pipes

	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I

		if(W.remove_fuel(0,user))
			playsound(src.loc, 'Welder2.ogg', 100, 1)
			// check if anything changed over 2 seconds
			var/turf/uloc = user.loc
			var/atom/wloc = W.loc
			user << "Slicing the disposal pipe."
			sleep(30)
			if(!W.isOn()) return
			if(user.loc == uloc && wloc == W.loc)
				welded()
			else
				user << "You must stay still while welding the pipe."
		else
			user << "You need more welding fuel to cut the pipe."
			return

	// would transfer to next pipe segment, but we are in a trunk
	// if not entering from disposal bin,
	// transfer to linked object (outlet or bin)
*/

/obj/structure/liquidpipe/trunk/transfer()
	//if(!..())
		//getlinked()

		//if(linked && linked:valve)
		//	src.reagents.trans_to(linked,100)
		//else if(!linked)
		//	src.expel()

	..()

	for(var/obj/machinery/liquidport/P in loc)
		if(!P.valve)
			reagents.trans_to(P,100)
		//world << "transferring reagents from trunk to port"

	return null

// a broken pipe
/obj/structure/liquidpipe/broken
	icon_state = "pipe-b"
	dpdir = 0		// broken pipes have dpdir=0 so they're not found as 'real' pipes
					// i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

	New()
		..()
		update()
		return

	// called when welded
	// for broken pipe, remove and turn into scrap

//	welded()
//		var/obj/item/scrap/S = new(src.loc)
//		S.set_components(200,0,0)
//		del(src)

