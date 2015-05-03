obj/effect/cyberspace/program
	icon = 'network.dmi'
	icon_state = "program"
	var/owner = ""
	var/cybercolor = "#FFFFFF"
	var/icon/preicon
	var/list/trail = list()

	var/movespeed = 4
	var/maxlength = 8

	var/initialsize = 0		//How much to grow it initially, good for AI and firewalls that need to span a wide area

	var/action1
	var/action2
	var/action3
	var/action4
	var/action5

	var/action1_type = /datum/cyberaction/move
	var/action2_type
	var/action3_type
	var/action4_type
	var/action5_type

	New(loc)
		..()

		var/obj/effect/cyberspace/sector/S = loc

		if(!S)
			del(src)

		cyberx = S.cyberx
		cybery = S.cybery
		cybercolor = rgb(rand(128,255),rand(128,255),rand(128,255))

		if(action1_type) action1 = new action1_type(src)
		if(action2_type) action2 = new action2_type(src)
		if(action3_type) action3 = new action3_type(src)
		if(action4_type) action4 = new action4_type(src)
		if(action5_type) action5 = new action5_type(src)

		grow(initialsize)

		update_cybericon()

	Move(loc,dir)
		var/obj/effect/cyberspace/sector/S = loc

		if(!S)
			return 0

		cyberx = S.cyberx
		cybery = S.cybery

		..()

	/*Click()
		var/client/c = usr.client
		if(c.currentcyberspace)
			c.currentcyberspace.select(src)*/

	update_cybericon()
		if(!preicon)
			preicon = icon

		var/obj/effect/cyberspace/program/head = src
		if(istype(src,/obj/effect/cyberspace/program/tail))
			head = src:master
			//world << "Master: [src:master]"

		if(!head) return

		var/icon/newicon = icon(preicon,"program")
		newicon.Blend(head.cybercolor,ICON_MULTIPLY)

		//world << head.cybercolor

		for(var/d in cardinal)
			var/xo = ((d & 4) > 0) - ((d & 8) > 0)
			var/yo = ((d & 1) > 0) - ((d & 2) > 0)

			//world << "[d] = [xo],[yo]"

			var/obj/effect/cyberspace/sector/S = gettile(cyberx + xo,cybery + yo)

			if(!S) continue

			var/obj/effect/cyberspace/program/T = locate() in S

			if(T && (T == head || (istype(T,/obj/effect/cyberspace/program/tail) && T:master == head)))
				var/icon/diricon = icon(preicon,"program-c",d)
				diricon.Blend(head.cybercolor,ICON_MULTIPLY)
				newicon.Blend(diricon,ICON_OVERLAY)

				//world << head.cybercolor
				//world << T

		if(head == src)
			newicon.Blend(icon(preicon,icon_state),ICON_OVERLAY)
		icon = newicon

		..()

	proc/movepathto(x,y)
		return movepath(gettile(x,y))

	proc/movepath(var/obj/effect/cyberspace/sector/dest)
		world << "moving [src] from \ref[src.loc] to \ref[dest]"

		var/list/path = AStar(src.loc, dest, /obj/effect/cyberspace/sector/proc/get_adjacent_sectors, /obj/effect/cyberspace/sector/proc/distance_ortho, 0, 120)
		path = reverselist(path)

		for(var/obj/effect/cyberspace/sector/pathsegment in path)
			world << "moving to [pathsegment]"
			move(pathsegment)

		return path.len

	proc/moveto(x,y)
		return move(gettile(x,y))

	proc/move(var/obj/effect/cyberspace/sector/S)
		var/currenttile = src.loc

		var/obj/effect/cyberspace/program/tail/T = locate() in S

		if(T && T.master == src)
			trail -= T
			del(T)

		. = Move(S)

		maketail(currenttile)

	proc/maketail(var/obj/effect/cyberspace/sector/S)
		if(!S) return

		if(trail.len >= maxlength)
			deletetail()

		//world << "Making tail at [S]"

		var/obj/effect/cyberspace/program/tail/T = S.deploy(/obj/effect/cyberspace/program/tail) //Doesn't need an owner
		if(T)
			T.master = src
			trail.Insert(1,T)
		//else
			//world << "Failed"

	proc/get_adjacent_sectors()
		if(!istype(loc,/obj/effect/cyberspace/sector)) return list()

		var/obj/effect/cyberspace/sector/sec = loc

		return sec.get_adjacent_sectors()

	proc/deletetail()
		if(trail.len > 1)
			del(trail[trail.len])
			trail.Cut(trail.len)
		else
			del(src)

	proc/damage(var/n)
		while(n)
			deletetail()
			n--

	proc/grow(var/n)
		var/i = rand(0,trail.len)
		var/e = 0

		while(n && e < 3)
			var/obj/effect/cyberspace/program/TI

			if(i > trail.len)
				i = 0
				e++

			if(i == 0)
				TI = src
			else
				TI = trail[i]

			for(var/obj/effect/cyberspace/sector/S in TI.get_adjacent_sectors())
				var/obj/effect/cyberspace/program/tail/T = S.deploy(/obj/effect/cyberspace/program/tail)
				if(T)
					T.master = src
					trail.Add(T)
					n--

			i++

	proc/sendmessage(string)
		var/obj/effect/cyberspace/mapholder/M = getmap()
		if(M) M.sendmessage(string)

	proc/gettile(x,y)
		var/obj/effect/cyberspace/mapholder/M = getmap()

		if(M)
			return M.gettile(x,y)

	proc/getmap()
		var/obj/effect/cyberspace/sector/S = loc

		if(S)
			return S.loc

	tail	//Technical program that is created as the tail of a moving program
		name = "\improper TAIL"
		var/obj/effect/cyberspace/program/master

		damage(var/n)
			master.damage(n)

		grow(var/n)
			master.grow(n)

	//LV1 WAREZ
	hack1
		name = "\improper HACK 1.0"
		icon_state = "hack1"

		maxlength = 4
		movespeed = 2

		action2_type = /datum/cyberaction/attack/hack

	bug
		name = "\improper BUG"
		icon_state = "bug1"

		maxlength = 1
		movespeed = 5

		action2_type = /datum/cyberaction/attack/glitch

	slingshot
		name = "\improper SLINGSHOT"
		icon_state = "hack1"

		maxlength = 2
		movespeed = 2

		action2_type = /datum/cyberaction/attack/stone

	data_doctor
		name = "\improper DATA DOCTOR"
		icon_state = "medic1"

		maxlength = 5
		movespeed = 4

		action2_type = /datum/cyberaction/heal/grow

	bit_man
		name = "\improper BIT-MAN"
		icon_state = "bitman"

		maxlength = 3
		movespeed = 3

		action2_type = /datum/cyberaction/bit0
		action3_type = /datum/cyberaction/bit1

	clog1
		name = "\improper CLOG.01"
		icon_state = "clog1"

		maxlength = 4
		movespeed = 2

		action2_type = /datum/cyberaction/attack/stone

	database
		name = "\improper DATABASE"
		icon_state = "file"
		owner = "ai"

	watchman
		name = "\improper WATCHMAN"
		icon_state = "watch1"
		owner = "ai"
		action2_type = /datum/cyberaction/attack/hack

		watchmanx
			name = "\improper WATCHMAN X"
			icon_state = "watch2"
			owner = "ai"

		watchmansp
			name = "\improper WATCHMAN SP"
			icon_state = "watch3"
			owner = "ai"

	dog
		name = "\improper GUARD PUP"
		icon_state = "dog1"
		owner = "ai"

		dogguard
			name = "\improper GUARD DOG"
			icon_state = "dog2"
			owner = "ai"

		dogattack
			name = "\improper ATTACK DOG"
			icon_state = "dog3"
			owner = "ai"

	sentinel1
		name = "\improper SENTINEL 1.0"
		icon_state = "sentinel1"
		owner = "ai"
		action2_type = /datum/cyberaction/attack/hack

		sentinel2
			name = "\improper SENTINEL 2.0"
			icon_state = "sentinel1"
			owner = "ai"

		sentinel3
			name = "\improper SENTINEL 3.0"
			icon_state = "sentinel1"
			owner = "ai"

	warden
		name = "\improper WARDEN"
		icon_state = "warden1"
		owner = "ai"

		wardenplus
			name = "\improper WARDEN+"
			icon_state = "warden2"
			owner = "ai"

		wardenplusplus
			name = "\improper WARDEN++"
			icon_state = "warden3"
			owner = "ai"

	sensor
		name = "\improper SENSOR"
		icon_state = "radar1"
		owner = "ai"

	sonar
		name = "\improper SONAR"
		icon_state = "radar2"
		owner = "ai"

	radar
		name = "\improper RADAR"
		icon_state = "radar3"
		owner = "ai"

	boss
		name = "\improper BOSS"
		icon_state = "boss"
		owner = "ai"
		maxlength = 25
		movespeed = 6

	firewall
		name = "\improper FIREWALL"
		icon_state = "firewall"
		owner = "ai"
		maxlength = 20
		movespeed = 2