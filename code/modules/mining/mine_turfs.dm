/**********************Mineral deposits**************************/

var/list/gasrock_chems = list("frostoil","lube","toxin","acid","pacid","thermite","mutagen","zombiepowder","xenomicrobes","condensedcapsaicin","blood","radium","fuel")

/turf/simulated/mineral //wall piece
	name = "Rock"
	icon = 'walls.dmi'
	icon_state = "rock"
	oxygen = 0
	nitrogen = 0
	opacity = 1
	density = 1
	blocks_air = 1
	temperature = TCMB
	var/mineralName = ""
	var/mineralAmt = 0
	var/spread = 0 //will the seam spread?
	var/spreadChance = 0 //the percentual chance of an ore spreading to the neighbouring tiles
	var/artifactChance = 0.3	//percent chance to spawn a xenoarchaelogical artifact
	var/gemChance = 10
	var/denseChance = 5
	var/dense = 0
	var/gem
	var/hasspread = 0

	var/gasrock = 0
	var/gasrockChance = 5


/turf/simulated/mineral/Del()
	return

/turf/simulated/mineral/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				src.mineralAmt -= 1 //some of the stuff gets blown up
				src.gets_drilled()
		if(1.0)
			src.mineralAmt -= 2 //some of the stuff gets blown up
			src.gets_drilled()
	return

/turf/simulated/mineral/New()
	spawn(4)
		if(src)

			var/turf/T
			if((istype(get_step(src, NORTH), /turf/simulated/floor)) || (istype(get_step(src, NORTH), /turf/space)) || (istype(get_step(src, NORTH), /turf/simulated/shuttle/floor)))
				T = get_step(src, NORTH)
				if (T)
					T.overlays += image('walls.dmi', "rock_side_s")
			if((istype(get_step(src, SOUTH), /turf/simulated/floor)) || (istype(get_step(src, SOUTH), /turf/space)) || (istype(get_step(src, SOUTH), /turf/simulated/shuttle/floor)))
				T = get_step(src, SOUTH)
				if (T)
					T.overlays += image('walls.dmi', "rock_side_n", layer=6)
			if((istype(get_step(src, EAST), /turf/simulated/floor)) || (istype(get_step(src, EAST), /turf/space)) || (istype(get_step(src, EAST), /turf/simulated/shuttle/floor)))
				T = get_step(src, EAST)
				if (T)
					T.overlays += image('walls.dmi', "rock_side_w", layer=6)
			if((istype(get_step(src, WEST), /turf/simulated/floor)) || (istype(get_step(src, WEST), /turf/space)) || (istype(get_step(src, WEST), /turf/simulated/shuttle/floor)))
				T = get_step(src, WEST)
				if (T)
					T.overlays += image('walls.dmi', "rock_side_e", layer=6)

	spawn(1)
		if (!src || !istype(src,/turf/simulated/mineral))
			return

		if (mineralName && mineralAmt && spread && spreadChance)
			if(prob(spreadChance))
				if(istype(get_step(src, SOUTH), /turf/simulated/mineral/random))
					var/turf/simulated/mineral/M = new src.type(get_step(src, SOUTH))
					if(istype(M))
						M.makedense(src.dense)
						M.gasrock = src.gasrock
			if(prob(spreadChance))
				if(istype(get_step(src, NORTH), /turf/simulated/mineral/random))
					var/turf/simulated/mineral/M = new src.type(get_step(src, NORTH))
					if(istype(M))
						M.makedense(dense)
						M.gasrock = src.gasrock
			if(prob(spreadChance))
				if(istype(get_step(src, WEST), /turf/simulated/mineral/random))
					var/turf/simulated/mineral/M = new src.type(get_step(src, WEST))
					if(istype(M))
						M.makedense(dense)
						M.gasrock = src.gasrock
			if(prob(spreadChance))
				if(istype(get_step(src, EAST), /turf/simulated/mineral/random))
					var/turf/simulated/mineral/M = new src.type(get_step(src, EAST))
					if(istype(M))
						M.makedense(dense)
						M.gasrock = src.gasrock

		hasspread = 1
	return

/turf/simulated/mineral/proc/chemexplode()
	var/location = get_turf(src)

	if(prob(100))
		var/datum/reagents/holder = new(100)
		holder.add_reagent(pick(gasrock_chems),rand(1,50))
		if(prob(20))
			holder.add_reagent(pick(gasrock_chems),rand(1,50))
		if(prob(10))
			holder.add_reagent(pick(gasrock_chems),rand(1,50))
		var/datum/effect/effect/system/chem_smoke_spread/S = new /datum/effect/effect/system/chem_smoke_spread
		S.attach(location)
		S.set_up(holder, 10, 0, location)
		playsound(location, 'smoke.ogg', 50, 1, -3)
		spawn(0)
			S.start()
			sleep(10)
			S.start()

/turf/simulated/mineral/proc/makedense(var/denseore)
	dense = denseore

	if(dense > 0)
		mineralAmt *= dense
		//world << "Made [src] at [x]|[y] dense [denseore]"

/turf/simulated/mineral/random
	icon_state = "burning"
	name = "Rock"
	var/mineralAmtList = list("Uranium" = 5, "Iron" = 5, "Diamond" = 5, "Gold" = 5, "Silver" = 5, "Plasma" = 5, "Coal" = 5, "Adamantine" = 5)
	var/mineralSpawnChanceList = list("Cave" = 15,"Lava" = 5,"Phazon" = 5,"Uranium" = 5, "Iron" = 50, "Diamond" = 1, "Gold" = 5, "Silver" = 5, "Plasma" = 25, "Coal" = 15, "Adamantine" =1)//Currently, Adamantine won't spawn as it has no uses. -Durandan
	var/mineralChance = 4  //means 10% chance of this plot changing to a mineral deposit

/turf/simulated/mineral/random/New()
	..()

	icon_state = "rock"

	if (prob(denseChance))
		makedense(rand(2,5))

	if (prob(mineralChance))
		var/mName = pickweight(mineralSpawnChanceList) //temp mineral name

		if (mName)
			var/tempdense = dense
			var/turf/simulated/mineral/M
			switch(mName)
				if("Uranium")
					M = new/turf/simulated/mineral/uranium(src)
				if("Iron")
					M = new/turf/simulated/mineral/iron(src)
				if("Diamond")
					M = new/turf/simulated/mineral/diamond(src)
				if("Gold")
					M = new/turf/simulated/mineral/gold(src)
				if("Silver")
					M = new/turf/simulated/mineral/silver(src)
				if("Plasma")
					M = new/turf/simulated/mineral/plasma(src)
				if("Archaeo")
					M = new/turf/simulated/mineral/archaeo(src)
				if("Coal")
					M = new/turf/simulated/mineral/coal(src)
				if("Cave")
					M = new/turf/simulated/mineral/cave(src)
				if("Lava")
					M = new/turf/simulated/mineral/lava(src)
				if("Phazon")
					M = new/turf/simulated/mineral/phazon(src)
				if("Adamantine")
					M = new/turf/simulated/mineral/adamantine(src)
			if(M)
				src = M
				if(istype(M))
					M.makedense(tempdense)
				M.levelupdate()
	else if (prob(artifactChance))
		//spawn a rare, xeno-arch artifact here
		new/obj/machinery/artifact(src)
	else if (prob(gemChance))
		if(prob(50))
			gem = "wealth"
		else if(prob(33))
			gem = "coronium"
		else if(prob(33))
			if(prob(50))
				gem = "meson"
			else
				gem = "thermal"
		else if(prob(50))
			gem = "megalith"
		else
			gem = "wealth"
	else if (prob(gasrockChance))
		gasrock = 1

	//icon_state = "rock"
	return

/turf/simulated/mineral/random/high_chance
	mineralChance = 25
	mineralSpawnChanceList = list("Uranium" = 10, "Iron" = 30, "Diamond" = 2, "Adamantine" = 2, "Gold" = 10, "Silver" = 10, "Plasma" = 25, "Coal" = 2)
	denseChance = 50
	gemChance = 50
	//icon_state = "burning"

/turf/simulated/mineral/random/Del()
	return

/turf/simulated/mineral/uranium
	name = "Uranium deposit"
	icon_state = "rock_Uranium"
	mineralName = "Uranium"
	mineralAmt = 5
	spreadChance = 10
	spread = 1

	New()
		..()

		spawn(2)
			ul_SetLuminosity(0,2,0)

	Del()
		ul_SetLuminosity(0,0,0)
		..()


/turf/simulated/mineral/iron
	name = "Iron deposit"
	icon_state = "rock_Iron"
	mineralName = "Iron"
	mineralAmt = 5
	spreadChance = 25
	spread = 1


/turf/simulated/mineral/diamond
	name = "Diamond deposit"
	icon_state = "rock_Diamond"
	mineralName = "Diamond"
	mineralAmt = 5
	spreadChance = 10
	spread = 1

/turf/simulated/mineral/adamantine
	name = "Adamantine deposit"
	icon_state = "rock_Adamantine"
	mineralName = "Adamantine"
	mineralAmt = 5
	spreadChance = 10
	spread = 1

/turf/simulated/mineral/gold
	name = "Gold deposit"
	icon_state = "rock_Gold"
	mineralName = "Gold"
	mineralAmt = 5
	spreadChance = 10
	spread = 1


/turf/simulated/mineral/silver
	name = "Silver deposit"
	icon_state = "rock_Silver"
	mineralName = "Silver"
	mineralAmt = 5
	spreadChance = 10
	spread = 1

/turf/simulated/mineral/plasma
	name = "Plasma deposit"
	icon_state = "rock_Plasma"
	mineralName = "Plasma"
	mineralAmt = 5
	spreadChance = 25
	spread = 1


/turf/simulated/mineral/archaeo
	name = "Strange rock formation"
	icon_state = "rock_Archaeo"
	mineralName = "Archaeo"
	mineralAmt = 3
	spreadChance = 25
	spread = 1

/turf/simulated/mineral/coal
	name = "Coal deposit"
	icon_state = "rock_Coal"
	mineralName = "Coal"
	mineralAmt = 5
	spreadChance = 25
	spread = 1

/turf/simulated/mineral/clown
	name = "Bananium deposit"
	icon_state = "rock_Clown"
	mineralName = "Clown"
	mineralAmt = 3
	spreadChance = 0
	spread = 0

/turf/simulated/mineral/cave
	name = "Cave"
	icon_state = "rock_Cave"
	mineralName = "Cave"
	mineralAmt = 5
	spreadChance = 30
	spread = 1

	New()
		..()
		spawn(0)
			while(1)
				sleep(7)
				if(hasspread)
					var/turf/simulated/floor/plating/airless/asteroid/M = new(src)
					if(M)
						M.levelupdate()
				break


/turf/simulated/mineral/lava
	name = "Lava deposit"
	icon_state = "rock_Lava"
	mineralName = "Lava"
	mineralAmt = 5
	spreadChance = 30
	spread = 1

	New()
		..()
		spawn(0)
			while(1)
				sleep(7)
				if(hasspread)
					var/turf/simulated/floor/plating/airless/lava/M = new(src)
					if(M)
						M.levelupdate()
					break

		//..()
		//spawn(2)


/turf/simulated/mineral/phazon
	name = "Phazon deposit"
	icon_state = "rock_Phazon"
	mineralName = "Phazon"
	mineralAmt = 5
	spreadChance = 30
	spread = 1

	New()
		..()
		spawn(0)
			while(1)
				sleep(7)
				if(hasspread)
					var/turf/simulated/floor/plating/airless/asteroid/M = new(src)
					new /obj/effect/phazon(M)
					if(M)
						M.levelupdate()
					break

		//..()
		//spawn(2)




/turf/simulated/mineral/ReplaceWithFloor()
	if(!icon_old) icon_old = icon_state
	var/turf/simulated/floor/plating/airless/asteroid/W
	var/old_dir = dir

	for(var/direction in cardinal)
		for(var/obj/effect/glowshroom/shroom in get_step(src,direction))
			if(!shroom.floor) //shrooms drop to the floor
				shroom.floor = 1
				shroom.icon_state = "glowshroomf"
				shroom.pixel_x = 0
				shroom.pixel_y = 0

	W = new /turf/simulated/floor/plating/airless/asteroid( locate(src.x, src.y, src.z) )
	W.dir = old_dir
	W.fullUpdateMineralOverlays()

	/*
	W.icon_old = old_icon
	if(old_icon) W.icon_state = old_icon
	*/
	W.opacity = 1
	W.ul_SetOpacity(0)
	//W.ul_Recalculate()
	W.levelupdate()
	return W


/turf/simulated/mineral/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/weapon/pickaxe))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return
/*
	if (istype(W, /obj/item/weapon/pickaxe/radius))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return
*/
//Watch your tabbing, microwave. --NEO

		if(istype(W, /obj/item/weapon/pickaxe/hand_pick) || istype(W, /obj/item/weapon/pickaxe/mini_pick))
			user << "\red You carefully start clearing away the rock."
			playsound(user, 'Genhit.ogg', 20, 1)

			if(do_after(user,W:digspeed * dense))
				user << "\blue You finish clearing away the rock."
				gets_drilled(1)
		else
			user << "\red You start picking."
			playsound(user, 'Genhit.ogg', 20, 1)

			if(do_after(user,W:digspeed * dense))
				user << "\blue You finish cutting into the rock."
				gets_drilled()

	else
		return attack_hand(user)
	return

/turf/simulated/mineral/proc/gets_drilled(var/delicate = 0)
	var/destroyed = 0
	if ((src.mineralName != "") && (src.mineralAmt > 0) && (src.mineralAmt < 11))
		var/i
		for (i=0;i<mineralAmt;i++)
			if (src.mineralName == "Uranium")
				new /obj/item/weapon/ore/uranium(src)
			if (src.mineralName == "Iron")
				new /obj/item/weapon/ore/iron(src)
			if (src.mineralName == "Gold")
				new /obj/item/weapon/ore/gold(src)
			if (src.mineralName == "Silver")
				new /obj/item/weapon/ore/silver(src)
			if (src.mineralName == "Plasma")
				new /obj/item/weapon/ore/plasma(src)
			if (src.mineralName == "Diamond")
				new /obj/item/weapon/ore/diamond(src)
			if (src.mineralName == "Coal")
				new /obj/item/weapon/ore/coal(src)
			if (src.mineralName == "Adamantine")
				new /obj/item/weapon/ore/adamantine(src)
			if (src.mineralName == "Archaeo")
				//spawn strange rocks here
				if(prob(10) || delicate)
					new /obj/item/weapon/ore/strangerock(src)
				else
					destroyed = 1
			if (src.mineralName == "Clown")
				new /obj/item/weapon/ore/clown(src)
	if (prob(src.artifactChance))
		//spawn a rare, xeno-archaelogical artifact here
		new /obj/machinery/artifact(src)
	if(gem)
		switch(gem)
			if("wealth")
				new /obj/item/weapon/ore/gem/wealth(src)
			if("coronium")
				new /obj/item/weapon/ore/gem/coronium(src)
			if("thermal")
				new /obj/item/weapon/ore/gem/thermal(src)
			if("meson")
				new /obj/item/weapon/ore/gem/meson(src)
			if("megalith")
				new /obj/item/weapon/ore/gem/megalith(src)
	if(gasrock)
		chemexplode()
	ReplaceWithFloor()
	if(destroyed)
		usr << "\red You destroy some of the rocks!"
	return

/*
/turf/simulated/mineral/proc/setRandomMinerals()
	var/s = pickweight(list("uranium" = 5, "iron" = 50, "gold" = 5, "silver" = 5, "plasma" = 50, "diamond" = 1))
	if (s)
		mineralName = s

	var/N = text2path("/turf/simulated/mineral/[s]")
	if (N)
		var/turf/simulated/mineral/M = new N
		src = M
		if (src.mineralName)
			mineralAmt = 5
	return*/


/**********************Asteroid**************************/

/turf/simulated/floor/plating/airless/asteroid //floor piece
	name = "Asteroid"
	icon = 'floors.dmi'
	icon_state = "asteroid"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	icon_plating = "asteroid"
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug

/turf/simulated/floor/plating/airless/asteroid/New()
	var/proper_name = name
	..()
	name = proper_name
	//if (prob(50))
	//	seedName = pick(list("1","2","3","4"))
	//	seedAmt = rand(1,4)
	if(prob(20))
		icon_state = "asteroid[rand(0,12)]"
	spawn(60)
		updateMineralOverlays()

/turf/simulated/floor/plating/airless/asteroid/ex_act(severity)
	return

/turf/simulated/floor/plating/airless/asteroid/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(!W || !user)
		return 0

	if ((istype(W, /obj/item/weapon/shovel)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug == 1)
			user << "\red This area has already been dug"
			return

		user << "\red You start digging."
		playsound(src.loc, 'rustle1.ogg', 50, 1) //russle sounds sounded better

		sleep(40)
		if ((user.loc == T && user.equipped() == W) && !dug)
			user << "\blue You dug a hole."
			gets_dug()
			dug = 1
			icon_plating = "asteroid_dug"
			icon_state = "asteroid_dug"
			return
		else
			return
	else
		..(W,user)
	if ((istype(W,/obj/item/weapon/pickaxe/drill)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug == 1)
			user << "\red This area has already been dug."
			return

		user << "\red You start digging."
		playsound(src.loc, 'rustle1.ogg', 50, 1) //russle sounds sounded better

		sleep(30)
		if ((user.loc == T && user.equipped() == W))
			user << "\blue You dug a hole."
			gets_dug()
			dug = 1
			icon_plating = "asteroid_dug"
			icon_state = "asteroid_dug"
			return
		else
			return
	else
		..(W,user)

	if ((istype(W,/obj/item/weapon/pickaxe/diamonddrill)) || (istype(W,/obj/item/weapon/pickaxe/borgdrill)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug == 1)
			user << "\red This area has already been dug."
			return

		user << "\red You start digging."
		playsound(src.loc, 'rustle1.ogg', 50, 1) //russle sounds sounded better

		sleep(0)
		if ((user.loc == T && user.equipped() == W))
			user << "\blue You dug a hole."
			gets_dug()
			dug = 1
			icon_plating = "asteroid_dug"
			icon_state = "asteroid_dug"
			return
		else
			return
	else
		..(W,user)

	return

/turf/simulated/floor/plating/airless/asteroid/proc/gets_dug()
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	return

/turf/simulated/floor/plating/airless/asteroid/proc/updateMineralOverlays()

	src.overlays = null

	if(istype(get_step(src, NORTH), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_n")
	if(istype(get_step(src, SOUTH), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_s", layer=6)
	if(istype(get_step(src, EAST), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_e", layer=6)
	if(istype(get_step(src, WEST), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_w", layer=6)


/turf/simulated/floor/plating/airless/asteroid/proc/fullUpdateMineralOverlays()
	var/turf/simulated/floor/plating/airless/asteroid/A
	if(istype(get_step(src, WEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, WEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, EAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, EAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTH), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTH)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHWEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHEAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHWEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHEAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTH), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTH)
		A.updateMineralOverlays()
	src.updateMineralOverlays()

//Lava stuff

/turf/simulated/floor/plating/airless/lava
	name = "Lava"
	icon = 'floors.dmi'
	icon_state = "lava"
	icon_plating = "lava"
	//oxygen = 0.01
	//nitrogen = 0.01
	temperature = 3000
	var/updatedelay = 10

/turf/simulated/floor/plating/airless/lava/New()
	var/proper_name = name
	..()
	name = proper_name

	spawn(2)
		dir = pick(NORTH,SOUTH,EAST,WEST)

		switch(pick(1,2,3))
			if(1)
				if(LuminosityRed != 11)
					ul_SetLuminosity(11,9,0)
			if(2)
				if(LuminosityRed != 8)
					ul_SetLuminosity(8,7,0)
			if(3)
				if(LuminosityRed != 5)
					ul_SetLuminosity(5,4,0)

		spawn(updatedelay)
			if(src)
				Life()

		updateMineralOverlays()

	spawn(60)
		updateMineralOverlays()

/turf/simulated/floor/plating/airless/lava/proc/Life()
	set background = 1

	while(1)
		hotspot_expose(700, 50, 1)

		Incinerate()
		//for(var/mob/living/carbon/human/M in loc)
		//	if(M)
		//		//M.apply_damage(30,BURN)
		//		LavaBurn(M,3000)
		//		M.updatehealth()

		for(var/mob/living/carbon/human/M in orange(4,src))
			if(prob(30))
				continue

			var/dist = get_dist(src,M)
			//var/raddmg = 2 / max(1,dist/2)
			LavaBurn(M,3000/dist)
			//M.apply_damage(raddmg,BURN)
			M.updatehealth()

		sleep(updatedelay)

/turf/simulated/floor/plating/airless/lava/proc/LavaBurn(var/mob/living/carbon/human/m,var/burntemp)
	var/datum/gas_mixture/env = new()
	env.copy_from(return_air())
	env.carbon_dioxide = 100
	env.temperature = burntemp
	env.update_values()

	m.handle_environment(env)

/turf/simulated/floor/plating/airless/lava/Entered(atom/movable/A as mob|obj)
	..()
	if(A)
		Incinerate()

/turf/simulated/floor/plating/airless/lava/proc/Incinerate()
	for(var/mob/living/M in src)
		if(M)
			M.apply_damage(100,BURN)
			M.updatehealth()
			if(M.getFireLoss() > 200)
				for(var/i=0, i<10, i++)
					new/obj/effect/decal/ash(src)
				del(M)

	for(var/obj/I in src)
		if(istype(I,/obj/item))
			new/obj/effect/decal/ash(src)
			del(I)

/turf/simulated/floor/plating/airless/lava/proc/Spread(var/spreadChance)
	if(prob(spreadChance))
		if(istype(get_step(src, SOUTH), /turf/simulated/mineral) || istype(get_step(src, SOUTH), /turf/simulated/floor/plating/airless/asteroid))
			new src.type(get_step(src, SOUTH))
	if(prob(spreadChance))
		if(istype(get_step(src, NORTH), /turf/simulated/mineral) || istype(get_step(src, NORTH), /turf/simulated/floor/plating/airless/asteroid))
			new src.type(get_step(src, NORTH))
	if(prob(spreadChance))
		if(istype(get_step(src, WEST), /turf/simulated/mineral) || istype(get_step(src, WEST), /turf/simulated/floor/plating/airless/asteroid))
			new src.type(get_step(src, WEST))
	if(prob(spreadChance))
		if(istype(get_step(src, EAST), /turf/simulated/mineral) || istype(get_step(src, EAST), /turf/simulated/floor/plating/airless/asteroid))
			new src.type(get_step(src, EAST))

/turf/simulated/floor/plating/airless/lava/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			src.Spread(30)
		if(1.0)
			src.Spread(50)
	return

/turf/simulated/floor/plating/airless/lava/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return

/turf/simulated/floor/plating/airless/lava/proc/updateMineralOverlays()

	src.overlays = null

	if(istype(get_step(src, NORTH), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_n")
	if(istype(get_step(src, SOUTH), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_s", layer=6)
	if(istype(get_step(src, EAST), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_e", layer=6)
	if(istype(get_step(src, WEST), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_w", layer=6)

/turf/simulated/floor/plating/airless/lava/proc/fullUpdateMineralOverlays()
	var/turf/simulated/floor/plating/airless/asteroid/A
	if(istype(get_step(src, WEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, WEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, EAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, EAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTH), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTH)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHWEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHEAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHWEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHEAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTH), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTH)
		A.updateMineralOverlays()
	src.updateMineralOverlays()