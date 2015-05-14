var/list/cyberusers = list()

datum/cyberuser
	//var/key
	//var/mob/currentmob
	var/client/currentclient
	var/obj/effect/cyberspace/mapholder/currentmap
	var/obj/effect/cyberspace/program/selected
	var/obj/effect/cyberspace/screen/action/selected_action

	var/list/allprograms = list()

	var/width
	var/height

	var/message_history_full = ""
	var/message_history_new = ""

	var/list/cyberlist = list()
	var/list/hud = list()
	var/obj/effect/cyberspace/screen/topmessage
	var/obj/effect/cyberspace/screen/topmessagebox
	var/obj/effect/cyberspace/screen/bottommessage
	var/obj/effect/cyberspace/screen/bottommessagebox
	var/obj/effect/cyberspace/screen/blocker
	var/obj/effect/cyberspace/screen/action/action1
	var/obj/effect/cyberspace/screen/action/action2
	var/obj/effect/cyberspace/screen/action/action3
	var/obj/effect/cyberspace/screen/action/action4
	var/obj/effect/cyberspace/screen/action/action5

	New(key)
		//src.key = key
		cyberusers += src

		//findclient()

		topmessagebox = new()
		topmessagebox.icon_state = "window"
		hud += topmessagebox

		topmessage = new()
		hud += topmessage

		bottommessagebox = new()
		bottommessagebox.icon_state = "window"
		hud += bottommessagebox

		bottommessage = new()
		hud += bottommessage

		blocker = new()
		blocker.icon_state = "blocker"
		hud += blocker

		action1 = new()
		action1.icon_state = "slot1"
		hud += action1

		action2 = new()
		action2.icon_state = "slot1"
		hud += action2

		action3 = new()
		action3.icon_state = "slot1"
		hud += action3

		action4 = new()
		action4.icon_state = "slot1"
		hud += action4

		action5 = new()
		action5.icon_state = "slot1"
		hud += action5

		updatehud()

		spawn() update()

	Del()
		cyberusers -= src
		..()

	proc/connect(var/obj/effect/cyberspace/mapholder/cmap)
		if(currentmap)
			disconnect()

		cmap.connect(src)

	proc/disconnect()
		if(!currentmap) return

		currentmap.disconnect(src)

	proc/click_act(var/obj/effect/cyberspace/clicktarget)
		if(istype(clicktarget,/obj/effect/cyberspace/screen/action))
			var/obj/effect/cyberspace/screen/action/A = clicktarget

			if(A.actionref && selected_action != clicktarget)
				select_action(clicktarget)
			else
				select_action(null)
		else
			var/obj/effect/cyberspace/program/targetprogram = clicktarget.get_program()

			var/used = 0

			if(selected_action)
				if(selected_action.actionref && selected_action.actionref.can_use(clicktarget))
					used = selected_action.actionref.use(clicktarget)
					selected_action.actionref.after_use()
					select_action(null)

			if(!used)
				select(targetprogram)
				select_action(null)
		/*if(istype(clicktarget,/obj/effect/cyberspace/sector))
			if(selected_action)
				var/used = 0

				if(selected_action.actionref && selected_action.actionref.can_use(clicktarget))
					used = selected_action.actionref.use(clicktarget)
					selected_action.actionref.after_use()

				if(!used)
					select(null)
					select_action(null)
			else
				select(null)
				select_action(null)*/


	proc/select(var/obj/effect/cyberspace/program/PRG)
		if(PRG && PRG.owner != src) return

		selected = PRG
		updatehud()

	proc/select_action(var/obj/effect/cyberspace/screen/action/act)
		//if(selected.owner != src) return

		if(selected_action && selected_action.actionref)
			selected_action.actionref.show_targets(usr,0)

		selected_action = act

		if(selected_action && selected_action.actionref)
			selected_action.actionref.show_targets(usr,1)

		updatehud()

	/*proc/findclient()
		for(var/mob/M in world)
			if(M.key == key)
				currentmob = M

		if(currentmob)
			client = currentmob.client

		for(var/mob/M in world)
			if(M.key == key)
				client = M.client*/

	proc/update()
		while(src)
			//if(!client || !currentmob)
			//	findclient()

			if(currentmap)
				width = currentmap.width
				height = currentmap.height

			updatehud()

			/*if(client)
				if(is_jacked())
					client.currentcyberspace = src
					client.update_cyberspace()
				else
					client.currentcyberspace = null
					client.hide_cyberspace()*/

			sleep(10)

	/*proc/is_jacked()
		if(istype(currentmob,/mob/living/silicon))
			return 1
		else if(istype(currentmob,/mob/living/carbon/human))
			var/mob/living/carbon/human/M = currentmob

			if(istype(M.head,/obj/item/clothing/head/helmet/cyber))
				var/obj/item/clothing/head/helmet/cyber/CH = M.head
				return (CH.jacktarget != null)
			else
				return 0

		return 0*/

	proc/updatehud()
		topmessage.pre_screen_loc = "0,[hudheight-1]"
		topmessagebox.pre_screen_loc = "0,[hudheight-1] to [hudwidth-1],[hudheight-1]"
		bottommessage.pre_screen_loc = "0,1"
		bottommessagebox.pre_screen_loc = "0,1 to [hudwidth-1],1"
		blocker.pre_screen_loc = "5,0 to [hudwidth-1],0"
		action1.pre_screen_loc = "0,0"
		action2.pre_screen_loc = "1,0"
		action3.pre_screen_loc = "2,0"
		action4.pre_screen_loc = "3,0"
		action5.pre_screen_loc = "4,0"
		/*for(var/obj/effect/cyberspace/screen/action/A in hud)
			if(selected)
				A.icon_state = "slot1"
			else
				A.icon_state = "slot0"*/

		topmessage.maptext_width = hudwidth * 32
		bottommessage.maptext_width = hudwidth * 32

		if(selected_action)
			bottommessage.maptext = "<text align=top><FONT COLOR='#00FF00'>[selected_action.actionref.name]<BR>[selected_action.actionref.desc]</FONT></text>"
		else
			bottommessage.maptext = ""

		if(selected)
			topmessage.maptext = "<text align=top><FONT COLOR='#00FF00'>[selected.name]<BR>[selected.desc]</FONT></text>"
		else
			topmessage.maptext = "<text align=top><FONT COLOR='#00FF00'>NO PROGRAM SELECTED</FONT></text>"

		if(selected)
			action1.actionref = selected.action1
			action2.actionref = selected.action2
			action3.actionref = selected.action3
			action4.actionref = selected.action4
			action5.actionref = selected.action5

		else
			action1.actionref = null
			action2.actionref = null
			action3.actionref = null
			action4.actionref = null
			action5.actionref = null

	proc/login(var/list/programlist)
		if(!currentmap)
			return

		var/list/loginlocs = currentmap.getedgetiles()

		for(var/obj/effect/cyberspace/sector/S in loginlocs)
			if(S.get_program())
				loginlocs -= S

		for(var/program in programlist)
			if(!loginlocs.len) break

			var/obj/effect/cyberspace/sector/loginloc = pick(loginlocs)

			allprograms += loginloc.deploy(program,src)

			loginlocs -= loginloc

		currentmap.sendmessage("User logging in...")

	proc/logout()
		if(!currentmap)
			return

		for(var/obj/effect/cyberspace/program/prg in allprograms)
			prg.damage(99999)

		currentmap.sendmessage("User logging out...")

	proc/sendmessage(string as text)
		message_history_new += "[string]<BR>"

		//if(client)
			//client << output(string,"cyberwindow.cyberoutput")

	proc/getallcontents()
		var/list/rlist = list()

		if(currentmap)
			rlist +=  currentmap.getallcontents()

		rlist += hud

		return rlist