/obj/machinery/hydrotray
	name = "hydroponics tray"
	icon = 'growing.dmi'
	icon_state = "tray"
	flags = FPRINT | CONDUCT | OPENCONTAINER
	density = 1
	anchored = 1
	var/waterlevel = 100 // The amount of water in the tray (max 100)
	var/nutrilevel = 10 // The amount of nutrient in the tray (max 10)
	var/pestlevel = 0 // The amount of pests in the tray (max 10)
	var/weedlevel = 0 // The amount of weeds in the tray (max 10)
	var/yieldmod = 1 //Modifier to yield
	var/mutmod = 1 //Modifier to mutation chance

	var/lastcycle = 0 //Used for timing of cycles.
	var/cycledelay = 1000 // About 50 seconds / cycle
	var/obj/effect/plantvine_controller/plant = null //The actual plant

	var/covered = 0
	var/lattice = 0

	var/volume = 1000 //Yeah, it's kinda massive.

	New()
		var/datum/reagents/R = new/datum/reagents(volume)
		reagents = R
		R.my_atom = src

		..()


	bullet_act(var/obj/item/projectile/Proj) //Works with the Somatoray to modify plant variables.
		if(istype(Proj ,/obj/item/projectile/energy/floramut))
			if(src.plant)
				src.mutate()
		else if(istype(Proj ,/obj/item/projectile/energy/florayield))
			if(src.plant && src.plant.plant.yield < 2)
				src.plant.plant.yield += 1

/obj/machinery/hydrotray/process()
	var/obj/effect/plantvine/vine = locate(/obj/effect/plantvine) in src

	if(world.time > (src.lastcycle + src.cycledelay))
		src.lastcycle = world.time
		if(vine && !vine.dead)
			// Advance age
			//vine.life()

			if(prob(5))  // On each tick, there's a 5 percent chance the pest population will increase
				src.pestlevel += 1
			if(prob(5))  // On each tick, there's a 5 percent chance the weed
				src.weedlevel += 1					//population will increase, but there needs to be water/nuts for that!
		else
			if(prob(10))  // If there's no plant, the percentage chance is 10%
				src.weedlevel += 1

		// These (v) wouldn't be necessary if additional checks were made earlier (^)

		if (src.weedlevel > 10) // Make sure it won't go overoboard
			src.weedlevel = 10
		if (src.pestlevel > 10 ) // Make sure it won't go overoboard
			src.pestlevel = 10

		// Weeeeeeeeeeeeeeedddssss

		//TODO: Weeds

	if(anchored)
		var/obj/machinery/liquidport/P = locate(/obj/machinery/liquidport) in loc
		if(P)
			P.valve = (reagents.total_volume < volume / 2)

	src.updateicon()
	return

obj/machinery/hydrotray/proc/get_vine()
	return locate(/obj/effect/plantvine) in src

obj/machinery/hydrotray/proc/plant(var/datum/seed/S)
	plant = new(src)
	plant.plant = S.copy()
	updateicon()

//obj/machinery/hydrotray/proc/harvest(var/atom/user)
//	if(!plant) return
//
//	plant.harvest(user)

obj/machinery/hydrotray/proc/mutate(var/atom/user)
	if(!plant) return

	plant.mutate()

obj/machinery/hydrotray/proc/updateicon()
	//Refreshes the icon and sets the luminosity
	overlays.Cut()

	var/obj/effect/plantvine/vine = get_vine()

	var/reagentratio = reagents.total_volume / volume
	var/reagentstate = round(min(3,4 * reagentratio))

	overlays += getChemIcon(icon(icon,"trayfill[reagentstate]"),reagents)

	if(vine)
		//if(src.waterlevel <= 10)
		//	overlays += image('hydroponics.dmi', icon_state="over_lowwater3")
		//if(src.nutrilevel <= 2)
		//	overlays += image('hydroponics.dmi', icon_state="over_lownutri3")
		if(vine.health <= (vine.plant.endurance / 2))
			overlays += image(icon, icon_state="trayhealth")
		if(src.weedlevel >= 5)
			overlays += image(icon, icon_state="trayalert")
		if(src.pestlevel >= 5)
			overlays += image(icon, icon_state="trayalert")
		//if(src.toxic >= 40)
		//	overlays += image(icon, icon_state="over_alert3")
		if(vine.can_harvest())
			overlays += image(icon, icon_state="trayharvest")

	if(lattice)
		overlays += icon(icon,"traygrill")

	if(vine)
		var/growthstage = min(4,round((vine.growthage / vine.plant.maturation) * 4))

		var/icon/planticon = icon(vine.icon)
		planticon.Blend(icon(icon,"growthmask[growthstage]"),ICON_MULTIPLY)
		if(covered)
			planticon.Blend(planticon,icon(icon,"traycovermask"),ICON_MULTIPLY)

		overlays += planticon
		//if(plant.dead)
		//	overlays += image('hydroponics.dmi', icon_state="[src.plant.species]-dead")
		/*else if(src.harvest)
			if(src.myseed.plant_type == 2) // Shrooms don't have a -harvest graphic
				overlays += image('hydroponics.dmi', icon_state="[src.plant.species]-grow[src.myseed.growthstages]")
			else
				overlays += image('hydroponics.dmi', icon_state="[src.plant.species]-harvest")
		else if(src.age < src.myseed.maturation)
			var/t_growthstate = ((src.age / src.myseed.maturation) * src.myseed.growthstages ) // Make sure it won't crap out due to HERPDERP 6 stages only
			overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow[round(t_growthstate)]")
			src.lastproduce = src.age //Cheating by putting this here, it means that it isn't instantly ready to harvest
		else
			overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow[src.myseed.growthstages]") // Same

		if(src.waterlevel <= 10)
			overlays += image('hydroponics.dmi', icon_state="over_lowwater3")
		if(src.nutrilevel <= 2)
			overlays += image('hydroponics.dmi', icon_state="over_lownutri3")
		if(src.health <= (src.myseed.endurance / 2))
			overlays += image('hydroponics.dmi', icon_state="over_lowhealth3")
		if(src.weedlevel >= 5)
			overlays += image('hydroponics.dmi', icon_state="over_alert3")
		if(src.pestlevel >= 5)
			overlays += image('hydroponics.dmi', icon_state="over_alert3")
		if(src.toxic >= 40)
			overlays += image('hydroponics.dmi', icon_state="over_alert3")
		if(src.harvest)
			overlays += image('hydroponics.dmi', icon_state="over_harvest3")*/

	/*if(myseed)
		if(luminosity && !istype(myseed,/obj/item/seeds/glowshroom)) //revert luminosity to 0
			ul_SetLuminosity(0)
		else if(!luminosity && istype(myseed,/obj/item/seeds/glowshroom)) //update luminosity
			ul_SetLuminosity(myseed.potency/10)
	else
		if(luminosity)
			ul_SetLuminosity(0)*/

	if(covered)
		overlays += icon(icon,"traycover")

	return


obj/machinery/hydrotray/attackby(var/obj/item/O as obj, var/mob/user as mob)

	//Called when mob user "attacks" it with object O
	/*if (istype(O, /obj/item/weapon/reagent_containers/glass/bucket))
		var/b_amount = O.reagents.get_reagent_amount("water")
		if(b_amount > 0 && src.waterlevel < 100)
			if(b_amount + src.waterlevel > 100)
				b_amount = 100 - src.waterlevel
			O.reagents.remove_reagent("water", b_amount)
			src.waterlevel += b_amount
			playsound(src.loc, 'slosh.ogg', 25, 1)
			user << "You fill the [src] with [b_amount] units of water."

		else if(src.waterlevel >= 100)
			user << "\red \The [src] is already full."
		else
			user << "\red \The [src] is not filled with water."
		src.updateicon()

	else if ( istype(O, /obj/item/nutrient) )
		var/obj/item/nutrient/myNut = O
		user.u_equip(O)
		src.nutrilevel = 10
		src.yieldmod = myNut.yieldmod
		src.mutmod = myNut.mutmod
		user << "You replace the nutrient solution in the [src]."
		del(O)
		src.updateicon()

	else*/ if ( istype(O, /obj/item/seed/) )
		var/obj/item/seed/SO = O

		if(!src.plant)
			user << "You plant the [O.name]"
			world << SO
			plant(SO.internal)
			//src.plant = SO.internal.copy()
			src.lastcycle = world.time
			//if((user.client  && user.s_active != src))
			//	user.client.screen -= O //Why the fuck is this even here, you're unequipping it, manually changing the screen AND dropping it
			SO.seedamt--
			if(SO.seedamt <= 0)
				user.u_equip(O)
				O.dropped(user)
				del(O)
			src.updateicon()

		else
			user << "\red The [src] already has seeds in it!"

	else if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		//TODO: Get plant data from seed

	else if (istype(O, /obj/item/weapon/plantbgone))
		//TODO: kill plants.

	else if (istype(O, /obj/item/weapon/minihoe))  // The minihoe
		//TODO: unweed

	else if ( istype(O, /obj/item/weapon/weedspray) )
		//TODO: unweed

	else if ( istype(O, /obj/item/weapon/pestspray) )
		//TODO: unpest

	else if(istype(O, /obj/item/weapon/wrench))
		playsound(loc, 'Ratchet.ogg', 50, 1)
		anchored = !anchored
		user << "You [anchored ? "wrench" : "unwrench"] \the [src]."
	else if(istype(O, /obj/item/weapon/shovel))
		if(istype(src, /obj/machinery/hydrotray/soil))
			user << "You clear up the [src]!"
			del(src)
	return


/obj/machinery/hydrotray/attack_hand(mob/user as mob)
	if(istype(usr,/mob/living/silicon))		//How does AI know what plant is?
		return

	var/obj/effect/plantvine/vine = get_vine()

	//if(plant.canharvest)
	//	if(!user in range(1,src))
		//	return
		//harvest(user)
		//src.updateicon()
	/*else*/ if(vine && vine.dead)
		plant = null
		usr << text("You remove the dead plant from the [src].")
		src.updateicon()
	/*else
		if(src.planted && !src.dead)
			usr << text("The [src] has \blue [src.myseed.plantname] \black planted.")
			if(src.health <= (src.myseed.endurance / 2))
				usr << text("The plant looks unhealthy")
		else
			usr << text("The [src] is empty.")
		usr << text("Water: [src.waterlevel]/100")
		usr << text("Nutrient: [src.nutrilevel]/10")
		if(src.weedlevel >= 5) // Visual aid for those blind
			usr << text("The [src] is filled with weeds!")
		if(src.pestlevel >= 5) // Visual aid for those blind
			usr << text("The [src] is filled with tiny worms!")
		usr << text ("") // Empty line for readability.
		*/

/*/obj/item/seeds/proc/harvest(mob/user = usr)
	var/produce = text2path(productname)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while ( t_amount < (yield * parent.yieldmod ))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/t_prod = new produce(user.loc, potency) // User gets a consumable
		if(!t_prod)	return
		t_prod.seed = mypath
		t_prod.species = species
		t_prod.lifespan = lifespan
		t_prod.endurance = endurance
		t_prod.maturation = maturation
		t_prod.production = production
		t_prod.yield = yield
		t_prod.potency = potency
		t_prod.plant_type = plant_type
		t_amount++

	parent.update_tray()*/

/*/obj/item/seeds/replicapod/harvest(mob/user = usr) //now that one is fun -- Urist
	var/obj/machinery/hydroponics/parent = loc

	if(ckey && config.revival_pod_plants) //if there's human data stored in it, make a human
		var/mob/ghost = find_dead_player("[ckey]")

		var/mob/living/carbon/human/podman = new /mob/living/carbon/human(parent.loc)
		if(ghost)
			ghost.client.mob = podman

		if (realName)
			podman.real_name = realName
			podman.original_name = realName	//don't want a random ghost name if we die again
		else
			podman.real_name = "pod person"  //No null names!!

		if(mind && istype(mind,/datum/mind) && mind.current && mind.current.stat == 2) //only transfer dead people's minds
			mind:transfer_to(podman)
			mind:original = podman
		else //welp
			podman.mind = new /datum/mind(  )
			podman.mind.key = podman.key
			podman.mind.current = podman
			podman.mind.original = podman
			podman.mind.transfer_to(podman)
			ticker.minds += podman.mind

			// -- Mode/mind specific stuff goes here
		switch(ticker.mode.name)
			if ("revolution")
				if (podman.mind in ticker.mode:revolutionaries)
					ticker.mode:add_revolutionary(podman.mind)
					ticker.mode:update_all_rev_icons() //So the icon actually appears
				if (podman.mind in ticker.mode:head_revolutionaries)
					ticker.mode:update_all_rev_icons()
			if ("nuclear emergency")
				if (podman.mind in ticker.mode:syndicates)
					ticker.mode:update_all_synd_icons()
			if ("cult")
				if (podman.mind in ticker.mode:cult)
					ticker.mode:add_cultist(podman.mind)
					ticker.mode:update_all_cult_icons() //So the icon actually appears
			if ("changeling")
				if (podman.mind in ticker.mode:changelings)
					podman.make_changeling()

			// -- End mode specific stuff

		if(ghost)
			if (istype(ghost, /mob/dead/observer))
				del(ghost) //Don't leave ghosts everywhere!!

		podman.gender = gender

		if (!podman.dna)
			podman.dna = new /datum/dna(  )
		if (ui)
			podman.dna.uni_identity = ui
			updateappearance(podman, ui)
		if (se)
			podman.dna.struc_enzymes = se
		podman:update_face()
		podman:update_body()

		if(!prob(potency)) //if it fails, plantman!
			podman.mutantrace = "plant"

	else //else, one packet of seeds. maybe two
		var/seed_count = 1
		if(prob(yield * parent.yieldmod * 20))
			seed_count++
		for(var/i=0,i<seed_count,i++)
			var/obj/item/seeds/replicapod/harvestseeds = new /obj/item/seeds/replicapod(user.loc)
			harvestseeds.lifespan = lifespan
			harvestseeds.endurance = endurance
			harvestseeds.maturation = maturation
			harvestseeds.production = production
			harvestseeds.yield = yield
			harvestseeds.potency = potency

	parent.update_tray()

/obj/item/seeds/replicapod/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers))

		user << "You inject the contents of the syringe into the seeds."

		for(var/datum/reagent/blood/bloodSample in W:reagents.reagent_list)
			var/mob/living/carbon/human/source = bloodSample.data["donor"] //hacky, since it gets the CURRENT condition of the mob, not how it was when the blood sample was taken
			if (!istype(source))
				continue
			//ui = bloodSample.data["blood_dna"] doesn't work for whatever reason
			ui = source.dna.uni_identity
			se = source.dna.struc_enzymes
			if(source.ckey)
				ckey = source.ckey
			else if(source.mind)
				ckey = ckey(source.mind.key)
			realName = source.real_name
			gender = source.gender

			if (!isnull(source.mind))
				mind = source.mind

		W:reagents.clear_reagents()
	else
		return ..()*/

/*/obj/machinery/hydrotray/proc/update_tray(mob/user = usr)
	//harvest = 0
	lastproduce = src.age
	if((yieldmod * myseed.yield) <= 0)
		user << text("\red You fail to harvest anything useful.")
	else
		user << text("You harvest from the [src.myseed.plantname]")
	if(myseed.oneharvest)
		del(myseed)
		planted = 0
		dead = 0
	updateicon()*/

///////////////////////////////////////////////////////////////////////////////

/obj/machinery/hydrotray/soil //Not actually hydroponics at all! Honk!
	name = "soil"
	icon = 'hydroponics.dmi'
	icon_state = "soil"
	density = 0
	New()
		..()

	updateicon() // Same as normal but with the overlays removed - Cheridan.
		overlays = null
		/*if(src.planted)
			if(dead)
				overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-dead")
			else if(src.harvest)
				if(src.myseed.plant_type == 2) // Shrooms don't have a -harvest graphic
					overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow[src.myseed.growthstages]")
				else
					overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-harvest")
			else if(src.age < src.myseed.maturation)
				var/t_growthstate = ((src.age / src.myseed.maturation) * src.myseed.growthstages )
				overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow[round(t_growthstate)]")
				src.lastproduce = src.age
			else
				overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow[src.myseed.growthstages]")

		if(myseed)
			if(luminosity && !istype(myseed,/obj/item/seeds/glowshroom))
				ul_SetLuminosity(0)
			else if(!luminosity && istype(myseed,/obj/item/seeds/glowshroom))
				ul_SetLuminosity(myseed.potency/10)
		else
			if(luminosity)
				ul_SetLuminosity(0)*/
		return