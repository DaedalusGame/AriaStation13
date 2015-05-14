var/hudwidth = 13
var/hudheight = 13

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

client/proc/reset_cyberspace()
	screen -= cyberlist

client/proc/update_cyberspace(var/datum/cyberuser/CU)
	if(!CU.currentmap) return

	var/newcyberlist = CU.getallcontents()

	//screen -= cyberlist
	//for(var/atom/A in cyberlist)
	//	if(!(A in newcyberlist))
	//		screen -= A

	cyberlist = newcyberlist

	//for(var/obj/effect/cyberspace/S in newcyberlist)
		//S.update_cybericon()
		//if(S.pre_screen_loc)
		//	S.screen_loc = "cybermap:[S.pre_screen_loc]"

	screen |= cyberlist

	//screen += newcyberlist
	//for(var/atom/A in newcyberlist)
	//	if(!(A in cyberlist))
	//		screen += A

client/proc/update_cyberunit(var/obj/effect/cyberspace/cunit)
	cyberlist |= cunit
	screen |= cunit

obj/effect/cyberspace
	var/cyberx = 0
	var/cybery = 0
	var/pre_screen_loc = null

	proc/getmap()
		return

	proc/get_program()
		return

	proc/particle_explode(var/n,var/color = "#FFFFFF")
		for(var/i = 0, i < n, i++)
			var/image/I = image('effects.dmi',src,"white")
			I.color = color
			world << I

			var/matrix/start = matrix()
			start.Scale(0.25,0.25)
			start.Turn(128)
			var/matrix/end = matrix()
			end.Scale(0.25,0.25)
			end.Turn(0)

			animate(I, transform = start, time = 0, loop=-1)
			animate(transform=end,alpha = 0,pixel_x = rand(-200,200),pixel_y = rand(-200,200),time=rand(5,15), loop=-1)

	proc/update_cybericon(var/datum/cyberuser/user)
		var/obj/effect/cyberspace/mapholder/map = getmap()

		if(!map) return

		var/totalx = (cyberx-1) * 32 + hudwidth * 16 - map.width * 16
		var/totaly = (cybery-1) * 32 + hudheight * 16 - map.height * 16

		pre_screen_loc = "[round(totalx / 32)]:[totalx % 32],[round(totaly / 32)]:[totaly % 32]"

		if(pre_screen_loc)
			screen_loc = "cybermap:[pre_screen_loc]"

		map.update_cyberunit(src)

	Click()
		var/datum/cyberuser/user = usr.get_cyberspace_interface()

		user.click_act(src)

obj/effect/cyberspace/screen
	name = "screen"
	icon = 'screen_network.dmi'
	layer = FLY_LAYER

	update_cybericon()
		if(pre_screen_loc)
			screen_loc = "cybermap:[pre_screen_loc]"

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

			if(pre_screen_loc)
				screen_loc = "cybermap:[pre_screen_loc]"

obj/effect/cyberspace/mapholder
	name = "cybermap"
	desc = "you should never see this"
	//var/list/sectors = list()
	var/list/possibletiles = list(0,1,2,3)
	var/list/connected = list()
	var/width = 0
	var/height = 0

	getmap()
		return src

	proc/connect(var/datum/cyberuser/C)
		if(C in connected) return

		C.currentmap = src
		connected += C

	proc/disconnect(var/datum/cyberuser/C)
		if(C in connected)
			connected -= C

		C.currentmap = null

	proc/update_cyberunit(var/obj/effect/cyberspace/cunit)
		for(var/datum/cyberuser/cu in connected)
			if(cu.currentclient)
				cu.currentclient.update_cyberunit(cunit)

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
			if(!S.is_solid() && (S.cyberx <= 1 || S.cybery <= 1 || S.cyberx >= width || S.cybery >= height))
				edgetiles += S

		return edgetiles

	proc/get_adjacent_sectors(var/xx,var/yy)
		var/list/rlist = list()

		for(var/d in cardinal)
			var/xo = ((d & 4) > 0) - ((d & 8) > 0)
			var/yo = ((d & 1) > 0) - ((d & 2) > 0)

			var/obj/effect/cyberspace/sector/S = gettile(xx + xo,yy + yo)

			if(S && !S.is_solid())
				rlist += S

			//world << "adjacent: [gettile(xx + xo,yy + yo)]"

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

	getmap()
		var/obj/effect/cyberspace/mapholder/map = loc

		return map.getmap()

	get_program()
		var/obj/effect/cyberspace/program/prg = locate() in src

		if(prg)
			return prg.get_program()

	verb/install()
		var/list/programs = typesof(/obj/effect/cyberspace/program) - /obj/effect/cyberspace/program

		var/prog = input("Select a program","Install Wizard") in programs

		if(!prog) return

		deploy(prog)

	proc/install_proc(var/mob/user,var/list/programs)
		var/prog = input(user,"Select a program","Install Wizard") in programs

		if(!prog) return 0

		deploy(prog)

		return 1

	proc/is_solid()
		switch(state)
			if(2,3)
				return 1
			else
				return 0

	proc/has_enemy(var/obj/effect/cyberspace/program/prg)
		var/obj/effect/cyberspace/program/P = locate() in src

		if(!P)
			return 0

		if(istype(P,/obj/effect/cyberspace/program/tail))
			var/obj/effect/cyberspace/program/tail/T = P

			if(T.master != prg)
				return 1
		else if(P != prg)
			return 1

		return 0

	proc/setstate(id)
		state = id
		update_cybericon()

	proc/deploy(var/type,var/datum/cyberuser/owner = null)
		if(!is_solid() && !locate(/obj/effect/cyberspace/program) in src)
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
		//world << "trying to get adjacent sectors"

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