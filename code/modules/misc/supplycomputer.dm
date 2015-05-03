/obj/fakeitem
	name = "Fake Item"
	desc = "Let's hope you don't see this"
	var/obj/skincmdtarget
	var/clickaction
	var/dblclkaction
	var/data

	Click()
		skincmdtarget.SkinCmd(usr,"[clickaction]")

	DblClick()
		skincmdtarget.SkinCmd(usr,"[dblclkaction]")

	proc/copy()
		var/obj/fakeitem/C = new()

		C.name = name
		C.desc = desc
		C.icon = icon
		C.icon_state = icon_state
		C.color = color
		C.skincmdtarget = skincmdtarget
		C.clickaction = clickaction
		C.dblclkaction = dblclkaction
		C.data = data

		return C


/obj/machinery/computer/supplycompnew
	name = "Supply shuttle console"
	icon = 'computer.dmi'
	icon_state = "supply"
	//req_access = list(ACCESS_CARGO)
	circuit = "/obj/item/weapon/circuitboard/supplycomp"
	var/list/catalogue = list()
	var/list/catalogue_items = list()
	var/list/containers = list()
	var/hacked = 0
	var/can_order_contraband = 0
	var/selected_catalogue
	var/selected_crate
	var/selected_item
	var/obj/fakeitem/current_crate
	var/obj/item/weapon/card/id/internalcard

	var/paymentid
	//var/storedmoney = 0

	New()
		..()

		internalcard = new()
		internalcard.money = rand(500,2000)

	attack_ai(var/mob/user as mob)
		return src.attack_hand(user)

	attack_paw(var/mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(stat & BROKEN)
			return
		user.machine = src

		initWindow(user)
		updateWindow(user)
		winshow(user, "supplywindow", 1)
		user.skincmds["supplycomp"] = src

	process()
		if(stat & BROKEN)
			return

		for(var/mob/player)
			if (player.machine == src && player.client)
				updateWindow(player)

	proc/generate_fakeitems()
		catalogue_items.Cut()

		for(var/datum/supplygood/good in catalogue)
			var/obj/fakeitem/FO = new()

			var/price = get_buy_price(good)

			FO.name = "[good.name] ([price]$)"
			FO.icon = good.recipe.icon
			FO.icon_state = good.recipe.icon_state
			FO.color = good.recipe.color
			FO.data = good
			FO.skincmdtarget = src
			FO.clickaction = "select"
			FO.dblclkaction = "additem"

			catalogue_items += FO

	proc/initWindow(mob/user as mob)
		if(!supplycatalogue.len)
			generate_goods()

		if(catalogue != supplycatalogue)
			catalogue = supplycatalogue
			generate_fakeitems()

		var/searchtext = winget(user,"supplywindow.inputSearchCatalog","text")

		updateCatalogue(user,searchtext)
		updateCrates(user)
		updateContent(user,searchtext)
		//winset(user,"supplywindow",catalogue)

	proc/updateCatalogue(mob/user as mob,var/searchstring)
		var/count = 0
		var/allcount = 0

		for(var/obj/fakeitem/O in catalogue_items)
			allcount++

			O.clickaction = "selectcatalogue:[allcount]"
			O.dblclkaction = "additem:[allcount]"

			if(lentext(searchstring) && !findtext(O.name,searchstring))
				continue

			count++

			if(selected_catalogue == allcount)
				winset(user,"supplywindow.gridCatalog","style='body{background-color:#0000FF;color:#FFFFFF;}'")
			else
				winset(user,"supplywindow.gridCatalog","style='body{background-color:#FFFFFF;color:#000000;}'")

			user << output(O, "supplywindow.gridCatalog:[count]")

		winset(user, "supplywindow.gridCatalog", "cells=\"[count]\"")
		//winset(user,"supplywindow",catalogue)

	proc/updateCrates(mob/user as mob)
		var/count = 0
		var/allcount = 0

		for(var/obj/fakeitem/O in containers)
			allcount++

			O.clickaction = "selectcrate:[allcount]"
			O.dblclkaction = O.clickaction

			//if(lentext(searchstring) && !findtext(O.name,searchstring))
			//	continue

			count++

			if(selected_crate == allcount)
				winset(user,"supplywindow.gridCrates","style='body{background-color:#0000FF;color:#FFFFFF;}'")
				current_crate = O
			else
				winset(user,"supplywindow.gridCrates","style='body{background-color:#FFFFFF;color:#000000;}'")

			user << output(O, "supplywindow.gridCrates:[count]")

		winset(user, "supplywindow.gridCrates", "cells=\"[count]\"")
		//winset(user,"supplywindow",catalogue)

	proc/updateContent(mob/user as mob,var/searchstring)
		var/count = 0
		var/allcount = 0

		if(current_crate)
			var/totalcost = get_buy_price(current_crate.data)

			for(var/obj/fakeitem/O in current_crate)
				allcount++

				O.clickaction = "selectitem:[allcount]"
				O.dblclkaction = O.clickaction

				if(lentext(searchstring) && !findtext(O.name,searchstring))
					continue

				count++

				totalcost += get_buy_price(O.data)

				if(selected_item == allcount)
					winset(user,"supplywindow.gridContent","style='body{background-color:#0000FF;color:#FFFFFF;}'")
				else
					winset(user,"supplywindow.gridContent","style='body{background-color:#FFFFFF;color:#000000;}'")

				user << output(O, "supplywindow.gridContent:[count]")

			current_crate.name = "[current_crate.data:name] ([totalcost]$)"

		winset(user, "supplywindow.gridContent", "cells=\"[count]\"")

	proc/updateWindow(mob/user as mob)
		var/searchtext = winget(user,"supplywindow.inputSearchCatalog","text")
		var/searchitemtext = winget(user,"supplywindow.inputSearchContent","text")

		updateCatalogue(user,searchtext)
		updateCrates(user)
		updateContent(user,searchitemtext)

		if(supply_shuttle_moving)
			winset(user,"supplywindow.buttonConfirm","is-disabled=1;text=\"Moving...\"")
		else if(supply_shuttle_at_station)
			winset(user,"supplywindow.buttonConfirm","is-disabled=0;text=\"Return Shuttle\"")
		else if(!supply_shuttle_at_station)
			winset(user,"supplywindow.buttonConfirm","is-disabled=0;text=\"Confirm Order\"")

		var/budget = internalcard ? internalcard.money : 0
		var/cost = get_total_cost()

		var/budgetcolor = rgb(0,255,0)
		if(cost - internalcard.money > 0)
			budgetcolor = rgb(255,0,0)

		winset(user,"supplywindow.labelMoney","text-color=[budgetcolor];text=\"Budget: [budget]$\"")

		return

	proc/addItem(var/obj/fakeitem/OTemp)
		if(!OTemp) return

		var/obj/fakeitem/O = OTemp.copy()

		var/datum/supplygood/good = OTemp.data

		if(istype(good.recipe,/datum/assemblerprint/storage))
			containers += O
		else
			current_crate.contents += O

	proc/removeItem(var/i)
		var/obj/fakeitem/O = current_crate[i]

		if(O)
			current_crate -= O

	proc/deleteCrate(var/i)
		var/obj/fakeitem/O = containers[i]

		if(O)
			containers -= O

	//From Station to Centcomm
	proc/return_supply()
		if(!supply_shuttle_at_station || supply_shuttle_moving) return

		if (!supply_can_move())
			usr << "\red The supply shuttle can not transport station employees, exosuits, classified nuclear codes or homing beacons."
			return

		//src.temp = "Shuttle sent.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		//src.updateUsrDialog()
		post_signal("supply")

		sell_supply_contents()

		//Remove anything or anyone that was either left behind or that bypassed supply_can_move() -Nodrak
		for(var/area/supply/station/A in world)
			for(var/obj/item/I in A.contents)
				del(I)
			for(var/mob/living/M in A.contents)
				del(M)

		send_supply_shuttle()

	//From Centcomm to Station
	proc/call_supply()
		if(supply_shuttle_at_station || supply_shuttle_moving) return

		if (!supply_can_move())
			usr << "\red The supply shuttle can not transport station employees, exosuits, classified nuclear codes or homing beacons."
			return

		post_signal("supply")
		usr << "\blue The supply shuttle has been called and will arrive in [round(((SUPPLY_MOVETIME/10)/60))] minutes."

		//src.temp = "Shuttle sent.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		//src.updateUsrDialog()

		supply_shuttle_moving = 1

		process_order()

		supply_shuttle_time = world.timeofday + SUPPLY_MOVETIME
		spawn(0)
			supply_process()

	proc/post_signal(var/command)
		var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

		if(!frequency) return

		var/datum/signal/status_signal = new
		status_signal.source = src
		status_signal.transmission_method = 1
		status_signal.data["command"] = command

		frequency.post_signal(src, status_signal)

	proc/get_total_cost()
		var/totalcost = 0

		for(var/obj/fakeitem/C in containers)
			totalcost += get_buy_price(C.data)

			for(var/obj/fakeitem/I in C.contents)
				totalcost += get_buy_price(I.data)

		return totalcost

	proc/can_afford()
		var/totalcost = get_total_cost()

		if(internalcard && internalcard.money >= totalcost)
			return 1 //For now

		return 0

	proc/reset()
		containers.Cut()
		current_crate = null

	proc/requestpayment(var/cost)
		for(var/obj/item/device/payment/P)
			if(P.id && paymentid && P.id == paymentid)
				P.targetaccount = internalcard
				P.payment_amt = cost

	SkinCmd(mob/user as mob, var/data as text)
		if(stat & BROKEN) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		usr.machine = src

		if (findtext(data,"selectcatalogue") == 1)
			var/num = text2num(copytext(data,findtext(data,":")+1))

			selected_catalogue = num
		if (findtext(data,"selectcrate") == 1)
			var/num = text2num(copytext(data,findtext(data,":")+1))

			selected_crate = num
		if (findtext(data,"selectitem") == 1)
			var/num = text2num(copytext(data,findtext(data,":")+1))

			selected_item = num
		else if (findtext(data,"additem") == 1)
			if(findtext(data,":"))
				var/num = text2num(copytext(data,findtext(data,":")+1))

				selected_catalogue = num

			addItem(catalogue_items[selected_catalogue])
		else if (findtext(data,"removeitem") == 1)
			removeItem(selected_item)
		else if (findtext(data,"deletecrate") == 1)
			deleteCrate(selected_crate)
		else if (findtext(data,"finishorder") == 1)
			var/cost = get_total_cost()

			if(supply_shuttle_at_station)
				return_supply()
			else if(can_afford())
				internalcard.money -= cost
				call_supply()
				reset()

		else if (findtext(data,"cancelorder") == 1)
			reset()
		else if (findtext(data,"pay") == 1)
			var/cost = get_total_cost()
			requestpayment(cost)
		//else if (findtext(data,"print") == 1)


		//if (findtext(data,"additem") == 1)


		for(var/mob/player)
			if (player.machine == src && player.client)
				updateWindow(player)

		src.add_fingerprint(usr)
		return



// Powersink - used to drain station power

/obj/item/device/payment
	desc = "A device for instant money transfers."
	name = "payment transfer device"
	icon_state = "payment"
	item_state = "electronic"
	w_class = 2.0
	flags = FPRINT | TABLEPASS | CONDUCT
	m_amt = 75
	w_amt = 75
	origin_tech = "powerstorage=1"
	var/payment_amt
	var/obj/item/weapon/card/id/targetaccount
	var/reset_access
	var/setpay_access
	var/id

	proc/scan(var/mob/user)
		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(H.wear_id)
				if(istype(H.wear_id, /obj/item/weapon/card/id))
					return H.wear_id
				if(istype(H.wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/P = H.wear_id
					if(istype(P.id,/obj/item/weapon/card/id))
						return P.id
		return null

	attack_ai(var/mob/user as mob)
		return src.attack_hand(user)

	attack_paw(var/mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(anchored)
			return

		//var/ucard = scan(user)

		..()

		/*if(!setpay_access || (ucard && setpay_access in ucard.access))
			var/want = input(usr,"Enter the desired amount") as num
			if(want)
				payment_amt = want
		else
			..()*/

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/weapon/screwdriver))
			var/atom/attachable = locate(/obj/structure/table) in get_turf(src)

			if(!attachable) return

			anchored = !anchored
			if(anchored)
				user << "You attach the device to \the [attachable]."

				for(var/mob/M in viewers(user))
					if(M == user) continue
					M << "[user] screws \the [src] to \the [attachable]."
			else
				user << "You detach the device from \the [attachable]."

				for(var/mob/M in viewers(user))
					if(M == user) continue
					M << "[user] unscrews \the [src] from \the [attachable]."
			return
		else if(istype(I, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/card = I

			if(targetaccount && card != targetaccount && payment_amt)
				var/pincode = input(usr,"Enter a pin-code") as num
				if(card.checkaccess(pincode,usr))
					if(card.money >= payment_amt)
						card.money -= payment_amt
						targetaccount.money += payment_amt
						payment_amt = 0
						//targetaccount = null

						src.visible_message("[src] accepts the payment!", "You hear a ping.")
						playsound(src.loc, 'ping.ogg', 50, 0)
					else
						user << "Not enough money."

			else if(!reset_access || reset_access in card.access)
				var/want = input(usr,"Enter the desired amount") as num
				if(want)
					payment_amt = want
					targetaccount = card
					user << "Set target account to your card."
			else
				user << "Access denied."

		else
			..()

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//		NEW PROCESS SUPPLY ORDER
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/computer/supplycompnew/proc/process_order()
	var/shuttleat = supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE

	var/list/markers = new/list()

	if(!containers.len) return

	for(var/turf/T in get_area_turfs(shuttleat))
		for(var/obj/effect/marker/supplymarker/D in T)
			markers += D

	for(var/obj/fakeitem/FO in containers)
		var/pickedloc = 0
		var/found = 0
		for(var/C in markers)
			if (locate(/obj/structure/closet) in get_turf(C)) continue
			found = 1
			pickedloc = get_turf(C)
		if (!found) pickedloc = get_turf(pick(markers))

		var/datum/supplygood/SP = FO.data
		var/datum/assemblerprint/R = SP.recipe

		var/atom/movable/A = R.builditem()
		A.loc = pickedloc
		//A.name = "[FO.name]"

		//supply manifest generation begin

		if(ordernum)
			ordernum++
		else
			ordernum = rand(500,5000) //pick a random number to start with

		var/obj/item/weapon/paper/manifest/slip = new /obj/item/weapon/paper/manifest (A)
		slip.info = ""
		slip.info +="<h3>[command_name()] Shipping Manifest</h3><hr><br>"
		slip.info +="Order #: [ordernum]<br>"
		slip.info +="Destination: [station_name]<br>"
		slip.info +="[containers.len] PACKAGES IN THIS SHIPMENT<br>"
		slip.info +="CONTENTS:<br><ul>"

		//spawn the stuff, finish generating the manifest while you're at it
		//if(SP.access)
		//	A:req_access = new/list()
		//	A:req_access += text2num(SP.access)
		for(var/obj/fakeitem/B in FO.contents)
			if(!B)	continue

			var/datum/supplygood/SPB = B.data
			var/datum/assemblerprint/RB = SPB.recipe

			var/atom/movable/B2 = RB.builditem()
			B2.loc = A
			slip.info += "<li>[B2.name]</li>" //add the item to the manifest

		//manifest finalisation
		slip.info += "</ul><br>"
		slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"

	return

/obj/machinery/computer/supplycompnew/proc/sell_supply_contents(var/list/content,var/recursion=0)
	if(!content)
		content = list()

		for(var/area/supply/station/A in world)
			for(var/obj/item/I in A.contents)
				content += I
			for(var/mob/living/M in A.contents)
				content += M
			for(var/obj/structure/closet/C in A.contents)
				content += C

	for(var/atom/A in content)
		sell_supply_contents(A.contents)

		var/datum/supplygood/good = find_good(A.type)

		if(good)
			src.internalcard.money += get_sell_price(good)
			del(A)

	return