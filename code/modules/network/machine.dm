/obj/machinery/power/netterm/New()

	..()

	var/turf/T = src.loc

	if(level==1) hide(T.intact)


/obj/machinery/power/netterm
	name = "network terminal"
	icon_state = "nterm"
	desc = "A connection port for network equipment."
	level = 2
	layer = TURF_LAYER
	anchored = 1
	directwired = 1		// must have a cable on same turf connecting to terminal
	layer = 2.6 // a bit above wires

	var/netid = "00000000"
	var/nettype = "UNKNOWN"

	var/obj/machinery/master = null

	//process()
		//if(netid == "00000000")
		//	requestid()

	proc/requestid()
		if(!powernet)
			return

		//world << powernet

		for (var/obj/machinery/power/netterm/term in powernet.nodes)
			if(istype(term.master,/obj/machinery/address_server))
				var/obj/machinery/address_server/dhcp = term.master
				netid = copytext(md5(num2text(dhcp.currentaddress,12)),1,9)
				dhcp.currentaddress += 1

	proc/ishost(id)
		if(id == "FFFFFFFF")
			return 1
		else if(netid == "FFFFFFFF")
			return 1
		else if(id == netid)
			return 1
		else
			return 0

	proc/getallhosts()
		var/list/rlist = list()

		if(powernet && netid != "00000000")
			for (var/obj/machinery/power/netterm/term in powernet.nodes)
				if(term != src)
					rlist += term

		return rlist

	proc/gethost(hostid)
		if(!powernet)
			return

		for (var/obj/machinery/power/netterm/term in powernet.nodes)
			if(term.ishost(hostid))
				return term

	proc/send(datum/netpacket/p)
		if(!powernet)
			return

		p.srchost = netid

		if(netid != "00000000")
			for (var/obj/machinery/power/netterm/term in powernet.nodes)
				if(term.ishost(p.desthost))
					term.receive(p)

	proc/receive(datum/netpacket/p)
		master.netreceive()

/obj/machinery/power/netterm/hide(var/i)

	if(i)
		invisibility = 101
		icon_state = "nterm-f"
	else
		invisibility = 0
		icon_state = "nterm"


/obj/machinery/commarray
	name = "communication array"
	desc = "Connects the local network to the bluespace network."
	icon_state = "commarray"
	density = 1
	anchored = 1.0
	use_power = 0
//	var/datum/networkaccess/interface = null

/obj/machinery/commarray/New()
	..()

	//interface = new()
	//interface.nettype = "DISH"

	spawn(2)
		power_change()

/obj/machinery/computer/process()
	if(stat & (BROKEN))
		return
	if(!nterm)
		for (var/obj/machinery/power/netterm/term in loc)
			netconnect(term)
			break
	else
		if(nterm.netid == "00000000")
			nterm.requestid()

/obj/machinery
	//var/net_connected = 0
	//var/net_netid
	var/obj/machinery/power/netterm/nterm

	proc/netconnect(obj/machinery/power/netterm/term)
		nterm = term
		nterm.master = src

	proc/netsend(datum/netpacket/p)
		if(!nterm)
			return

		nterm.send(p)

	proc/netreceive(datum/packet/p)
