// Powersink - used to drain station power

/obj/item/device/packetsniffer
	desc = "A packetsniffer for sniffing data from a network terminal."
	name = "power sink"
	icon_state = "powersink0"
	item_state = "electronic"
	w_class = 4.0
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	m_amt = 750
	w_amt = 750
	origin_tech = "programming=4"
	var/mode = 0		// 0 = off, 1=clamped (off), 2=operating

	var/obj/machinery/power/netterm/attached		// the attached cable
	var/obj/item/weapon/memory/cmemory = null

	New()
		var/obj/item/weapon/memory/harddrive/computer/hd = new(src)
		cmemory = hd
		cmemory.machine = src

		netconnect = new(src)
		netconnect.nettype = "SNIFFER"
		netconnect.device = src


	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/weapon/screwdriver))
			if(mode == 0)
				var/turf/T = loc
				if(isturf(T))
					attached = locate() in T
					if(!attached)
						user << "No network terminal here to attach to."
						return
					else
						anchored = 1
						mode = 1
						user << "You attach the device to the network terminal."
						for(var/mob/M in viewers(user))
							if(M == user) continue
							M << "[user] attaches the power sink to the network terminal."
						return
				else
					user << "Device must be placed over a network terminal to attach to it."
					return
			else
				if (mode == 2)
					processing_objects.Remove(src) // Now the power sink actually stops draining the station's power if you unhook it. --NeoFite
				anchored = 0
				mode = 0
				user << "You detach	the device from the network terminal."
				for(var/mob/M in viewers(user))
					if(M == user) continue
					M << "[user] detaches the power sink from the network terminal."
				ul_SetLuminosity(0)
				icon_state = "powersink0"

				return
		else
			..()



	attack_paw()
		return

	attack_ai()
		return

	attack_hand(var/mob/user)
		switch(mode)
			if(0)
				..()

			if(1)
				user << "You activate the device!"
				for(var/mob/M in viewers(user))
					if(M == user) continue
					M << "[user] activates the packetsniffer!"
				netaccess.connect(locate(/obj/machinery/power/netterm) in src.loc)
				mode = 2
				icon_state = "powersink1"
				processing_objects.Add(src)

			if(2)  //This switch option wasn't originally included. It exists now. --NeoFite
				user << "You deactivate the device!"
				for(var/mob/M in viewers(user))
					if(M == user) continue
					M << "[user] deactivates the packetsniffer!"
				mode = 1
				ul_SetLuminosity(0)
				icon_state = "powersink0"
				processing_objects.Remove(src)

	process()
		if(attached)
			//interface.connect(attached)
			if(!luminosity)
				ul_SetLuminosity(12,3,0)

	proc/receivepacket(datum/netmessage/message)
		if (mode == 2)
			lines += message