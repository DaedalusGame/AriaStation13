var/list/researchprograms = list()
var/list/workingprograms = list()
var/list/unlockedprograms = list()

var/list/researchblacklist = list(/datum/researchprogram,/datum/researchprogram/upgrade,/datum/researchprogram/upgrade/nerf)

/obj/machinery/algorithm_server
	icon = 'research.dmi'
	icon_state = "algo0"
	name = "Algorithm Server"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100

	var/workingspeed = 1

	var/obj/item/weapon/blueprintdisk/recipedisk
	var/list/possiblerecipes = list()

	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/list/wires = list()
	var/list/wirecolors = list()
	var/hack_wire
	var/disable_wire
	var/shock_wire
	var/opened = 0

	var/screen = 0

	New()
		..()

		wires["Red"] = 0
		wirecolors["Red"] = "#AA0000"
		wires["Blue"] = 0
		wirecolors["Blue"] = "#0000AA"
		wires["Green"] = 0
		wirecolors["Green"] = "#00AA00"
		wires["Yellow"] = 0
		wirecolors["Yellow"] = "#AAAA00"
		wires["Black"] = 0
		wirecolors["Black"] = "#000000"
		wires["White"] = 0
		wirecolors["White"] = "#AAAAAA"
		var/list/w = list("Red","Blue","Green","Yellow","Black","White")
		src.hack_wire = pick(w)
		w -= src.hack_wire
		src.shock_wire = pick(w)
		w -= src.shock_wire
		src.disable_wire = pick(w)
		w -= src.disable_wire

		if(!researchprograms.len)
			for(var/recipe in typesof(/datum/researchprogram) - researchblacklist)
				var/datum/researchprogram/newprogram = new recipe(src)
				researchprograms += newprogram

		for(var/datum/researchprogram/recipe in researchprograms)
			if(recipe.researchtime <= 0)
				recipe.unlock(src)
				if(recipe.unlocked)
					unlockedprograms += recipe

	proc
		wires_win(mob/user as mob)
			var/dat as text
			dat += "Server Wires:<BR>"
			for(var/wire in src.wires)
				var/iscut = src.wires[wire]
				var/wirecolor = src.wirecolors[wire]
				var/icon/cablecolor = icon('cables.dmi',"cable[iscut]",2,1)
				cablecolor.Blend(wirecolor)
				cablecolor.Blend(icon('cables.dmi',"cable[iscut]o",2,1),ICON_OVERLAY)

				var/imagename = "cable[iscut][copytext(wirecolor,2)].png"
				user << browse_rsc(cablecolor, imagename)
				user << browse_rsc('pulse.png', "pulse.png")
				//user << imagename

				dat += text("[wire] Wire: <span style='margin-left:5em'><A href='?src=\ref[src];wire=[wire];act=wire'><IMG SRC='[imagename]'/></A> <A href='?src=\ref[src];wire=[wire];act=pulse'><IMG SRC='pulse.png'/></A></span><BR>")

			dat += "<BR>"
			dat += text("The red light is [src.disabled ? "off" : "on"].<BR>")
			dat += text("The green light is [src.shocked ? "off" : "on"].<BR>")
			dat += text("The blue light is [src.hacked ? "off" : "on"].<BR>")
			return "<HTML><HEAD><TITLE>Algorithm Server Hacking</TITLE></HEAD><BODY>[dat]</BODY></HTML>"

		regular_win(mob/user as mob)
			var/dat as text
			dat = text("<HR>")
			dat += "<A href='?src=\ref[src];menu=0.0'>Main Menu</A>"
			//dat += "<A href='?src=\ref[src];menu=1.0'>Research Storage</A><HR>"

			switch(screen)
				if(0.0)
					dat += "<BR>"
					for(var/datum/researchprogram/program in researchprograms)
						var/eta = 100

						if(program.totalresearchtime != 0)
							eta *= program.researchtime / program.totalresearchtime

						dat += "[program.name] "
						if(program in workingprograms)
							dat += "([100-eta]%) "
							dat += "\[<A href='?src=\ref[src];stop=\ref[program]'>Stop</A>]"
						else if(program in unlockedprograms)
							dat += "(Completed) "
							if(program.switching)
								dat += "\[Working...]"
							else if(program.enabled == -1)
								dat += ""
							else if(program.enabled)
								dat += "\[<A href='?src=\ref[src];disable=\ref[program]'>Disable</A>]"
							else
								dat += "\[<A href='?src=\ref[src];enable=\ref[program]'>Enable</A>]"
							dat += "<BR>"
							dat += "<SMALL>[program.desc]</SMALL><BR>"
						else
							dat += "([100-eta]%) "
							dat += "\[<A href='?src=\ref[src];start=\ref[program]'>Start</A>]"

						dat += tabulacore.getprogressbar(eta)
						dat += "<BR>"

			//user << browse_rsc('base.css',"base.css")

			return "<HTML><HEAD><TITLE>Algorithm Server Control Panel</TITLE></HEAD><BODY><TT>[dat]</TT></BODY></HTML>"

		shock(mob/user, prb)
			if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
				return 0
			if(!prob(prb))
				return 0
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()
			if (electrocute_mob(user, get_area(src), src, 0.7))
				return 1
			else
				return 0

		interact(mob/user as mob)
			if(..())
				return
			if (src.shocked)
				src.shock(user,50)
			else
				var/ui = ""

				if (src.opened)
					ui = wires_win(user)
				else
					ui = regular_win(user)

				if (src.disabled)
					user << "\red You press the button, but nothing happens."
					return

				user << browse(ui, "window=research_regular")
				onclose(user, "research_regular")
			return

	Topic(href, href_list)
		if(..())
			return
		usr.machine = src
		src.add_fingerprint(usr)

		if(href_list["menu"]) //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
			var/temp_screen = text2num(href_list["menu"])
			if(src.allowed(usr) || emagged) //Unless you are making something, you need access.
				screen = temp_screen
			else
				usr << "Unauthorized Access."
		else if(href_list["start"])
			var/datum/researchprogram/A = locate(href_list["start"])
			if(A && !(A in workingprograms) && !(A in unlockedprograms))
				workingprograms += A
		else if(href_list["stop"])
			var/datum/researchprogram/A = locate(href_list["stop"])
			if(A && A in workingprograms)
				workingprograms -= A
		else if(href_list["enable"])
			var/datum/researchprogram/A = locate(href_list["enable"])
			if(A && A in unlockedprograms)
				A.enable()
		else if(href_list["disable"])
			var/datum/researchprogram/A = locate(href_list["disable"])
			if(A && A in unlockedprograms)
				A.disable()
		else if(opened)
			if(href_list["act"])
				var/temp_wire = href_list["wire"]
				if(href_list["act"] == "pulse")
					if (!istype(usr.equipped(), /obj/item/device/multitool))
						usr << "You need a multitool!"
					else
						if(src.wires[temp_wire])
							usr << "You can't pulse a cut wire."
						else
							if(src.hack_wire == temp_wire)
								src.hacked = !src.hacked
								//src.unlockall()
								spawn(100) src.hacked = !src.hacked
							if(src.disable_wire == temp_wire)
								src.disabled = !src.disabled
								src.shock(usr,50)
								spawn(100) src.disabled = !src.disabled
							if(src.shock_wire == temp_wire)
								src.shocked = !src.shocked
								src.shock(usr,50)
								spawn(100) src.shocked = !src.shocked
				if(href_list["act"] == "wire")
					if (!istype(usr.equipped(), /obj/item/weapon/wirecutters))
						usr << "You need wirecutters!"
					else
						wires[temp_wire] = !wires[temp_wire]
						if(src.hack_wire == temp_wire)
							src.hacked = !src.hacked
						if(src.disable_wire == temp_wire)
							src.disabled = !src.disabled
							src.shock(usr,50)
						if(src.shock_wire == temp_wire)
							src.shocked = !src.shocked
							src.shock(usr,50)
		src.updateUsrDialog()
		return

	process()
		if(stat)
			return

		spawn(0)
			doresearch()

		if(!nterm)
			for (var/obj/machinery/power/netterm/term in loc)
				netconnect(term)
				break
		else
			if(nterm.netid == "00000000")
				nterm.requestid()

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		user.machine = src
		interact(user)

	proc/doresearch()
		for(var/datum/researchprogram/recipe in workingprograms)
			recipe.researchtime -= (workingspeed / workingprograms.len) * getupgrade("research_speed")

			if(recipe.researchtime <= 0 && !(recipe in unlockedprograms))
				recipe.researchtime = 0
				recipe.unlock(src)

				if(recipe.unlocked)
					workingprograms -= recipe
					unlockedprograms += recipe

		src.updateUsrDialog()


/obj/machinery/address_server
	icon = 'research.dmi'
	icon_state = "server"
	name = "Address Server"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100
	var/currentaddress = 1

	process()
		if(stat & (BROKEN))
			return
		if(!nterm)
			for (var/obj/machinery/power/netterm/term in loc)
				netconnect(term)
				break
		else
			nterm.netid = "cfcd2084"

/obj/machinery/server_terminal
	icon = 'research.dmi'
	icon_state = "term1"
	name = "Terminal"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100

	process()
		if(!nterm)
			for (var/obj/machinery/power/netterm/term in loc)
				netconnect(term)
				break
		else
			if(nterm.netid == "00000000")
				nterm.requestid()

