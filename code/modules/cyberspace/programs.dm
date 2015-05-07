obj/effect/cyberspace/program
	icon = 'network.dmi'
	icon_state = "program"
	var/owner = ""
	var/cybercolor = "#FFFFFF"
	var/icon/preicon
	var/list/trail = list()

	var/movespeed = 1
	var/maxlength = 1

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

	var/icon/mainicon
	var/icon/connecticon

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

		spawn(1)
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

	proc/init_programicon()
		mainicon = icon(preicon,"program")
		mainicon.Blend(cybercolor,ICON_MULTIPLY)

		connecticon = icon(preicon,"program-c")
		connecticon.Blend(cybercolor,ICON_MULTIPLY)

	update_cybericon()
		overlays.Cut()

		var/obj/effect/cyberspace/program/head = src
		if(istype(src,/obj/effect/cyberspace/program/tail))
			head = src:master

			//world << "Master: [src:master]"

		if(!preicon)
			preicon = icon

			if(head == src)
				init_programicon()

		if(!head) return

		//var/icon/newicon = icon(preicon,"program")
		//newicon.Blend(head.cybercolor,ICON_MULTIPLY)
		icon = head.mainicon

		//world << head.cybercolor

		for(var/d in cardinal)
			var/xo = ((d & 4) > 0) - ((d & 8) > 0)
			var/yo = ((d & 1) > 0) - ((d & 2) > 0)

			//world << "[d] = [xo],[yo]"

			var/obj/effect/cyberspace/sector/S = gettile(cyberx + xo,cybery + yo)

			if(!S) continue

			var/obj/effect/cyberspace/program/T = locate() in S

			if(T && (T == head || (istype(T,/obj/effect/cyberspace/program/tail) && T:master == head)))
				//var/icon/diricon = icon(preicon,"program-c",d)
				//diricon.Blend(head.cybercolor,ICON_MULTIPLY)
				//newicon.Blend(diricon,ICON_OVERLAY)
				overlays += icon(head.connecticon,dir=d)

				//world << head.cybercolor
				//world << T

		if(head == src)
			overlays += icon(preicon,icon_state)
			//newicon.Blend(icon(preicon,icon_state),ICON_OVERLAY)
		//icon = newicon

		..()

	get_program()
		return src

	proc/movepathto(x,y)
		return movepath(gettile(x,y))

	proc/movepath(var/obj/effect/cyberspace/sector/dest)
		//world << "moving [src] from \ref[src.loc] to \ref[dest]"

		var/list/path = AStar(src.loc, dest, /obj/effect/cyberspace/sector/proc/get_adjacent_sectors, /obj/effect/cyberspace/sector/proc/distance_ortho, movespeed, 120)
		path = reverselist(path)

		for(var/obj/effect/cyberspace/sector/pathsegment in path)
			//world << "moving to [pathsegment]"
			move(pathsegment)

		return path.len

	proc/moveto(x,y)
		return move(gettile(x,y))

	proc/move(var/obj/effect/cyberspace/sector/S)
		if(!S || S.is_solid() || S.has_enemy(src)) return

		var/currenttile = src.loc

		var/obj/effect/cyberspace/program/tail/T = locate() in S

		if(T && T.master == src)
			trail -= T
			del(T)

		. = Move(S)

		maketail(currenttile)

	proc/maketail(var/obj/effect/cyberspace/sector/S)
		if(!S) return

		if(trail.len + 1 >= maxlength)
			deletetail()

		//world << "Making tail at [S]"

		var/obj/effect/cyberspace/program/tail/T = S.deploy(/obj/effect/cyberspace/program/tail) //Doesn't need an owner
		if(T)
			T.master = src
			trail.Insert(1,T)
		//else
			//world << "Failed"

	proc/get_size()
		return (trail.len + 1)

	proc/get_adjacent_sectors()
		if(!istype(loc,/obj/effect/cyberspace/sector)) return list()

		var/obj/effect/cyberspace/sector/sec = loc

		return sec.get_adjacent_sectors()

	proc/deletetail()
		if(trail.len > 0)
			del(trail[trail.len])
			trail.Cut(trail.len)
		else
			del(src)

	proc/damage(var/n)
		if(n)
			particle_explode(16,"#FFFFFF")

		while(n--)
			deletetail()
			sleep(0.1)

	particle_explode(var/n,var/color = "#FFFFFF")
		var/obj/effect/cyberspace/sector/sec = loc

		sec.particle_explode(n,color)

	proc/grow(var/n)
		var/i = rand(0,trail.len)
		var/e = 0

		if(n)
			particle_explode(16,"#00FFFF")

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
				if(!n) break

				var/obj/effect/cyberspace/program/tail/T = S.deploy(/obj/effect/cyberspace/program/tail)
				if(T)
					T.master = src
					trail.Add(T)
					n--
					sleep(0.1)

			i++

	proc/sendmessage(string)
		var/obj/effect/cyberspace/mapholder/M = getmap()
		if(M) M.sendmessage(string)

	proc/gettile(x,y)
		var/obj/effect/cyberspace/mapholder/M = getmap()

		if(M)
			return M.gettile(x,y)

	getmap()
		var/obj/effect/cyberspace/sector/S = loc

		if(S)
			return S.getmap()

	tail	//Technical program that is created as the tail of a moving program
		name = "\improper TAIL"
		var/obj/effect/cyberspace/program/master

		damage(var/n)
			if(!master) return
			master.damage(n)

		grow(var/n)
			if(!master) return
			master.grow(n)

		get_program()
			return master

	//Hack series
	hack1
		name = "\improper HACK 1.0"
		icon_state = "hack1"

		maxlength = 4
		movespeed = 2

		action2_type = /datum/cyberaction/attack/slice

	hack2
		name = "\improper HACK 2.0"
		icon_state = "hack2"

		maxlength = 4
		movespeed = 3

		action2_type = /datum/cyberaction/attack/slice
		action3_type = /datum/cyberaction/attack/dice

	hack3
		name = "\improper HACK 3.0"
		icon_state = "hack3"

		maxlength = 4
		movespeed = 4

		action2_type = /datum/cyberaction/attack/slice
		action3_type = /datum/cyberaction/attack/mutilate

	//Bug series
	bug
		name = "\improper BUG"
		icon_state = "bug1"

		maxlength = 1
		movespeed = 5

		action2_type = /datum/cyberaction/attack/glitch

	mandelbug
		name = "\improper MANDELBUG"
		icon_state = "bug2"

		maxlength = 1
		movespeed = 5

		action2_type = /datum/cyberaction/attack/fractal_glitch

	heisenbug
		name = "\improper HEISENBUG"
		icon_state = "bug3"

		maxlength = 1
		movespeed = 5

		action2_type = /datum/cyberaction/attack/quantum_glitch

	//Sling series
	slingshot
		name = "\improper SLINGSHOT"
		icon_state = "shot1"

		maxlength = 2
		movespeed = 2

		action2_type = /datum/cyberaction/attack/stone

	ballista
		name = "\improper BALLISTA"
		icon_state = "shot2"

		maxlength = 2
		movespeed = 1

		action2_type = /datum/cyberaction/attack/fling

	catapult
		name = "\improper CATAPULT"
		icon_state = "shot3"

		maxlength = 3
		movespeed = 2

		action2_type = /datum/cyberaction/attack/fling

	//Doctor series
	data_doctor
		name = "\improper DATA DOCTOR"
		icon_state = "medic1"

		maxlength = 5
		movespeed = 4

		action2_type = /datum/cyberaction/heal/grow

	medic
		name = "\improper MEDIC"
		icon_state = "medic2"

		maxlength = 3
		movespeed = 3

		action2_type = /datum/cyberaction/heal/hypo

	data_doctor_pro
		name = "\improper DATA DOCTOR PRO"
		icon_state = "medic3"

		maxlength = 8
		movespeed = 5

		action2_type = /datum/cyberaction/heal/megagrow
		action3_type = /datum/cyberaction/sizechange/surgery

	//Bit-man
	bit_man
		name = "\improper BIT-MAN"
		icon_state = "bitman"

		maxlength = 3
		movespeed = 3

		action2_type = /datum/cyberaction/bit0
		action3_type = /datum/cyberaction/bit1

	//Clog series
	clog1
		name = "\improper CLOG.01"
		icon_state = "clog1"

		maxlength = 4
		movespeed = 2

		action2_type = /datum/cyberaction/speedchange/lag

	clog2
		name = "\improper CLOG.02"
		icon_state = "clog2"

		maxlength = 4
		movespeed = 2

		action2_type = /datum/cyberaction/speedchange/chug

	clog3
		name = "\improper CLOG.03"
		icon_state = "clog3"

		maxlength = 4
		movespeed = 2

		action2_type = /datum/cyberaction/speedchange/chug
		action3_type = /datum/cyberaction/speedchange/hang

	//Golem series
	golem_mud
		name = "\improper GOLEM.MUD"
		icon_state = "golem1"

		maxlength = 5
		movespeed = 1

		action2_type = /datum/cyberaction/attack/thump

	golem_clay
		name = "\improper GOLEM.CLAY"
		icon_state = "golem2"

		maxlength = 6
		movespeed = 2

		action2_type = /datum/cyberaction/attack/bash

	golem_stone
		name = "\improper GOLEM.STONE"
		icon_state = "golem3"

		maxlength = 7
		movespeed = 3

		action2_type = /datum/cyberaction/attack/crash

	//Spider series
	wolf_spider
		name = "\improper WOLF SPIDER"
		icon_state = "crawl1"

		maxlength = 3
		movespeed = 3

		action2_type = /datum/cyberaction/attack/byte

	black_widow
		name = "\improper BLACK WIDOW"
		icon_state = "crawl2"

		maxlength = 3
		movespeed = 4

		action2_type = /datum/cyberaction/attack/byte
		action3_type = /datum/cyberaction/speedchange/paralyze

	tarantula
		name = "\improper TARANTULA"
		icon_state = "crawl3"

		maxlength = 3
		movespeed = 5

		action2_type = /datum/cyberaction/attack/megabyte
		action3_type = /datum/cyberaction/speedchange/paralyze

	//Seeker series
	seeker
		name = "\improper SEEKER"
		icon_state = "seek1"

		maxlength = 3
		movespeed = 3

		action2_type = /datum/cyberaction/attack/peek

	seeker2
		name = "\improper SEEKER 2.0"
		icon_state = "seek2"

		maxlength = 4
		movespeed = 3

		action2_type = /datum/cyberaction/attack/poke

	seeker3
		name = "\improper SEEKER 3.0"
		icon_state = "seek3"

		maxlength = 5
		movespeed = 4

		action2_type = /datum/cyberaction/attack/poke
		action3_type = /datum/cyberaction/attack/seek_and_destroy

	//Tower series
	tower
		name = "\improper TOWER"
		icon_state = "tower"

		maxlength = 1
		movespeed = 0

		action2_type = /datum/cyberaction/attack/spot

	mobile_tower
		name = "\improper MOBILE TOWER"
		icon_state = "movingtower"

		maxlength = 1
		movespeed = 1

		action2_type = /datum/cyberaction/attack/spot

	//Satellite series
	laser_satellite
		name = "\improper SATELLITE"
		icon_state = "satellite1"

		maxlength = 1
		movespeed = 1

		action2_type = /datum/cyberaction/attack/scramble

	laser_satellite
		name = "\improper LASER SATELLITE"
		icon_state = "satellite2"

		maxlength = 1
		movespeed = 2

		action2_type = /datum/cyberaction/attack/megascramble

	//Turbo series
	turbo
		name = "\improper TURBO"
		icon_state = "boost1"

		maxlength = 3
		movespeed = 3

		action2_type = /datum/cyberaction/speedchange/boost

	turbo_dx
		name = "\improper TURBO DELUXE"
		icon_state = "boost2"

		maxlength = 4
		movespeed = 4

		action2_type = /datum/cyberaction/speedchange/megaboost

	//Fiddle
	fiddle
		name = "\improper FIDDLE"
		icon_state = "tweak"

		maxlength = 3
		movespeed = 3

		action2_type = /datum/cyberaction/sizechange/twiddle
		action3_type = /datum/cyberaction/speedchange/tweak

	//Bomb series
	buzzbomb
		name = "\improper BUZZBOMB"
		icon_state = "bomb1"

		maxlength = 2
		movespeed = 8

		action2_type = /datum/cyberaction/attack/sting
		action3_type = /datum/cyberaction/attack/kamikaze

	logicbomb
		name = "\improper LOGICBOMB"
		icon_state = "bomb2"

		maxlength = 6
		movespeed = 3

		action2_type = /datum/cyberaction/attack/selfdestruct

	forkbomb
		name = "\improper FORKBOMB"
		icon_state = "bomb3"

		maxlength = 2
		movespeed = 4

		action2_type = /datum/cyberaction/fusion/fusionbomb
		action3_type = /datum/cyberaction/attack/splitbomb

	//Sumo
	sumo
		name = "\improper SUMO"
		icon_state = "sumo"

		maxlength = 12
		movespeed = 2

		action2_type = /datum/cyberaction/attack/dataslam

	//Memory Hog
	memory_hog
		name = "\improper MEMORY HOG"
		icon_state = "hog"

		maxlength = 30
		movespeed = 5

		action2_type = /datum/cyberaction/bloat

	//Guru
	guru
		name = "\improper GURU"
		icon_state = "read"

		maxlength = 3
		movespeed = 2

		action2_type = /datum/cyberaction/attack/fire
		action3_type = /datum/cyberaction/speedchange/ice

	//Wizard
	wizard
		name = "\improper WIZARD"
		icon_state = "wizard"

		maxlength = 4
		movespeed = 3

		action2_type = /datum/cyberaction/attack/scorch
		action3_type = /datum/cyberaction/sizechange/stretch
		action4_type = /datum/cyberaction/install

	//Database
	database
		name = "\improper DATABASE"
		icon_state = "file"

		maxlength = 20
		movespeed = 0

		owner = "ai"

	//Watchman series
	watchman
		name = "\improper WATCHMAN"
		icon_state = "watch1"
		owner = "ai"

		maxlength = 2
		movespeed = 1

		action2_type = /datum/cyberaction/attack/phaser

	watchmanx
		name = "\improper WATCHMAN X"
		icon_state = "watch2"
		owner = "ai"

		maxlength = 4
		movespeed = 1

		action2_type = /datum/cyberaction/attack/phaser

	watchmansp
		name = "\improper WATCHMAN SP"
		icon_state = "watch3"
		owner = "ai"

		maxlength = 4
		movespeed = 1

		action2_type = /datum/cyberaction/attack/photon

	dog
		name = "\improper GUARD PUP"
		icon_state = "dog1"
		owner = "ai"

		maxlength = 2
		movespeed = 3

		action2_type = /datum/cyberaction/attack/byte

	dogguard
		name = "\improper GUARD DOG"
		icon_state = "dog2"
		owner = "ai"

		maxlength = 3
		movespeed = 3

		action2_type = /datum/cyberaction/attack/byte

	dogattack
		name = "\improper ATTACK DOG"
		icon_state = "dog3"
		owner = "ai"

		maxlength = 7
		movespeed = 4

		action2_type = /datum/cyberaction/attack/megabyte

	sentinel1
		name = "\improper SENTINEL 1.0"
		icon_state = "sentinel1"
		owner = "ai"

		maxlength = 3
		movespeed = 1

		action2_type = /datum/cyberaction/attack/cut

	sentinel2
		name = "\improper SENTINEL 2.0"
		icon_state = "sentinel1"
		owner = "ai"

		maxlength = 4
		movespeed = 2

		action2_type = /datum/cyberaction/attack/cut

	sentinel3
		name = "\improper SENTINEL 3.0"
		icon_state = "sentinel1"
		owner = "ai"

		maxlength = 4
		movespeed = 2

		action2_type = /datum/cyberaction/attack/taser

	warden
		name = "\improper WARDEN"
		icon_state = "warden1"
		owner = "ai"

		maxlength = 5
		movespeed = 1

		action2_type = /datum/cyberaction/attack/thump

	wardenplus
		name = "\improper WARDEN+"
		icon_state = "warden2"
		owner = "ai"

		maxlength = 7
		movespeed = 3

		action2_type = /datum/cyberaction/attack/bash

	wardenplusplus
		name = "\improper WARDEN++"
		icon_state = "warden3"
		owner = "ai"

		maxlength = 7
		movespeed = 3

		action2_type = /datum/cyberaction/attack/crash

	sensor
		name = "\improper SENSOR"
		icon_state = "radar1"
		owner = "ai"

		maxlength = 1
		movespeed = 0

		action2_type = /datum/cyberaction/attack/blip

	sonar
		name = "\improper SONAR"
		icon_state = "radar2"
		owner = "ai"

		maxlength = 1
		movespeed = 0

		action2_type = /datum/cyberaction/attack/ping

	radar
		name = "\improper RADAR"
		icon_state = "radar3"
		owner = "ai"

		maxlength = 1
		movespeed = 0

		action2_type = /datum/cyberaction/attack/pong

	boss
		name = "\improper BOSS"
		icon_state = "boss"
		owner = "ai"

		maxlength = 25
		movespeed = 6

		initialsize = 15

		action2_type = /datum/cyberaction/attack/shutdown

	firewall
		name = "\improper FIREWALL"
		icon_state = "firewall"
		owner = "ai"

		maxlength = 20
		movespeed = 2

		initialsize = 10

		action2_type = /datum/cyberaction/attack/burn