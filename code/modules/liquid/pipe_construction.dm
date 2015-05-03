// Disposal pipe construction
// This is the pipe that you drag around, not the attached ones.

/obj/structure/liquidconstruct

	name = "liquid pipe segment"
	desc = "A huge pipe segment used for constructing liquid transfer systems."
	icon = 'liquidpipe.dmi'
	icon_state = "conpipe-s"
	anchored = 0
	density = 0
	pressure_resistance = 5*ONE_ATMOSPHERE
	m_amt = 500
	g_amt = 1350
	level = 2
	var/ptype = 0
	// 0=straight, 1=bent, 2=junction, 3=trunk, 4=pump, 5=filter, 6=port, 7=injection, 8=qport

	var/dpdir = 0	// directions as disposalpipe
	var/base_state = "pipe-s"

	// update iconstate and dpdir due to dir and type
	proc/update()
		var/flip = turn(dir, 180)
		var/left = turn(dir, 90)
		var/right = turn(dir, -90)

		switch(ptype)
			if(0)
				base_state = "pipe-s"
				dpdir = dir | flip
			if(1)
				base_state = "pipe-c"
				dpdir = dir | right
			if(2)
				base_state = "pipe-y"
				dpdir = dir | left | right
			if(3)
				base_state = "pipe-t"
				dpdir = dir
			if(4)
				base_state = "pipe-v"
				dpdir = dir | flip
			if(5)
				base_state = "pipe-f"
				dpdir = dir | flip
			if(6)
				base_state = "port"
				dpdir = 0
			if(7)
				base_state = "port"
				dpdir = 0
			if(8)
				base_state = "qport"
				dpdir = 0


		icon_state = "con[base_state]"

		if(invisibility)				// if invisible, fade icon
			icon -= rgb(0,0,0,128)

	// hide called by levelupdate if turf intact status changes
	// change visibility status and force update of icon
	hide(var/intact)
		invisibility = (intact && level==1) ? 101: 0	// hide if floor is intact
		update()


	// flip and rotate verbs
	verb/rotate()
		set name = "Rotate Pipe"
		set src in view(1)

		if(usr.stat)
			return

		if(anchored)
			usr << "You must unfasten the pipe before rotating it."
			return

		dir = turn(dir, -90)
		update()

	verb/flip()
		set name = "Flip Pipe"
		set src in view(1)
		if(usr.stat)
			return

		if(anchored)
			usr << "You must unfasten the pipe before flipping it."
			return

		dir = turn(dir, 180)
		update()

	// returns the type path of disposalpipe corresponding to this item dtype
	proc/dpipetype()
		switch(ptype)
			if(0,1)
				return /obj/structure/liquidpipe/segment
			if(2)
				return /obj/structure/liquidpipe/junction
			if(3)
				return /obj/structure/liquidpipe/trunk
			if(4)
				return /obj/structure/liquidpipe/pump
			if(5)
				//return /obj/structure/liquidpipe/filter
			if(6)
				return /obj/machinery/liquidport
			if(7)
				return /obj/machinery/liquidport/injector
			if(8)
				return /obj/machinery/liquidport/qport
		return



	// attackby item
	// wrench: (un)anchor
	// weldingtool: convert to real pipe

	attackby(var/obj/item/I, var/mob/user)
		var/nicetype = "pipe"
		var/ispipe = 0 // Indicates if we should change the level of this pipe
		switch(ptype)
			if(4)
				nicetype = "pump"
				ispipe = 1
			if(5)
				nicetype = "filter"
				ispipe = 1
			if(6)
				nicetype = "port"
			if(7)
				nicetype = "injection port"
			if(8)
				nicetype = "quantum port"
			else
				nicetype = "pipe"
				ispipe = 1

		var/turf/T = src.loc
		if(T.intact)
			user << "You can only attach the [nicetype] if the floor plating is removed."
			return

		var/obj/structure/liquidpipe/CP = locate() in T
		if(ptype >= 6 && ptype <= 8) // liquid port
			if(CP) // There's something there
				if(!istype(CP,/obj/structure/liquidpipe/trunk))
					user << "The [nicetype] requires a trunk underneath it in order to work."
					return
			else // Nothing under, fuck.
				user << "The [nicetype] requires a trunk underneath it in order to work."
				return
		else
			if(CP)
				update()
				var/pdir = CP.dpdir
				if(istype(CP, /obj/structure/liquidpipe/broken))
					pdir = CP.dir
				if(pdir & dpdir)
					user << "There is already a [nicetype] at that location."
					return

		//var/obj/structure/liquidpipe/trunk/Trunk = CP

		if(istype(I, /obj/item/weapon/wrench))
			if(anchored)
				anchored = 0
				if(ispipe)
					level = 2
					density = 0
				else
					density = 0
				user << "You detach the [nicetype] from the underfloor."
			else
				anchored = 1
				if(ispipe)
					level = 1 // We don't want disposal bins to disappear under the floors
					density = 0
				else
					density = 0 // We don't want disposal bins or outlets to go density 0
				user << "You attach the [nicetype] to the underfloor."
			playsound(src.loc, 'Ratchet.ogg', 100, 1)
			update()

		else if(istype(I, /obj/item/weapon/weldingtool))
			if(anchored)
				var/obj/item/weapon/weldingtool/W = I
				if(W.remove_fuel(0,user))
					playsound(src.loc, 'Welder2.ogg', 100, 1)
					user << "Welding the [nicetype] in place."
					if(do_after(user, 20))
						if(!src || !W.isOn()) return
						user << "The [nicetype] has been welded in place!"
						update() // TODO: Make this neat
						if(ispipe) // Pipe

							var/pipetype = dpipetype()
							var/obj/structure/liquidpipe/P = new pipetype(src.loc)
							P.base_icon_state = base_state
							P.dir = dir
							P.dpdir = dpdir
							P.updateicon()

						else if(ptype==6) // Disposal bin
							new /obj/machinery/liquidport(src.loc)

						else if(ptype==7) // Disposal outlet
							new /obj/machinery/liquidport/injector(src.loc)

						else if(ptype==8) // Disposal outlet
							new /obj/machinery/liquidport/qport(src.loc)

						del(src)
						return
				else
					user << "You need more welding fuel to complete this task."
					return
			else
				user << "You need to attach it to the plating first!"
				return

/obj/machinery/pipedispenser/liquid
	name = "Liquid Pipe Dispenser"
	icon = 'stationobjs.dmi'
	icon_state = "pipe_d"
	density = 1
	anchored = 1.0

/*
//Allow you to push disposal pipes into it (for those with density 1)
/obj/machinery/pipedispenser/disposal/HasEntered(var/obj/structure/disposalconstruct/pipe as obj)
	if(istype(pipe) && !pipe.anchored)
		del(pipe)

Nah
*/

//Allow you to drag-drop disposal pipes into it
/obj/machinery/pipedispenser/liquid/MouseDrop_T(var/obj/structure/liquidconstruct/pipe as obj, mob/usr as mob)
	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if (!istype(pipe) || get_dist(usr, src) > 1 || get_dist(src,pipe) > 1 )
		return

	if (pipe.anchored)
		return

	del(pipe)

/obj/machinery/pipedispenser/liquid/attack_hand(user as mob)
	if(..())
		return

	var/dat = {"<b>Liquid Pipes</b><br><br>
<A href='?src=\ref[src];dmake=0'>Pipe</A><BR>
<A href='?src=\ref[src];dmake=1'>Bent Pipe</A><BR>
<A href='?src=\ref[src];dmake=2'>Junction</A><BR>
<A href='?src=\ref[src];dmake=3'>Trunk</A><BR>
<A href='?src=\ref[src];dmake=4'>Pump</A><BR>
<A href='?src=\ref[src];dmake=5'>Filter</A><BR>
<A href='?src=\ref[src];dmake=6'>Port</A><BR>
<A href='?src=\ref[src];dmake=7'>Injection Port</A><BR>
<A href='?src=\ref[src];dmake=8'>Quantum Port</A><BR>
"}

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return

// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk


/obj/machinery/pipedispenser/liquid/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["dmake"])
		if(unwrenched || !usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
			usr << browse(null, "window=pipedispenser")
			return
		if(!wait)
			var/p_type = text2num(href_list["dmake"])
			var/obj/structure/liquidconstruct/C = new (src.loc)
			C.ptype = p_type

			C.update()
			wait = 1
			spawn(15)
				wait = 0
	return

