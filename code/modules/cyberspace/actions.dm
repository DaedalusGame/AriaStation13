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
			if(!istype(target,/obj/effect/cyberspace/sector)) return 0

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

		thump
			name = "Thump"
			icon_state = "slam"
			attackpower = 3

		crash
			name = "Crash"
			icon_state = "slam"
			attackpower = 7

		byte
			name = "Byte"
			icon_state = "byte"
			attackpower = 2

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

		spot
			name = "Spot"
			icon_state = "zap"
			attackpower = 3
			distance = 3

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

		dice2 //better version for hack 3.0
			name = "Dice"
			icon_state = "bighack"
			attackpower = 4
			sizereq = 4

		bash
			name = "Bash"
			icon_state = "slam"
			attackpower = 5

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
				//S.delete()
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
				//S.repair()
				return 1

			return 0

	sizechange
		name = "Sizechange"
		icon_state = "tweak"
		var/distance = 1
		var/sizepower = 0

		surgery
			name = "Surgery"
			sizepower = 1

		twiddle
			name = "Twiddle"
			sizepower = 1
			cost = 1

		stretch
			name = "Stretch"
			sizepower = 1

		use(var/obj/effect/cyberspace/target)
			if(!istype(target,/obj/effect/cyberspace/program)) return 0

			var/obj/effect/cyberspace/program/P = target
			var/dist = abs(P.cyberx - owner.cyberx) + abs(P.cybery - owner.cybery)

			if(dist <= distance && P != src)
				P.maxlength = max(P.maxlength - sizepower,1)

			return 0

	speedchange
		name = "Speedchange"
		icon_state = "clog"
		var/distance = 1
		var/speedpower = 0

		boost
			name = "Boost"
			distance = 1
			speedpower = 1
			cost = 1

		megaboost
			name = "Megaboost"
			distance = 3
			speedpower = 2
			sizereq = 3
			cost = 2

		tweak
			name = "Tweak"
			speedpower = 1
			cost = 1

		lag
			name = "Lag"
			distance = 3
			speedpower = -1

		chug
			name = "Chug"
			distance = 3
			speedpower = -2

		hang //Completely stops the enemy program
			name = "Hang"
			distance = 3
			speedpower = -99999
			sizereq = 4

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

		grow
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
