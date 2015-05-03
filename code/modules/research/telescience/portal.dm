var/teleporter_constA = 1
var/teleporter_constB = 0
var/teleporter_constC = 1
var/teleporter_constD = 0

/obj/machinery/computer/portal
	name = "Portal"
	desc = "Used to control a linked Portal Hub."
	icon_state = "teleport"
	circuit = "/obj/item/weapon/circuitboard/portal"
	var/obj/effect/teleportal/portalin = null
	var/obj/effect/teleportal/portalout = null
	var/list/destinations = list()
	var/id = null
	var/destx = 0
	var/desty = 0
	var/destz = 0
	var/teleportmode = 1
	var/timing = 0.0
	var/time = 30.0
	var/server = 0

/obj/machinery/computer/portal/New()
	teleporter_constA = 1/rand(2,20)
	teleporter_constB = rand(0,100)
	teleporter_constC = 1/rand(2,20)
	teleporter_constD = rand(0,100)
	//src.id = text("[]", rand(1000, 9999))
	spawn(3)
		if(!stat)
			initialdest()

	if(stat & BROKEN)
		set_broken()

	..()
	return

/obj/machinery/computer/portal/proc/initialdest()
	for(var/obj/machinery/portal_beacon/B in world)
		var/datum/teledest/TD = new()
		TD.name = B.telename
		TD.x = (B.x - teleporter_constB) / teleporter_constA
		TD.y = (B.y - teleporter_constD) / teleporter_constC
		TD.z = B.z
		destinations += TD

/obj/machinery/computer/portal/Del()
	if(portalin)
		del(portalin)
	if(portalout)
		del(portalout)
	..()

/obj/machinery/computer/portal/attackby(I as obj, user as mob)
	if(stat & (NOPOWER|BROKEN))
		src.attack_hand()

	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( loc )
				new /obj/item/weapon/shard( loc )

				//generate appropriate circuitboard. Accounts for /pod/old computer types
				var/obj/item/weapon/circuitboard/portal/M = new /obj/item/weapon/circuitboard/portal( A )

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
				var/obj/item/weapon/circuitboard/portal/M = new /obj/item/weapon/circuitboard/portal( A )

				for (var/obj/C in src)
					C.loc = loc
				M.id = id
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else if (istype(I, /obj/item/weapon/card/data))
		var/obj/item/weapon/card/data/M = I

		if(!M.function || M.function == "teleporter")
			var/datum/teledest/TD = new()
			TD.name = input(usr,"Name:","Enter name for destination","")
			TD.x = destx
			TD.y = desty
			TD.z = destz
			M.data = TD
			if(M.function != "teleporter")
				user << "\blue Destination saved to datacard."
			else
				user << "\blue Datacard overwritten."
			M.function = "teleporter"
			M.name = "[M]([TD.name])"
		else if(M.function != "teleporter")
			src.attack_hand()

		if(istype(M.data,/datum/teledest) && !(M.data in destinations))
			destinations += M.data
			user << "\blue Destination added to location repository."
		return
	else
		..()
	return

/obj/machinery/computer/portal/attack_ai()
	src.attack_hand()

/obj/machinery/computer/portal/attack_paw()
	src.attack_hand()

/obj/machinery/computer/portal/proc/isopen()
	if(portalin || portalout)
		return 1

/obj/machinery/computer/portal/attack_hand(var/mob/user as mob)
	if(..())
		return

	if(stat & (NOPOWER|BROKEN))
		return

	if(server && !istype(user, /mob/living/silicon))
		return

	var/dat = "<HTML><BODY><TT><B>Portal Controls</B>"
	user.machine = src
	dat += "<HR><A href = '?src=\ref[src];xteleport=1'>[destx]</A>|"
	dat += "<A href = '?src=\ref[src];yteleport=1'>[desty]</A><BR>"
	//dat += "<A href = '?src=\ref[src];zteleport=1'>[destz]</A><BR>"
	dat += "<A href = '?src=\ref[src];open=[!isopen()]'>[isopen() ? "Close" : "Open"] Spacial Rend</A><BR><HR>"
	//for(var/datum/teledest/D in destinations)
		//dat += "[D.name] - [D.x]|[D.y]|[D.z]<BR>"
	for(var/datum/teledest/D in destinations)
		dat += "<A href = '?src=\ref[src];dest=\ref[D]'>[D.name] - [D.x]|[D.y]</A><BR>"
	if(isopen())
		dat += "<HR><A href = '?src=\ref[src];teleport=1'>Teleportation Sequence</A> "
	else
		dat += "<HR>Teleportation Sequence "
	dat += "<A href = '?src=\ref[src];teleportmode=[!teleportmode]'>([teleportmode ? "Send" : "Receive"])</A><BR>"
	var/d2
	if (timing)
		d2 = text("<A href='?src=\ref[];time=0'>Stop Time Teleport</A>", src)
	else
		d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Teleport</A>", src)
	var/second = time % 60
	var/minute = (time - second) / 60
	dat += text("<HR>\nTimer System: []\nTime Left: [][] <A href='?src=\ref[];tp=-10'>-</A> <A href='?src=\ref[];tp=-5'>-</A> <A href='?src=\ref[];tp=5'>+</A> <A href='?src=\ref[];tp=10'>+</A>", d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=computer'>Close</A></TT></BODY></HTML>", user)
	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/portal/process()
	..()

	if (timing)
		if (time > 0)
			time = round(time) - 1
		else
			do_portal()
			time = 0
			timing = 0
		updateDialog()
	return


/obj/machinery/computer/portal/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["time"])
			timing = text2num(href_list["time"])
		if (href_list["tp"])
			var/tp = text2num(href_list["tp"])
			time += tp
			time = min(max(round(time), 0), 3600)
		if (href_list["xteleport"])
			destx = text2num(input(usr,"X-Coordinate:","Enter destination X-Coordinate for Teleportation",""))
			if(!destx)
				destx = 0
		if (href_list["yteleport"])
			desty = text2num(input(usr,"Y-Coordinate:","Enter destination Y-Coordinate for Teleportation",""))
			if(!desty)
				desty = 0
		if (href_list["zteleport"])
			destz = text2num(input(usr,"Z-Coordinate:","Enter destination Z-Coordinate for Teleportation",""))
			if(!destz)
				destz = 0
		if (href_list["open"])
			open_portal(text2num(href_list["open"]))
		if (href_list["teleportmode"])
			teleportmode = text2num(href_list["teleportmode"])
		if (href_list["teleport"])
			do_portal()
		if(href_list["dest"])
			use_power(5)
			var/datum/teledest/T = locate(href_list["dest"])
			if(T)
				destx = T.x
				desty = T.y
				destz = T.z
		add_fingerprint(usr)
		updateUsrDialog()
	return

/obj/machinery/computer/portal/proc/open_portal(var/on)
	if(!on)
		if(portalin)
			del(portalin)
			portalin = null
		if(portalout)
			del(portalout)
			portalout = null
	else
		for(var/obj/machinery/portalgen/P)
			if(P.id == src.id)
				portalin = new(P.loc)
				portalout = new(src.loc)

				portalin.telelink = portalout
				portalout.telelink = portalin
				P.telelink = portalin

				var/dx = destx * teleporter_constA + teleporter_constB
				var/dy = desty * teleporter_constC + teleporter_constD

				dx %= world.maxx
				dy %= world.maxy

				var/dz = destz
				dz = min(dz % 10,8)

				for(var/atom/movable/A in range(1,P))
					if(istype(A,/obj/structure/tachyum))
						dz = 5

				if(dz == 0)
					dz = 8
				if(dz == 2) //centcomm
					dz = 1
				if(dz == 5) //void
					if(prob(100))
						var/obj/effect/mapmarker/portalspawn/S = pick(bluespace_destinations)
						if(S)
							portalin.make_skull()
							portalout.make_skull()
							portalout.loc = S.loc
							break
						else
							dz = 8
					else
						dz = 8

				portalout.loc = locate(dx,dy,dz)

				break

/obj/machinery/computer/portal/proc/do_portal()
	if(!portalin && !portalout)
		return

	if(teleportmode)
		portalin.portal_in()
	else
		portalout.portal_in()

/datum/teledest
	var/name
	var/x
	var/y
	var/z

/obj/effect/teleportal
	name = "portal"
	desc = "Looks unstable."
	icon = '96x96.dmi'
	icon_state = "open2"
	density = 0
	unacidable = 1//Can't destroy energy portals.
	var/failchance = 5
	var/obj/effect/teleportal/telelink
	var/unstable = 0
	anchored = 1.0
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -32

	New()
		for( var/obj/effect/teleportal/L in loc )
			if(L != src)
				del(L)

	Del()
		del(telelink)
		..()

	proc/portal_in()
		if(!telelink)
			return

		for(var/atom/movable/A in range(1,src))
			if(!A.anchored && !istype(A,/obj/structure/tachyum))
				telelink.portal_out(A,A.x - src.x,A.y - src.y)

		return

	proc/portal_out(var/atom/movable/AM,X,Y)
		if(!AM)
			return

		AM.loc = src.loc
		AM.x += X
		AM.y += Y

		portal_effect(AM)

	proc/make_skull()
		icon_state = "backframe"
		var/obj/effect/overlay = new/obj
		overlay.icon = '96x96.dmi'
		overlay.layer = 5.1
		overlay.icon_state = "skullspace"
		overlays += overlay


	proc/portal_effect(var/atom/movable/AM)
		return

/obj/machinery/portalgen
	name = "Spatial Rending Generator"
	desc = "A device which produces a portal when set up."
	icon = 'singularity.dmi'
	icon_state = "PortalGen"
	anchored = 1
	density = 0
	use_power = 0
	var/obj/effect/teleportal/telelink = null
	var/id = null
	mouse_opacity = 0

	Del()
		if(telelink)
			del(telelink)

		..()

	process()
		for( var/obj/effect/teleportal/L in loc )
			telelink = L

			for(var/obj/machinery/computer/portal/P)
				if(P.id == src.id)
					P.portalin = telelink
					P.portalout = telelink.telelink
			break


		return

/obj/machinery/portal_beacon

	icon = 'objects.dmi'
	icon_state = "floor_beaconf"
	name = "Bluespace Gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	level = 1		// underfloor
	layer = 2.5
	anchored = 1
	use_power = 1
	idle_power_usage = 0
	var/telename

	// update the invisibility and icon
	hide(var/intact)
		invisibility = intact ? 101 : 0
		updateicon()

	// update the icon_state
	proc/updateicon()
		var/state="floor_beacon"

		if(invisibility)
			icon_state = "[state]f"

		else
			icon_state = "[state]"

/obj/machinery/portal_control
	name = "remote portal-control"
	icon = 'mining_machines.dmi'
	icon_state = "console"
	desc = "A remote control-switch for a portal."
	var/id = null

	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/portal_control/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portal_control/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portal_control/attackby(obj/item/weapon/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/portal_control/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return

	var/dat
	var/found

	dat += text("<b>Portal control console</b><HR><br><br>")
	for(var/obj/machinery/computer/portal/P)
		if(P.id == src.id)
			for(var/datum/teledest/D in P.destinations)
				dat += "<A href = '?src=\ref[src];dest=\ref[D]'>[D.name] - [D.x]|[D.y]</A><BR>"

			if(P.isopen())
				dat += "<HR><A href = '?src=\ref[src];teleport=1'>Teleportation Sequence</A> "
			else
				dat += "<HR>Teleportation Sequence "
			dat += "<A href = '?src=\ref[src];teleportmode=[!P.teleportmode]'>([P.teleportmode ? "Send" : "Receive"])</A><BR>"
			found = 1
			break

	if(!found)
		dat += "PORTAL CONTROL COMPUTER NOT FOUND"

	user << browse("[dat]", "window=console_teleport")





/obj/machinery/portal_control/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	for(var/obj/machinery/computer/portal/P)
		if(P.id == src.id)
			if(href_list["teleport"])
				use_power(5)
				P.do_portal()
			if(href_list["dest"])
				use_power(5)
				var/datum/teledest/T = locate(href_list["dest"])
				if(T)
					P.open_portal(0)
					P.destx = T.x
					P.desty = T.y
					P.destz = T.z
					P.open_portal(1)
			if (href_list["teleportmode"])
				P.teleportmode = text2num(href_list["teleportmode"])



	src.updateUsrDialog()
	return




