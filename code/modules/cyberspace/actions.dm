datum/cyberaction
	var/name
	var/desc
	var/icon_state
	var/obj/effect/cyberspace/program/owner

	var/sizereq = 1		//How many sectors are required on user
	var/cost = 0		//How many sectors are deleted from user

	New(loc)
		..()
		owner = loc

	Del()
		..()

	proc/isowner(var/datum/cyberuser/user)
		if(!owner) return 0

		return owner.owner == user

	proc/use(var/obj/effect/cyberspace/target)
		return 0

	proc/get_range_name(var/n)
		switch(n)
			if(0)
				return "no squares"
			if(1)
				return "1 square"
			else
				return "[n] squares"

	move
		name = "Move"
		icon_state = "move"
		var/distance = 1

		New()
			..()
			desc = "Moves up to [get_range_name(distance)] squares."

		use(var/obj/effect/cyberspace/target)
			if(!istype(target,/obj/effect/cyberspace/sector))
				target = target.loc

			var/obj/effect/cyberspace/sector/S = target
			var/dist = abs(S.cyberx - owner.cyberx) + abs(S.cybery - owner.cybery)

			if(dist <= owner.movespeed)
				return owner.movepath(S)

			return 0

	attack
		name = "Attack"
		icon_state = "slam"
		var/distance = 1
		var/attackpower = 1

		//Sentinel
		cut
			name = "Cut"
			icon_state = "hack"
			attackpower = 2

		taser
			name = "Taser"
			icon_state = "zap"
			attackpower = 4

		//Watchman
		phaser
			name = "Phaser"
			icon_state = "slam"
			attackpower = 2
			distance = 2

		photon
			name = "Photon"
			icon_state = "slam"
			attackpower = 2
			distance = 3

		//Sensors
		blip
			name = "Blip"
			icon_state = "signal"
			attackpower = 1
			distance = 5

		ping
			name = "Ping"
			icon_state = "signal"
			attackpower = 1
			distance = 8

		pong
			name = "Pong"
			icon_state = "signal"
			attackpower = 2
			distance = 5

		//Firewall
		burn
			name = "Burn"
			icon_state = "burn"
			attackpower = 1


		//Hack
		hack
			name = "Hack"
			icon_state = "hack"
			attackpower = 2

		slice
			name = "Slice"
			icon_state = "hack"
			attackpower = 2

		dice
			name = "Dice"
			icon_state = "bighack"
			attackpower = 3
			sizereq = 3

		mutilate //better version for hack 3.0
			name = "Mutilate"
			icon_state = "bighack"
			attackpower = 4
			sizereq = 4

		//Glitch
		glitch
			name = "Glitch"
			icon_state = "bug"
			attackpower = 2

		fractal_glitch
			name = "Fractal Glitch"
			icon_state = "mandelbug"
			attackpower = 4

		quantum_glitch
			name = "Quantum Glitch"
			icon_state = "heisenbug"
			attackpower = 6

		//Sling
		stone
			name = "Stone"
			icon_state = "sling"
			attackpower = 1
			distance = 3

		fling
			name = "Fling"
			icon_state = "ballista"
			attackpower = 2
			distance = 4

		//Golem
		thump
			name = "Thump"
			icon_state = "slam"
			attackpower = 3

		bash
			name = "Bash"
			icon_state = "slam"
			attackpower = 5

		crash
			name = "Crash"
			icon_state = "slam"
			attackpower = 7

		//Spider and Dog
		byte
			name = "Byte"
			icon_state = "bite"
			attackpower = 2

		megabyte
			name = "Megabyte"
			icon_state = "megabite"
			attackpower = 3

		//Telescope
		peek
			name = "Peek"
			icon_state = "telescope"
			attackpower = 2
			distance = 2

		poke
			name = "Poke"
			icon_state = "telescope"
			attackpower = 2
			distance = 3

		seek_and_destroy //This ones complicated. you need to be 5 long, and it costs 2 to deal 5 damage over distance 2
			name = "Seek&Destroy"
			icon_state = "zap"
			attackpower = 5
			distance = 2
			sizereq = 5
			cost = 2

		//Tower
		spot
			name = "Spot"
			icon_state = "zap"
			attackpower = 3
			distance = 3

		//Satellite
		scramble
			name = "Scramble"
			icon_state = "minisat"
			attackpower = 4
			distance = 2

		megascramble
			name = "Megascramble"
			icon_state = "sat"
			attackpower = 4
			distance = 3


		//Guru
		fire
			name = "Fire"
			icon_state = "burn"
			attackpower = 4
			distance = 2

		//Wizard
		scorch
			name = "Scorch"
			icon_state = "burn"
			attackpower = 2
			distance = 3

		//Bombs
		sting
			name = "Sting"
			icon_state = "slam"
			attackpower = 1

		kamikaze
			name = "Kamikaze"
			icon_state = "bomb"
			attackpower = 5
			cost = 99999

		selfdestruct
			name = "Selfdestruct"
			icon_state = "bomb"
			attackpower = 10
			cost = 99999

		splitbomb //This will do something different
			name = "Splitbomb"
			icon_state = "splitbomb"
			attackpower = 15
			sizereq = 4
			cost = 99999

		//Sumo
		dataslam
			name = "Dataslam"
			icon_state = "slam"
			attackpower = 8
			sizereq = 6

		//Boss
		shutdown
			name = "Shutdown"
			icon_state = "shutdown"
			attackpower = 5
			sizereq = 5

		New()
			..()
			desc = "Deletes [attackpower] sectors."

		use(var/obj/effect/cyberspace/target)
			if(!istype(target,/obj/effect/cyberspace/program)) return 0

			var/obj/effect/cyberspace/program/P = target
			var/dist = abs(P.cyberx - owner.cyberx) + abs(P.cybery - owner.cybery)

			if(dist <= distance && P != src)
				P.damage(attackpower)

			return 0

	//Obscure ones start here
	bit0
		name = "Zero"
		desc = "Deletes one grid square."
		icon_state = "bit0"
		var/distance = 1

		use(var/obj/effect/cyberspace/target)
			if(!istype(target,/obj/effect/cyberspace/sector)) return 0

			var/obj/effect/cyberspace/sector/S = target
			var/dist = abs(S.cyberx - owner.cyberx) + abs(S.cybery - owner.cybery)

			if(dist <= distance)
				S.destroy()
				return 1

			return 0

	bit1
		name = "One"
		desc = "Repairs one grid square."
		icon_state = "bit1"
		var/distance = 1

		use(var/obj/effect/cyberspace/target)
			if(!istype(target,/obj/effect/cyberspace/sector)) return 0

			var/obj/effect/cyberspace/sector/S = target
			var/dist = abs(S.cyberx - owner.cyberx) + abs(S.cybery - owner.cybery)

			if(dist <= distance)
				S.repair()
				return 1

			return 0

	fusion
		name = "Fusion"
		icon_state = "zap"
		var/distance = 1

		fusionbomb
			name = "Fusionbomb"
			icon_state = "fusionbomb"

		use(var/obj/effect/cyberspace/target)
			if(!istype(target,/obj/effect/cyberspace/program)) return 0

			var/obj/effect/cyberspace/program/P = target
			var/dist = abs(P.cyberx - owner.cyberx) + abs(P.cybery - owner.cybery)

			if(dist <= distance && P != src)
				P.maxlength = max(P.maxlength + owner.maxlength,1)
				owner.damage(99999)

			return 0

	sizechange
		name = "Sizechange"
		icon_state = "tweak"
		var/distance = 1
		var/sizepower = 0

		surgery
			name = "Surgery"
			icon_state = "hack"
			sizepower = 1

		twiddle
			name = "Twiddle"
			icon_state = "extend"
			sizepower = 1
			cost = 1

		stretch
			name = "Stretch"
			icon_state = "extend"
			sizepower = 1

	speedchange
		name = "Speedchange"
		icon_state = "clog"
		var/distance = 1
		var/speedpower = 0

		boost
			name = "Boost"
			icon_state = "boost"
			distance = 1
			speedpower = 1
			cost = 1

		megaboost
			name = "Megaboost"
			icon_state = "boost"
			distance = 3
			speedpower = 2
			sizereq = 3
			cost = 2

		tweak
			name = "Tweak"
			icon_state = "distill"
			speedpower = 1
			cost = 1

		lag
			name = "Lag"
			icon_state = "clog"
			distance = 3
			speedpower = -1

		chug
			name = "Chug"
			icon_state = "clog"
			distance = 3
			speedpower = -2

		hang //Completely stops the enemy program
			name = "Hang"
			icon_state = "clog"
			distance = 3
			speedpower = -99999
			sizereq = 4

		paralyze
			name = "Paralyze"
			icon_state = "shutdown"
			distance = 1
			speedpower = -3

		ice
			name = "Ice"
			icon_state = "freeze"
			distance = 2
			speedpower = -3

		use(var/obj/effect/cyberspace/target)
			if(!istype(target,/obj/effect/cyberspace/program)) return 0

			var/obj/effect/cyberspace/program/P = target
			var/dist = abs(P.cyberx - owner.cyberx) + abs(P.cybery - owner.cybery)

			if(dist <= distance && P != src)
				P.movespeed = max(P.movespeed - speedpower,0)

			return 0

	heal
		name = "Heal"
		desc = "Adds 1 sector to target"
		icon_state = "heal"
		var/healpower = 1
		var/distance = 1

		grow
			name = "Grow"
			desc = "Adds 2 sectors to target"
			icon_state = "heal"
			healpower = 2

		hypo
			name = "Hypo"
			desc = "Adds 2 sectors to target"
			icon_state = "inject"
			distance = 3
			healpower = 2

		megagrow
			name = "Megagrow"
			desc = "Adds 4 sectors to target"
			icon_state = "superheal"
			healpower = 4

		use(var/obj/effect/cyberspace/target)
			if(!istype(target,/obj/effect/cyberspace/program)) return 0

			var/obj/effect/cyberspace/program/P = target
			var/dist = abs(P.cyberx - owner.cyberx) + abs(P.cybery - owner.cybery)

			if(dist <= distance && P != src)
				P.grow(healpower)

			return 0

	install
		name = "Install"
		desc = "Installs one new program"
		icon_state = "install"
		var/list/possibleprograms = list(/obj/effect/cyberspace/program/sentinel1,
			/obj/effect/cyberspace/program/data_doctor,
			/obj/effect/cyberspace/program/bit_man)
		var/distance = 1

		use(var/obj/effect/cyberspace/target)
			if(!istype(target,/obj/effect/cyberspace/sector)) return 0

			var/obj/effect/cyberspace/sector/S = target
			var/dist = abs(S.cyberx - owner.cyberx) + abs(S.cybery - owner.cybery)

			if(dist <= distance)
				return S.install_proc(usr,possibleprograms)

			return 0

	bloat
		name = "Bloat"
		desc = "Adds 5 sectors to user"
		icon_state = "hog"
		var/healpower = 5

		use(var/obj/effect/cyberspace/target)
			owner.grow(healpower)
			return 1