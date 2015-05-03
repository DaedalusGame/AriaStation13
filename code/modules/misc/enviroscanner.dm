/obj/item/device/mining_scanner
	desc = "A scanner that checks surrounding rock for useful minerals; Requires you to wear mesons to function properly."
	name = "mining scanner"
	icon_state = "envscan0"
	item_state = "analyzer"
	w_class = 2.0
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/cooldown = 0
	var/list/radioactives = list()

	proc/scan_tile(var/turf/T)
		if(locate(/obj/machinery/artifact) in T)
			return "anomaly"
		else if(locate(/obj/structure/tachyum) in T)
			return "anomaly"
		else if(istype(T,/turf/simulated/mineral))
			var/turf/simulated/mineral/M = T

			if(istype(M,/turf/simulated/mineral/adamantine))
				return "anomaly"
			else if(istype(M,/turf/simulated/mineral/uranium))
				return "radio"
			else if(istype(M,/turf/simulated/mineral/clown))
				return "bio"
			else if(istype(M,/turf/simulated/mineral/plasma))
				return "explosive"
			else if(M.gasrock)
				return "bio"
			else if(M.gem)
				return "gem"
			else if(M.dense)
				return "dense"

			return "wall"
		else if(istype(T,/turf/simulated/floor/plating/airless/asteroid))
			if(locate(/obj/effect/plantvine) in T)
				return "bio"
			if(locate(/obj/effect/phazon) in T)
				return "radio"
			if(locate(/obj/effect/liquid/lava) in T)
				return "fire"
		else if(istype(T,/turf/simulated/floor/plating/airless/lava))
			return "fire"

		return null

	proc/scan_tile_color(var/turf/T)
		if(locate(/obj/machinery/artifact) in T)
			return "000000FF"
		else if(locate(/obj/structure/tachyum) in T)
			return "000000FF"
		else if(istype(T,/turf/simulated/mineral))
			var/turf/simulated/mineral/M = T

			if(istype(M,/turf/simulated/mineral/adamantine))
				return "000000FF"
			else if(istype(M,/turf/simulated/mineral/uranium))
				return "55FF00FF"
			else if(istype(M,/turf/simulated/mineral/clown))
				return "FF00FFFF"
			else if(istype(M,/turf/simulated/mineral/plasma))
				return "#FF22AAFF"
			else if(M.gem)
				return "#00FFFFFF"
			else if(M.dense)
				return "#000000FF"

			return "#00FF00FF"
		else if(istype(T,/turf/simulated/floor/plating/airless/asteroid))
			if(locate(/obj/effect/plantvine) in T)
				return "#1AFF00FF"
			else if(locate(/obj/effect/phazon) in T)
				return "#00FFFFFF"
			else if(locate(/obj/effect/liquid/lava) in T)
				return "#FF2200FF"
		else if(istype(T,/turf/simulated/floor/plating/airless/lava))
			return "#FF2200FF"

		return "#00000000"

	attack_self(mob/user)
		flick("envscan1",src)

		if(!user.client)
			return
		if(!cooldown)
			cooldown = 1
			spawn(40)
				cooldown = 0
			var/client/C = user.client
			var/list/L = list()
			var/turf/simulated/T
			for(T in range(7, user))
				if(scan_tile(T))
					L += T
			if(!L.len)
				user << "<span class='info'>[src] reports that nothing was detected nearby.</span>"
				return
			else
				for(T in L)
					var/turf/TT = get_turf(T)
					var/image/I = image('icons/effects/enviroment.dmi', loc = TT, icon_state = scan_tile(T), layer = 18)
					I.color = scan_tile_color(T)
					C.images += I
					spawn(30)
						if(C)
							C.images -= I

