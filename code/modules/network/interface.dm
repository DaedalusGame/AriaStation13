#define SCREEN_CONSOLE 0
#define SCREEN_BROWSER 1
#define SCREEN_TEXTEDIT 2

datum/interface
	var/datum/file/filesystem
	var/obj/machinery/device
	var/list/programs = list()
	var/datum/file/program/currprogram = null

	var/mob/lastuser = null

	var/outconsole = ""
	var/outbrowser = ""
	var/outtype = SCREEN_CONSOLE

	proc/init(var/mob/user,var/obj/machinery/mach)
		if(!mach) return
		device = mach
		if(mach.net_memory)
			filesystem = mach.net_memory.root
		winshow(user, "consolewindow", 1)
		user.skincmds["consolewindow"] = src

	proc/read(var/data)

	proc/write(var/data)
		if(istext(data))
			switch(outtype)
				if(SCREEN_CONSOLE)
					outconsole += data
				if(SCREEN_BROWSER)
					outbrowser += data
		else if(device)
			device.write(data)

	proc/setmode(var/mode)
		outtype = mode

	proc/updateWindow(mob/user as mob)
		winset(user, "consolewindow.output", "is-visible=false")
		winset(user, "consolewindow.browse", "is-visible=false")
		winset(user, "consolewindow.textedit", "is-visible=false")

		switch(outtype)
			if(SCREEN_CONSOLE)
				winset(user, "consolewindow.output", "is-visible=true")
				user << output(null, "consolewindow.output")
				user << output(outconsole, "consolewindow.output")
			if(SCREEN_BROWSER)
				winset(user, "consolewindow.browse", "is-visible=true")
				user << output(null, "consolewindow.browse")
				user << output(outbrowser, "consolewindow.browse")
			if(SCREEN_TEXTEDIT)
				winset(user, "consolewindow.textedit", "is-visible=true")

/obj/machinery
	var/datum/interface/interface
	var/datum/networkaccess/netconnect

	proc/net_connect(var/force)
		if(!netconnect) return

		if(!netconnect.connected || force)
			netconnect.connect(locate(/obj/machinery/power/netterm) in src.loc)

	proc/net_disconnect()
		if(!netconnect) return

		if(netconnect.connected)
			netconnect.disconnect()

	proc/read(var/data)

	proc/write(var/data)

/obj/machinery/SkinCmd(mob/user as mob, var/data as text)
	if(!interface) return
	if(stat & BROKEN) return
	if(usr.stat || usr.restrained()) return
	if(!in_range(src, usr) && !istype(usr, /mob/living/silicon)) return

	usr.machine = src

	//src.shelloutput += data+"\n"
	interface.lastuser = user
	interface.read(data)

	for(var/mob/player)
		if (player.machine == src && player.client)
			interface.updateWindow(player)

	src.add_fingerprint(usr)
	return