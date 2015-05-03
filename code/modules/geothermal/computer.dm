/obj/machinery/computer/geothermal
	name = "Geothermal Engine Control Computer"
	desc = "Used to access informations and systems related to the geothermal engine."
	icon_state = "engine"
	//circuit = "/obj/item/weapon/circuitboard/stationalert"
	var/id = ""
	var/datum/magmaengine/engine
	var/autocooling

//the station alerts computer
/obj/machinery/computer/geothermal/attack_ai(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/geothermal/attack_hand(mob/user)
	if(..())
		return
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/geothermal/proc/interact(mob/user)
	usr.machine = src
	var/dat = "<HEAD><TITLE>Engine Status</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[user];mach_close=geoengine'>Close</A><hr><br>"
	if(engine)
		var/engineheat = engine.heat / engine.maxheat
		var/integrity = engine.maxheat / (engine.maxheat + engine.heatdamage)

		dat += "Engine Containment<br>"
		dat += "- Heatlevel: [engineheat*100]%<br>"
		dat += "- Integrity: [integrity*100]%<br>"

		dat += "<br>";
		dat += "- Automatic Cooling Level: <A HREF='?src=\ref[src];autocool=[-0.10]'>-10%</A> <A HREF='?src=\ref[src];autocool=[-0.01]'>-1%</A> >[autocooling] <A HREF='?src=\ref[src];autocool=[0.01]'>+1%</A> <A HREF='?src=\ref[src];autocool=[0.10]'>+10%</A>";
	else
		dat += "ERROR: No connected engine found."
	user << browse(dat, "window=geoengine")
	onclose(user, "geoengine")

/obj/machinery/computer/geothermal/Topic(href, href_list)
	if(..())
		return
	if (href_list["autocool"])
		autocooling += text2num(href_list["autocool"])
		autocooling = max(0,min(1,autocooling))
	src.updateUsrDialog()

/obj/machinery/computer/geothermal/process()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "engine0"
		return

	engine = find_engine(id)

	if(engine)
		icon_state = "engine1"
	else
		icon_state = "engine2"

	for(var/obj/machinery/atmospherics/unary/containment_cooler/C in world)
		if (C.id == id)
			C.coolinglevel = autocooling
	..()