// SPACE VINES
/obj/effect/plantvine
	name = "vines"
	desc = "the vines of a plant"
	icon = 'floorplant.dmi'
	icon_state = "Light1"
	anchored = 1
	density = 0
	pass_flags = PASSTABLE | PASSGRILLE
	var/health = 0
	var/dead = 0
	var/energy = 0 //The growthstage of the vine
	var/growthage = 0
	var/lastgrowth = 0
	var/obj/effect/plantvine_controller/master = null
	var/datum/seed/plant = null
	var/base_icon_state
	var/list/fruits = list()
	var/hidden = 0
	var/airpass = 1

	var/mouthstate = 0 //0 = no mouth, 1 = small biter, 2 = biterfield, 3 = maneater, 4 = supereater

	New()
		spawn(5)
			if(!plant)
				del(src)

			health = plant.endurance
			dead = 0

			var/turf/T = src.loc			// hide if turf is not intact
			if(T) hide(T.intact)
			update_icon()

		update_nearby_tiles(1)

		return

	Del()
		if(master)
			master.vines -= src
			master.growth_queue -= src

		update_nearby_tiles(1)

		..()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (!W || !user || !W.type) return
		switch(W.type)
			if(/obj/item/weapon/circular_saw) del src
			if(/obj/item/weapon/kitchen/utensil/knife) del src
			if(/obj/item/weapon/scalpel) del src
			if(/obj/item/weapon/twohanded/fireaxe) del src
			if(/obj/item/weapon/hatchet) del src
			if(/obj/item/weapon/melee/energy) del src

			//less effective weapons
			if(/obj/item/weapon/wirecutters)
				if(prob(25)) del src
			if(/obj/item/weapon/shard)
				if(prob(25)) del src

			else //weapons with subtypes
				if(istype(W, /obj/item/weapon/melee/energy/sword)) del src
				else if(istype(W, /obj/item/weapon/weldingtool))
					var/obj/item/weapon/weldingtool/WT = W
					if(WT.remove_fuel(0, user)) del src
			//TODO: add plant-b-gone
		..()

	attack_hand(mob/user as mob)
		for(var/mob/M in src.loc)
			if(M.buckled == src)
				if(prob(50))
					if(M == user)
						user << "\red You break free from the vines!"
					else
						user << "\red You rip away at the vines and free [M]!"
						M << "\red [user] frees you from the vines!"
					M.buckled = null
				else
					user << "\red You rip away at the vines..."
				break //only process one captured mob.

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	hide(var/intact)
		if(level == 1 && intact && istype(loc, /turf/simulated))
			hidden = 1
		update_icon()

	update_icon()
		var/icon/curricon

		switch(plant.plant_type)
			if(0)
				base_icon_state = "vine[energy]"
			if(1)
				if(!isturf(loc))
					base_icon_state = "traymold[energy]"
				else
					base_icon_state = "mold[energy]"
			if(4)
				if(!isturf(loc))
					base_icon_state = "grass[energy]"
				else
					base_icon_state = "vine[energy]"

		if(hidden)
			switch(plant.plant_type)
				if(1)
					alpha = 128
				else
					invisibility = 101

		else
			alpha = 255
			invisibility = 0

		//world << plant.colors

		for(var/colid in plant.colors)
			var/pcolor = plant.colors[colid]
			var/list/pcolorlist = ReadRGB(pcolor)

			var/icon/newicon = icon('floorplant.dmi',"[base_icon_state][colid]")

			if(!newicon) continue

			//world << "[base_icon_state][colid]"

			var/truer = pcolorlist[1]/255
			var/trueg = pcolorlist[2]/255
			var/trueb = pcolorlist[3]/255
			var/overstretch = 0.5

			newicon.MapColors(overstretch+truer,overstretch+trueg,overstretch+trueb, overstretch+truer,overstretch+trueg,overstretch+trueb, overstretch+truer,overstretch+trueg,overstretch+trueb, -overstretch,-overstretch,-overstretch)

			if(dead)
				newicon.Blend(plant.deadcolor,ICON_MULTIPLY)

			if(curricon)
				curricon.Blend(newicon,ICON_OVERLAY)
			else
				curricon = newicon

		if(mouthstate == 1)
			icon_addplantpart(curricon,"maw")
		if(mouthstate == 2 || mouthstate == 4)
			icon_addplantpart(curricon,"vinemaws")
		if(mouthstate == 3 || mouthstate == 4)
			icon_addplantpart(curricon,"face")

		icon = curricon

	proc/icon_addplantpart(var/icon/I,var/baseicon)
		var/icon/curricon = I

		if(!curricon) return null

		for(var/colid in plant.colors)
			var/pcolor = plant.colors[colid]
			var/list/pcolorlist = ReadRGB(pcolor)

			var/icon/newicon = icon('floorplant.dmi',"[baseicon][colid]")

			if(!newicon) continue

			//world << "[base_icon_state][colid]"

			var/truer = pcolorlist[1]/255
			var/trueg = pcolorlist[2]/255
			var/trueb = pcolorlist[3]/255
			var/overstretch = 0.5

			newicon.MapColors(overstretch+truer,overstretch+trueg,overstretch+trueb, overstretch+truer,overstretch+trueg,overstretch+trueb, overstretch+truer,overstretch+trueg,overstretch+trueb, -overstretch,-overstretch,-overstretch)

			if(dead)
				newicon.Blend(plant.deadcolor,ICON_MULTIPLY)

			curricon.Blend(newicon,ICON_OVERLAY)

		curricon.Blend(icon('floorplant.dmi',"[baseicon]"),ICON_OVERLAY)

		return curricon

	CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
		if(!airpass && !istype(mover))
			return 0
		return !density

	proc/update_nearby_tiles(need_rebuild)
		if(!air_master) return 0

		var/turf/simulated/source = loc
		var/turf/simulated/north = get_step(source,NORTH)
		var/turf/simulated/south = get_step(source,SOUTH)
		var/turf/simulated/east = get_step(source,EAST)
		var/turf/simulated/west = get_step(source,WEST)

		if(istype(source)) air_master.tiles_to_update += source
		if(istype(north)) air_master.tiles_to_update += north
		if(istype(south)) air_master.tiles_to_update += south
		if(istype(east)) air_master.tiles_to_update += east
		if(istype(west)) air_master.tiles_to_update += west

		return 1


/obj/effect/plantvine_controller
	var/list/obj/effect/spacevine/vines = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	var/datum/seed/plant = null
	var/defaultplant = "vine"
	var/volume = 1000 //It's too big
	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the spacevines' size to something less than 20 plots, it won't grow anymore.

	kudzu
		defaultplant = "kudzu"

	space
		defaultplant = "spaceweed"

	plasmapod
		defaultplant = "plasmapod"

	maneater
		defaultplant = "maneater"

	mold
		defaultplant = "mold"

		death
			defaultplant = "deathmold"

	New()
		//if(!istype(src.loc,/turf/simulated/floor))
		//	del(src)

		plant = plants[defaultplant]

		var/datum/reagents/R = new/datum/reagents(volume)
		reagents = R
		R.my_atom = src

		spawn(5)
			spawn_spacevine_piece(src.loc)
			processing_objects.Add(src)

	Del()
		processing_objects.Remove(src)
		..()

	proc/spawn_spacevine_piece(var/turf/location)
		var/obj/effect/plantvine/SV = new(location)
		growth_queue += SV
		vines += SV
		SV.master = src
		SV.plant = plant

	proc/get_tray()
		if(istype(loc,/obj/machinery/hydrotray))
			return loc

	proc/mutate()
		if(!plant) return

		var/muttype = pickweight(plant.possiblemutations)
		var/datum/plantmutation/mut = new muttype()
		plant = plant.mutate(mut)

	process()
		if(!vines.len)
			del(src) //space  vines exterminated. Remove the controller
			return
		if(!growth_queue)
			del(src) //Sanity check
			return
		if(vines.len >= plant.collapsesize && !reached_collapse_size)
			reached_collapse_size = 1
		if(vines.len >= plant.slowdownsize && !reached_slowdown_size )
			reached_slowdown_size = 1

		var/length = 0
		if(reached_collapse_size)
			length = 0
		else if(reached_slowdown_size)
			if(prob(25))
				length = 1
			else
				length = 0
		else
			length = min( plant.slowdownsize , max( length , vines.len / 5 ) )

		var/i = 0
		var/list/obj/effect/plantvine/queue_end = list()

		for( var/obj/effect/plantvine/SV in growth_queue )
			queue_end += SV
			growth_queue -= SV

			SV.life()

			//if(SV.lastgrowth + SV.plant.growthtime > world.time)
			//	continue

			if(!SV.dead)
				SV.grow()
				SV.spread()

			i++

			if(i >= length)
				break

		growth_queue = growth_queue + queue_end
		//sleep(5)
		//src.process()

/obj/effect/plantvine/proc/mutate()
	if(!master) return

	master.mutate()

/obj/effect/plantvine/proc/grow()
	if(!master) return

	lastgrowth = world.time
	plant = master.plant

	growthage += rand(1,5)

	if(plant.nutrientlevel >= 5)
		growthage += rand(1,5)

	var/maxstage = 1
	var/dense = 0

	if(plant.hasmutation(/datum/plantmutation/dense/super/hyper))
		dense = 3
	else if(plant.hasmutation(/datum/plantmutation/dense/super))
		dense = 2
	else if(plant.hasmutation(/datum/plantmutation/dense))
		dense = 1

	if(dense)
		maxstage = 2

	energy = min(maxstage,round((growthage / plant.maturation) * maxstage))

	switch(energy)
		if(0)
			density = 0
			opacity = 0
			layer = 2.7
		if(1)
			density = 0
			opacity = 0
			layer = 3
		if(2)
			//Airpass
			if(dense >= 3 && airpass)
				airpass = 0
				update_nearby_tiles(1)
			else if(!airpass)
				airpass = 1
				update_nearby_tiles(1)

			//No objects pass
			if(dense >= 2)
				density = 1
			else
				density = 0

			//Opacity
			if(dense)
				opacity = 1
			layer = 5

	if(growthage >= plant.maturation)
		var/datum/plantmutation/carnivore/biter/bitemut = locate(/datum/plantmutation/carnivore/biter) in plant.mutations

		if(bitemut)
			if(mouthstate < bitemut.maxmouth && prob(10))
				mouthstate++
			if(mouthstate > bitemut.maxmouth && prob(20))
				mouthstate--

		//Make fruit
		if(fruits.len < plant.yield)
			var/obj/fruit = plant.producefruit(get_turf(src))
			if(fruit)
				fruit:set_vine(src)

		for(var/obj/fruit in fruits)
			fruit:growthsize += 0.01
			fruit:growthsize = min(plant.size,fruit:growthsize)
			if(fruit.reagents)
				fruit.reagents.maximum_volume = fruit:volume * fruit:growthsize
			fruit.update_icon()

	//if(!energy)
		//src.icon_state = pick("Med1", "Med2", "Med3")
		//energy = 1
		//src.opacity = 1
		//layer = 5
	//else
		//src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		//energy = 2

/obj/effect/plantvine/proc/grab(var/grabdead)
	for(var/mob/living/carbon/V in src.loc)
		if((grabdead || V.stat != DEAD) && (V.buckled != src)) //if mob not dead or captured
			V.buckled = src
			V << "\red The vines [pick("wind", "tangle")] around you!"
			break //only capture one mob at a time.

/obj/effect/plantvine/proc/spread()
	if(!prob(plant.spreadspeed))
		return

	var/obj/machinery/hydrotray/plantedtray = get_tray()

	var/turf/currentpos = get_turf(src)
	var/direction = pick(cardinal)
	var/step = get_step(currentpos,direction)

	if(!isturf(loc))
		step = get_turf(src)

	if(istype(step,/turf/simulated/floor))
		var/turf/simulated/floor/F = step

		if(plant.requireslattice)
			if((loc == plantedtray && !plantedtray.lattice) || !locate(/obj/structure/grille,F))
				return

		if(!locate(/obj/effect/plantvine,F))
			if(F.Enter(src))
				if(master)
					master.spawn_spacevine_piece( F )

/obj/effect/plantvine/proc/bite(var/mob/living/carbon/human/M)
	//stolen from holographic boxing gloves code
	//This should probably be done BY the mob, however, the attack code will be expecting a source mob.
	if(!mouthstate) return

	var/turf/tloc = get_turf(src)

	var/damage
	if(prob(50))
		damage = rand(0, 2 ** mouthstate) // pap
	else
		damage = rand(0, 4 ** mouthstate) // thwack FUCK IT THIS REALLY HURTS

	if(!damage)
		playsound(tloc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		tloc.visible_message("\red \The [src] lunged at [M], but whiffed!")
		return
	var/datum/organ/external/affecting = M.get_organ(ran_zone("chest",50))
	var/armor_block = M.run_armor_check(affecting, "melee")

	playsound(tloc, "sound/items/eatfood", 25, 1, -1)
	src.visible_message("\red <B>\The [src] has bitten [M]!</B>")

	M.apply_damage(damage, BRUTE,   affecting, armor_block) // Foul!  Foooul!

	if(damage >= 9)
		src.visible_message("\red <B>\The [src] has weakened [M]!</B>")
		M.apply_effect(4, WEAKEN, armor_block)

/obj/effect/plantvine/proc/devour()
	//stolen from holographic boxing gloves code
	//This should probably be done BY the mob, however, the attack code will be expecting a source mob.
	if(mouthstate < 2) return

	var/turf/tloc = get_turf(src)

	grab(1)

	for(var/mob/living/carbon/V in src.loc)
		if(V.stat == DEAD && V.buckled == src) //if mob dead and captured
			playsound(tloc, "sound/items/eatfood", 25, 1, -1)
			tloc.visible_message("\red \The [src] is starting to devour [V]!")
			spawn(100) devour_finish(V)

/obj/effect/plantvine/proc/devour_finish(var/mob/living/carbon/human/M)
	if(!src || !M) return
	if(M.stat != DEAD || M.buckled != src || !mouthstate || dead) return

	var/turf/tloc = get_turf(src)

	tloc.visible_message("\red \The [src] has devoured [M]!")
	M.gib()
	plant.evopoints++

/obj/effect/plantvine/proc/lash(var/mob/living/carbon/human/M,var/maxpunches = 1)
	//stolen from holographic boxing gloves code
	//This should probably be done BY the mob, however, the attack code will be expecting a source mob.

	if(!M)
		for(var/mob/living/carbon/V in range(src.loc,1))
			if(V.stat != DEAD) //if mob not dead or captured
				lash(V,maxpunches)

	var/turf/tloc = get_turf(src)

	var/damage
	if(prob(75))
		damage = rand(0, 6) // pap
	else
		damage = rand(0, 12) // thwack

	if(!damage)
		playsound(tloc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		src.visible_message("\red \The [src] lashed at [M], but whiffed!")

		if(maxpunches > 1 && prob(50)) // Follow through on a miss, 50% chance
			return lash(M,maxpunches - 1) + 1
		return 1
	var/datum/organ/external/affecting = M.get_organ(ran_zone("chest",50))
	var/armor_block = M.run_armor_check(affecting, "melee")

	playsound(tloc, "punch", 25, 1, -1)
	src.visible_message("\red <B>\The [src] has lashed [M]!</B>")

	M.apply_damage(damage, BRUTE,   affecting, armor_block) // Foul!  Foooul!

	if(damage >= 9)
		src.visible_message("\red <B>\The [src] has weakened [M]!</B>")
		M.apply_effect(4, WEAKEN, armor_block)
		return maxpunches // The machine is not so sophisticated as to not gloat
	else
		if(prob(25)) // Follow through on a hit, 25% chance.  Pause after.
			return lash(M,maxpunches-1) + 1
	return 1

/obj/effect/plantvine/proc/get_tray()
	if(master)
		return master.get_tray()

	return null

/obj/effect/plantvine/proc/can_harvest()
	if (!src) return 0

	for(var/obj/fruit in fruits)
		if(fruit:growthsize >= plant.size)
			return 1

	return 0

/obj/effect/plantvine/proc/life()
	if (!src) return

	plant.life(src)

	if(health <= 0)
		health = 0
		dead = 1

	update_icon()
/*
/obj/effect/spacevine/proc/Life()
	if (!src) return
	var/Vspread
	if (prob(50)) Vspread = locate(src.x + rand(-1,1),src.y,src.z)
	else Vspread = locate(src.x,src.y + rand(-1, 1),src.z)
	var/dogrowth = 1
	if (!istype(Vspread, /turf/simulated/floor)) dogrowth = 0
	for(var/obj/O in Vspread)
		if (istype(O, /obj/structure/window) || istype(O, /obj/effect/forcefield) || istype(O, /obj/effect/blob) || istype(O, /obj/effect/alien/weeds) || istype(O, /obj/effect/spacevine)) dogrowth = 0
		if (istype(O, /obj/machinery/door/))
			if(O:p_open == 0 && prob(50)) O:open()
			else dogrowth = 0
	if (dogrowth == 1)
		var/obj/effect/spacevine/B = new /obj/effect/spacevine(Vspread)
		B.icon_state = pick("vine-light1", "vine-light2", "vine-light3")
		spawn(20)
			if(B)
				B.Life()
	src.growth += 1
	if (src.growth == 10)
		src.name = "Thick Space Kudzu"
		src.icon_state = pick("vine-med1", "vine-med2", "vine-med3")
		src.opacity = 1
		src.waittime = 80
	if (src.growth == 20)
		src.name = "Dense Space Kudzu"
		src.icon_state = pick("vine-hvy1", "vine-hvy2", "vine-hvy3")
		src.density = 1
	spawn(src.waittime)
		if (src.growth < 20) src.Life()

*/

/obj/effect/plantvine/ex_act(severity)
	//plant.ex_act(src,severity)
	return

/obj/effect/plantvine/temperature_expose(null, temp, volume) //hotspots kill vines
	//plant.temp_act(src,temp,volume)
