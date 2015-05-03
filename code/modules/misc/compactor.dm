//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04


/obj/machinery/compactor
	icon = 'recycling.dmi'
	icon_state = "separator-A1"
	name = "garbage compactor"
	desc = "A garbage compaction unit."
	layer = MOB_LAYER+1
	var/id = 1.0
	anchored = 1
	density = 1
	var/obj/machinery/conveyor/conv

/obj/machinery/compactor/New()
	// On us
	..()
	conv = new(loc, EAST, 0)
	update_icon()

/obj/machinery/compactor/update_icon()
	overlays = null

	var/obj/effect/overlay = new/obj
	overlay.icon = 'recycling.dmi'
	overlay.layer = MOB_LAYER+1
	overlay.icon_state = "separator-AO1"
	overlay.pixel_y = 6
	overlays += overlay

/obj/machinery/compactor/Bumped(var/atom/movable/AM)
	// HasEntered didn't like people lying down.
	var/move_dir = get_dir(loc, AM.loc)
	if(istype(AM,/mob/living))
		var/mob/living/H = AM
		if(H.lying && move_dir == WEST)// || move_dir == WEST)
			AM.loc = src.loc
	else if(move_dir == WEST)
		AM.loc = src.loc

/obj/machinery/compactor/proc/setmove(var/on)
	if(conv)
		conv.operating = on
		conv.setmove()

/obj/machinery/compactor/proc/compact()
	var/mamt = 0
	var/gamt = 0
	var/wamt = 0
	var/blood = 0
	var/meat = 0
	var/bone = 0

	for(var/obj/item/scrap/s in loc)
		mamt += s.m_amt
		gamt += s.g_amt
		wamt += s.w_amt
		blood += s.blood
		del(s)

	for(var/obj/effect/decal/cleanable/blood/gibs/b in loc)
		meat++
		blood++
		del(b)

	for(var/mob/living/carbon/h in loc)
		if(!istype(h,/mob/living/carbon/metroid) && !istype(h,/mob/living/carbon/alien))
			meat += 7
			bone += 1
			blood += 7
			del(h)

	if(mamt || gamt || wamt)
		var/obj/item/scrapblock/cube = new(loc)
		cube.blood = min(2,blood)
		cube.set_components(mamt,gamt,wamt)
	else if(meat)
		var/obj/item/gibblock/meatcube = new(loc)
		meatcube.gibamount = meat
		meatcube.bones = bone





/obj/machinery/computer/compactor
	name = "Compactor Control Control"
	desc = "Controls an attached compactor."
	icon_state = "compactor"
	var/id = 1.0
	var/obj/machinery/compactor/connected = null
	var/timing = 0.0
	var/time = 30.0


/obj/machinery/computer/compactor/New()
	..()
	spawn( 5 )
		for(var/obj/machinery/compactor/M in world)
			if (M.id == id)
				connected = M
			else
		return
	return


/obj/machinery/computer/compactor/proc/alarm()
	if(stat & (NOPOWER|BROKEN))
		return

	for(var/obj/machinery/compactor/M in world)
		if(M.id == id)
			M.compact()
	sleep(40)

	//connected.drive()		*****RM from 40.93.3S
	for(var/obj/machinery/compactor/M in world)
		if(M.id == id)
			M.setmove(1)

	sleep(10)
	for(var/obj/machinery/compactor/M in world)
		if(M.id == id)
			M.setmove(0)
	return


/obj/machinery/computer/compactor/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( loc )
				new /obj/item/weapon/shard( loc )

				//generate appropriate circuitboard. Accounts for /pod/old computer types
				var/obj/item/weapon/circuitboard/compactor/M = null
				M = new /obj/item/weapon/circuitboard/compactor( A )

				for (var/obj/C in src)
					C.loc = loc
				M.id = id
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( loc )

				//generate appropriate circuitboard. Accounts for /pod/old computer types
				var/obj/item/weapon/circuitboard/compactor/M = null
				M = new /obj/item/weapon/circuitboard/compactor( A )

				for (var/obj/C in src)
					C.loc = loc
				M.id = id
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else
		attack_hand(user)
	return


/obj/machinery/computer/compactor/attack_ai(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/compactor/attack_paw(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/compactor/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = "<HTML><BODY><TT><B>Compactor Controls</B>"
	user.machine = src
	dat += "<HR><A href = '?src=\ref[src];alarm=1'>Compaction Sequence</A><BR>"
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=computer'>Close</A></TT></BODY></HTML>", user)
	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return


/obj/machinery/computer/compactor/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["alarm"])
			alarm()
		add_fingerprint(usr)
		updateUsrDialog()
	return



/obj/machinery/computer/compactor/old
	icon_state = "old"
	name = "Compactor Control Computer"

/obj/item/weapon/circuitboard/compactor
	name = "Circuit board (Compactor control)"
	build_path = "/obj/machinery/computer/compactor"