turf/cyberspace
	name = "sector"
	icon = 'network.dmi'
	icon_state = "sector"

turf/cyberspace/full
	name = "data sector"
	icon = 'network.dmi'
	icon_state = "fullsector"

turf/cyberspace/hole
	name = "empty sector"
	icon_state = "nosector"
	density = 1

turf/cyberspace/block
	name = "blocked sector"
	icon = 'network.dmi'
	icon_state = "block"

var/list/cyberusers = list()

datum/cyberuser
	//var/key
	//var/mob/currentmob
	//var/client/client
	var/obj/effect/cyberspace/mapholder/currentmap
	var/obj/effect/cyberspace/program/selected
	var/obj/effect/cyberspace/screen/action/selected_action

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

	proc/click_act(var/obj/effect/cyberspace/clicktarget)
		if(istype(clicktarget,/obj/effect/cyberspace/program))
			if(selected_action)
				selected_action.actionref.use(clicktarget)
			else
				select(clicktarget)
		if(istype(clicktarget,/obj/effect/cyberspace/sector))
			if(selected_action)
				selected_action.actionref.use(clicktarget)
		if(istype(clicktarget,/obj/effect/cyberspace/screen/action))
			var/obj/effect/cyberspace/screen/action/A = clicktarget

			if(A.actionref && selected_action != clicktarget)
				select_action(clicktarget)
			else
				select_action(null)

	proc/select(var/obj/effect/cyberspace/program/PRG)
		//if(selected.owner != src) return

		selected = PRG
		updatehud()

	proc/select_action(var/obj/effect/cyberspace/screen/action/act)
		//if(selected.owner != src) return

		selected_action = act
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
		topmessage.pre_screen_loc = "0,[height]"
		topmessagebox.pre_screen_loc = "0,[height] to [width-1],[height]"
		bottommessage.pre_screen_loc = "0,-1"
		bottommessagebox.pre_screen_loc = "0,-1 to [width-1],-1"
		blocker.pre_screen_loc = "5,-2 to [width-1],-2"
		action1.pre_screen_loc = "0,-2"
		action2.pre_screen_loc = "1,-2"
		action3.pre_screen_loc = "2,-2"
		action4.pre_screen_loc = "3,-2"
		action5.pre_screen_loc = "4,-2"
		/*for(var/obj/effect/cyberspace/screen/action/A in hud)
			if(selected)
				A.icon_state = "slot1"
			else
				A.icon_state = "slot0"*/

		topmessage.maptext_width = width * 32
		bottommessage.maptext_width = width * 32

		if(selected_action)
			topmessage.maptext = "<text align=top><FONT COLOR='#00FF00'>[selected_action.actionref.name]<BR>[selected_action.actionref.desc]</FONT></text>"
		else if(selected)
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

client
	//var/datum/cyberuser/currentcyberspace
	var/list/cyberlist = list()

/*client/proc/enter_cyberspace(var/obj/effect/cyberspace/mapholder/M)
	if(!currentcyberspace)
		currentcyberspace = new(key)
	if(currentcyberspace.currentmap)
		currentcyberspace.currentmap.disconnect(currentcyberspace)
	currentcyberspace.currentmap = M
	currentcyberspace.currentmap.connect(currentcyberspace)

	show_cyberspace()*/

client/proc/show_cyberspace()
	winshow(src,"cyberwindow",1)
	//update_cyberspace()

client/proc/hide_cyberspace()
	winshow(src,"cyberwindow",0)

client/proc/update_cyberspace(var/datum/cyberuser/CU)
	screen -= cyberlist

	if(!CU.currentmap) return

	cyberlist = CU.getallcontents()

	for(var/obj/effect/cyberspace/S in cyberlist)
		S.update_cybericon()
		if(S.pre_screen_loc)
			S.screen_loc = "cybermap:[S.pre_screen_loc]"

	screen += cyberlist


obj/effect/cyberspace
	var/cyberx = 0
	var/cybery = 0
	var/pre_screen_loc = null

	proc/update_cybericon()
		pre_screen_loc = "[cyberx-1],[cybery-1]"

	Click()
		var/datum/cyberuser/user = usr.get_cyberspace_interface()

		user.click_act(src)

obj/effect/cyberspace/screen
	name = "screen"
	icon = 'screen_network.dmi'
	layer = FLY_LAYER

	update_cybericon()
		return

	action
		var/datum/cyberaction/actionref
		icon_state = "slot0"

		update_cybericon()
			overlays.Cut()

			if(!actionref)
				icon_state = "slot0"
				return

			icon_state = "slot1"

			overlays += icon(icon,actionref.icon_state)
			return

obj/effect/cyberspace/mapholder
	name = "cybermap"
	desc = "you should never see this"
	//var/list/sectors = list()
	var/list/possibletiles = list(0,1,2,3)
	var/list/connected = list()
	var/width = 0
	var/height = 0

	proc/connect(var/datum/cyberuser/C)
		if(C in connected) return

		C.currentmap = src
		connected += C

	proc/disconnect(var/datum/cyberuser/C)
		if(C in connected)
			connected -= C

		C.currentmap = null

	proc/sendmessage(string as text)
		for(var/datum/cyberuser/c in connected)
			c.sendmessage(string)

	proc/getallcontents()
		var/rcontent = list()

		for(var/obj/effect/cyberspace/sector/S in contents)
			rcontent += S.contents

		rcontent += contents

		return rcontent

	proc/gettile(x,y)
		for(var/obj/effect/cyberspace/sector/S in src)
			if(S.cyberx == x && S.cybery == y)
				return S

		return null

	proc/settile(x,y,id)
		var/obj/effect/cyberspace/sector/S = gettile(x,y)

		if(!S)
			S = new(src)
			S.cyberx = x
			S.cybery = y

		S.setstate(id)

	proc/createrect(x1,y1,x2,y2,id)
		for(var/x = x1, x <= x2, x++)
			for(var/y = y1, y <= y2, y++)
				if(!gettile(x,y))
					settile(x,y,id)

	proc/setrect(x1,y1,x2,y2,id)
		var/temp

		if(x1 > x2)
			temp = x1
			x1 = x2
			x2 = temp

		if(y1 > y2)
			temp = y1
			y1 = y2
			y2 = temp

		for(var/obj/effect/cyberspace/sector/S in src)
			if(S.cyberx >= x1 && S.cybery >= y1 && S.cyberx <= x2 && S.cybery <= y2)
				S.setstate(id)

	proc/generate(w,h,iter)
		width = w
		height = h

		createrect(1,1,width,height,0)

		for(var/i=0, i<iter, i++)
			setrect(rand(1,width),rand(1,height),rand(1,width),rand(1,height),pick(possibletiles))

		//make sure we can still enter/leave from the sides
		setrect(rand(1,width),1,rand(1,width),1,0)
		setrect(rand(1,width),height,rand(1,width),height,0)
		setrect(1,rand(1,height),1,rand(1,height),0)
		setrect(width,rand(1,height),width,rand(1,height),0)

	proc/getedgetiles()
		var/list/edgetiles = list()

		for(var/obj/effect/cyberspace/sector/S in src)
			if(S.state == 0 && (S.cyberx <= 1 || S.cybery <= 1 || S.cyberx >= width || S.cybery >= height))
				edgetiles += S

		return edgetiles

	proc/get_adjacent_sectors(var/xx,var/yy)
		var/list/rlist = list()

		for(var/d in cardinal)
			var/xo = ((d & 4) > 0) - ((d & 8) > 0)
			var/yo = ((d & 1) > 0) - ((d & 2) > 0)

			rlist += gettile(xx + xo,yy + yo)

			world << "adjacent: [gettile(xx + xo,yy + yo)]"

		return rlist

	proc/enter(var/obj/effect/cyberspace/program/P)
		var/list/edges = getedgetiles()
		var/obj/effect/cyberspace/sector/S = pick(edges)

		if(S)
			return P.move(S)

		return 0

	proc/get_free_spots()
		var/list/freetiles = list()

		for(var/obj/effect/cyberspace/sector/S in src)
			if(S.state == 0 && !locate(/obj/effect/cyberspace/program) in S)
				freetiles += S

		return freetiles

obj/effect/cyberspace/sector
	name = "sector"
	icon = 'network.dmi'
	icon_state = "sector"
	layer = TURF_LAYER
	//mouse_over_pointer = MOUSE_HAND_POINTER

	var/state = 0 	//0 = empty - walkable
					//1 = filled - walkable
					//2 = eaten - hole
					//3 = blocked - protected wall

	var/variation

	New()
		..()
		variation = rand(0,1000)

	verb/install()
		var/list/programs = typesof(/obj/effect/cyberspace/program) - /obj/effect/cyberspace/program

		var/prog = input("Select a program","Install Wizard") in programs

		if(!prog) return

		deploy(prog)

	proc/setstate(id)
		state = id
		update_cybericon()

	proc/deploy(var/type,var/datum/cyberuser/owner = null)
		if(state == 0 && !locate(/obj/effect/cyberspace/program) in src)
			var/obj/effect/cyberspace/program/P = new type(src)
			P.owner = owner
			return P

		return null

	update_cybericon()
		switch(state)
			if(1)
				icon_state = "fullsector"
			if(2)
				icon_state = "nosector"
			if(3)
				icon_state = "block"
			else
				icon_state = "sector"
				if(variation > 500)
					icon_state = "sector[variation % 3]"

		..()

	proc/get_adjacent_sectors(var/id=null)
		world << "trying to get adjacent sectors"

		if(!istype(loc,/obj/effect/cyberspace/mapholder)) return list()

		var/obj/effect/cyberspace/mapholder/map = loc

		return map.get_adjacent_sectors(cyberx,cybery)

	proc/get_adjacent_access(var/id=null)
		if(!istype(loc,/obj/effect/cyberspace/mapholder)) return list()

		var/obj/effect/cyberspace/mapholder/map = loc

		var/list/sectors = map.get_adjacent_sectors(cyberx,cybery)

		for(var/obj/effect/cyberspace/sector/S in sectors)
			if(!S.can_enter(id))
				sectors -= S

		return sectors

	proc/distance_ortho(var/obj/effect/cyberspace/sector/t)
		if(t != null && src != null)
			//world << "dist: [abs(src.cyberx - t.cyberx) + abs(src.cybery - t.cybery)]"
			return abs(src.cyberx - t.cyberx) + abs(src.cybery - t.cybery)

		else
			//world << "dist: infinity"
			return 99999

	proc/can_enter(var/obj/effect/cyberspace/program/prg)
		var/obj/effect/cyberspace/program/otherprg = locate() in src

		switch(state)
			if(2,3)
				return 0

		if(istype(otherprg,/obj/effect/cyberspace/program/tail) && otherprg:master == prg)
			return 1

		if(otherprg)
			return 0

	proc/repair()
		switch(state)
			if(2)
				setstate(0)

	proc/destroy()
		switch(state)
			if(1,3)
				setstate(0)
			else
				setstate(2)

	proc/reinforce()
		switch(state)
			if(1,2,3)
				return
			else
				setstate(1)