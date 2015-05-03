/obj/machinery/chemfab
	name = "Chemical Fabricator"
	icon = 'reactor.dmi'
	icon_state = "reactor1"
	density = 1
	anchored = 1
	use_power = 1
	flags = OPENCONTAINER | NOREACT

	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/list/wires = list()
	var/hack_wire
	var/disable_wire
	var/shock_wire
	var/opened = 0
	var/volume = 10000

	var/basematter = "unimatter"
	var/list/targetreagents = list("hydrogen" = 100,"lithium" = 100,"carbon" = 100,"nitrogen" = 100,"oxygen" = 100,"fluorine" = 100,"sodium" = 100,"aluminum" = 100,"silicon" = 100,"phosphorus" = 100,"sulfur" = 100,"chlorine" = 100,"potassium" = 100,"copper" = 100,"mercury" = 100,"tungsten" = 100,"radium" = 100,"water" = 100,"ethanol" = 100,"sugar" = 100,"acid" = 100,"milk" = 100)
	var/list/amplifiers = list("iron","plasma","uranium")

	var/fabricationspeed = 10

	var/screen = 0
	var/id = ""

	New()
		..()

		wires["Red"] = 0
		wires["Blue"] = 0
		wires["Green"] = 0
		wires["Yellow"] = 0
		wires["Black"] = 0
		wires["White"] = 0
		var/list/w = list("Red","Blue","Green","Yellow","Black","White")
		src.hack_wire = pick(w)
		w -= src.hack_wire
		src.shock_wire = pick(w)
		w -= src.shock_wire
		src.disable_wire = pick(w)
		w -= src.disable_wire

		var/datum/reagents/R = new/datum/reagents(volume)		//Holder for the reagents used as materials.
		reagents = R
		R.my_atom = src


	proc
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

		insert(var/obj/O,var/mob/user)
			if (istype(O,/obj/item/weapon/liquidcartridge))
				O.reagents.trans_to(src,O.reagents.total_volume)
				del(O)
				user << "You insert a liquid cartridge."

		fabricate()
			if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
				return 0

			var/obj/machinery/liquidport/P = locate(/obj/machinery/liquidport) in loc
			if(!P) return

			var/datum/reagents/R = P.get_reagents()
			if(!R) return

			var/amp = 0
			var/base = 0

			var/totalbaseremoved = 0
			var/totalampremoved = 0

			for(var/datum/reagent/chem in reagents.reagent_list)
				if(chem.id == basematter)
					base += chem.volume
				else if(chem.id in amplifiers)
					amp += chem.volume

			for(var/target in targetreagents)
				var/amt = R.get_reagent_amount(target) + reagents.get_reagent_amount(target)
				var/targetamt = targetreagents[target]
				var/fabamt = targetamt - amt

				//world << "making [target]; required:[targetamt], in storage:[amt]"

				if(!fabamt) continue

				var/removebase = min(base,fabamt)
				var/removeamp = min(amp,removebase * (2/3))

				removebase -= removeamp
				fabamt = max(0,min(fabamt,removebase + removeamp))

				R.add_reagent(target, fabamt)

				amp -= removeamp
				base -= removebase

				totalampremoved += removeamp
				totalbaseremoved += removebase

			if(totalbaseremoved) reagents.remove_reagent(basematter,totalbaseremoved)
			if(totalampremoved) removeamplifier(totalampremoved)

		removeamplifier(var/amt)
			for(var/datum/reagent/R in reagents.reagent_list)
				if(R.id in amplifiers)
					var/amtfound = reagents.get_reagent_amount(R.id)
					amt -= min(amtfound,amt)
					reagents.remove_reagent(R,min(amtfound,amt))

		wires_win(mob/user as mob)
			var/dat as text
			dat += "Chemical Fabricator Wires:<BR>"
			for(var/wire in src.wires)
				dat += text("[wire] Wire: <A href='?src=\ref[src];wire=[wire];act=wire'>[src.wires[wire] ? "Mend" : "Cut"]</A> <A href='?src=\ref[src];wire=[wire];act=pulse'>Pulse</A><BR>")

			dat += text("The red light is [src.disabled ? "off" : "on"].<BR>")
			dat += text("The green light is [src.shocked ? "off" : "on"].<BR>")
			dat += text("The blue light is [src.hacked ? "off" : "on"].<BR>")
			user << browse("<HTML><HEAD><TITLE>Chemical Fabricator Hacking</TITLE></HEAD><BODY>[dat]</BODY></HTML>","window=quantumfab_hack")
			onclose(user, "quantumfab_hack")

		regular_win(mob/user as mob)
			var/dat as text
			dat = text("<HR>")
			dat += "Material Creation Settings<BR><HR>"

			for(var/target in targetreagents)
				var/datum/reagent/R = chemical_reagents_list[target]

				if(R)
					dat += "[R.name]: <A href='?src=\ref[src];remove10=[target]'>-10</A> <A href='?src=\ref[src];remove1=[target]'>-1</A> [targetreagents[target]] <A href='?src=\ref[src];add1=[target]'>+1</A> <A href='?src=\ref[src];add10=[target]'>+10</A><BR>"

			dat += "<BR><HR>"
			dat += "Material Storage<BR><HR>"

			var/waste = 0
			var/amp = 0
			var/base = 0

			for(var/datum/reagent/R in reagents.reagent_list)
				if(R.id == basematter)
					base += R.volume
				else if(R.id in amplifiers)
					amp += R.volume
				else
					waste += R.volume

			dat += "Base Matter: [base] units<BR>"
			dat += "Amplifier: [amp] units<BR>"
			dat += "Waste Material: [waste] units <A href='?src=\ref[src];clearwaste=1'>\[Clear\]</A><BR>"
			dat += "<BR><HR>"

			user << browse("<HTML><HEAD><TITLE>Chemical Fabricator Control Panel</TITLE></HEAD><BODY><TT>[dat]</TT></BODY></HTML>", "window=disassembler_regular")
			onclose(user, "disassembler_regular")

		interact(mob/user as mob)
			if(..())
				return
			if (src.shocked)
				src.shock(user,50)
			if (src.opened)
				wires_win(user,50)
				return
			if (src.disabled)
				user << "\red You press the button, but nothing happens."
				return
			regular_win(user)
			return

	update_icon()
		if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
			icon_state = "reactor0"
		else
			icon_state = "reactor1"

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if (shocked)
			shock(user,50)
		else if (O.is_open_container())
			return 1
		else
			insert(O,user)

	process()
		if(stat)
			use_power = 0
			return

		reagents.add_reagent(basematter, fabricationspeed)

		fabricate()

		var/obj/machinery/liquidport/P = locate(/obj/machinery/liquidport) in loc
		if(P)
			P.valve = 1
			var/datum/reagents/R = P.get_reagents()
			if(R)
				for(var/datum/reagent/chem in reagents)
					if(chem.id == basematter) continue
					if(chem.id in amplifiers) continue

					world << "transferring [chem.id] to storage"

					reagents.trans_id_to(R.my_atom,chem.id,100)

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

	Topic(href, href_list)
		if(..())
			return
		usr.machine = src
		src.add_fingerprint(usr)

		if(href_list["add1"])
			var/target = href_list["add1"]
			targetreagents[target] += 1
		if(href_list["add10"])
			var/target = href_list["add10"]
			targetreagents[target] += 10
		if(href_list["remove1"])
			var/target = href_list["remove1"]
			targetreagents[target] -= 1
		if(href_list["remove10"])
			var/target = href_list["remove10"]
			targetreagents[target] -= 10
		if(href_list["clearjunk"])
			for(var/datum/reagent/chem in reagents)
				if(chem.id == basematter) continue
				if(chem.id in amplifiers) continue

				reagents.remove_reagent(chem.id,reagents.get_reagent_amount(chem.id))
		src.updateUsrDialog()
		return