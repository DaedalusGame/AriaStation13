/obj/effect/mapmarker/spacedestination
	name = "Space Travel Destination"
	//icon = 'singularity.dmi'
	//icon_state = "singularity_s1"

/obj/machinery/plate
	name = "pressureplate"
	desc = "It's useful for activating mechanisms on pressure."
	icon = 'stationobjs.dmi'
	icon_state = "holopad0"
	var/id = null
	var/sendmessage = null
	var/active = 0
	var/delay = 0
	var/senddata = ""
	var/alarmname = "Station Alarm System"
	var/alarmtext = "Access detected in prohibited area!"
	layer = 2.96
	anchored = 1.0
	use_power = 0

/obj/machinery/plate/HasEntered(AM as mob|obj)
	if(!id || !sendmessage)
		return

	if(active)
		return

	active = 1

	sleep(delay)

	switch(sendmessage)
		if("massdriver")
			drivercontrol()
		if("instdriver")
			instantdrivercontrol()
		if("massdrivertag")
			massdrivertag(AM)
		if("dooropen")
			dooropen()
		//if("doorclose")
		//	doorclose()
		if("doortoggle")
			doortoggle()
		if("alarm")
			soundalarm()
	active = 0
	..()

/obj/machinery/plate/proc/instantdrivercontrol()
	for(var/obj/machinery/mass_driver/M in world)
		if(M.id == src.id)
			M.drive()

	sleep(50)

/obj/machinery/plate/proc/massdrivertag(var/atom/movable/AM)
	if(!AM)
		return

	AM.spacetag = senddata

/obj/machinery/plate/proc/doortoggle()
	for(var/obj/machinery/door/poddoor/M in world)
		if (M.id == src.id)
			spawn( 0 )
				if(M.density)
					M.open()
				else
					M.close()
				return

/obj/machinery/plate/proc/dooropen()
	for(var/obj/machinery/door/poddoor/M in world)
		if (M.id == src.id)
			spawn( 0 )
				M.open()
				return

	sleep(senddata)

	for(var/obj/machinery/door/poddoor/M in world)
		if (M.id == src.id)
			spawn( 0 )
				M.close()
				return

/obj/machinery/plate/proc/drivercontrol()
	for(var/obj/machinery/door/poddoor/M in world)
		if (M.id == src.id)
			spawn( 0 )
				M.open()
				return

	sleep(20)

	for(var/obj/machinery/mass_driver/M in world)
		if(M.id == src.id)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in world)
		if (M.id == src.id)
			spawn( 0 )
				M.close()
				return

/obj/machinery/plate/proc/soundalarm()
	var/obj/item/device/radio/headset/a = new /obj/item/device/radio/headset(null)
	a.autosay("states, \""+alarmtext+"\"", alarmname)
	del(a)

	sleep(senddata)