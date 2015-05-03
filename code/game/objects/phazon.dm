//separate dm since hydro is getting bloated already

/obj/effect/phazon
	name = "Phazon"
	anchored = 1
	opacity = 0
	density = 0
	icon = 'phazon.dmi'
	icon_state = "phazon0"
	blend_mode = 2
	layer = 2.1
	var/ore = 3
	var/spreadChance = 40
	var/delay = 240
	var/lifedelay = 40


/obj/effect/phazon/New()
	..()

	ore = rand(1,4)
	icon_state = "phazon[rand(0,15)]"

	var/obj/effect/phazon/p = locate(/obj/effect/phazon) in loc

	if(p && p != src)
		del(src)

	spawn(2) //allows the luminosity TO BE RANDOM
		ul_SetLuminosity(0,rand(0,3),rand(0,3))
		icon_update()
		spawn(delay)
			if(src)
				Spread()
		spawn(lifedelay)
			if(src)
				Life()



/obj/effect/phazon/Del()
	ul_SetLuminosity(0)
	..()

/obj/effect/phazon/proc/Spread()
	while(1)
		for(var/turf/t in orange(1,src))
			if(istype(t,/turf/simulated/floor))
				var/turf/simulated/floor/F = t
				if(!locate(/obj/effect/phazon,F))
					if(F.Enter(src))
						if(prob(spreadChance))
							new /obj/effect/phazon(F)
		icon_update()

		sleep(delay)

/obj/effect/phazon/proc/Life()
	set background = 1

	while(1)
		if(prob(10))
			icon_state = "phazon[rand(0,15)]"

		for(var/mob/living/carbon/M in loc)
			if(M)
				var/toxdamage = rand(3,5) // changed the name to toxdamage from toxloss to prevent further conflicts
				var/radiation = 5

				//M.radiation += 4
				//M.adjustToxLoss(rand(3,5))
				if(M.health <= 0)
					toxdamage = rand(8,10)
					//M.adjustToxLoss(rand(8,10))
				radiation = max(radiation - (radiation*(M.getarmor(null, "rad")/100)),0)
				toxdamage = max(toxdamage - (toxdamage*(M.getarmor(null, "rad")/100)),0)
				//M.apply_effect(rand(radiation), IRRADIATE)
				//M.apply_effect(toxdamage, TOX)
				M.radiation += radiation
				M.adjustToxLoss(toxdamage)

				if(prob(1) && M.radiation > 30 && M.health > 0)
					randmuti(M)
					if(prob(70))
						randmutb(M)
					else
						randmutg(M)
					domutcheck(M, null)
					updateappearance(M,M.dna.uni_identity)
				M.updatehealth()

		for(var/mob/living/carbon/M in orange(5,src))
			if(prob(60))
				continue

			var/dist = get_dist(src,M)
			var/raddmg = 5 / max(1,dist/2)
			raddmg = max(raddmg - (raddmg*(M.getarmor(null, "rad")/100)),0)
			M.radiation += raddmg
			M.updatehealth()

		sleep(lifedelay)

/obj/effect/phazon/proc/icon_update(ded=0)
	overlays = null

	//world << "Phazon Icon Update"

	for(var/turf/simulated/floor/F in orange(1,src))
		if(!locate(/obj/effect/phazon,F))
			var/tdir = get_dir(F,src)
			var/obj/effect/overlay = new/obj
			overlay.icon = 'phazon.dmi'
			overlay.layer = layer
			overlay.icon_state = "phazone[tdir]"
			overlay.pixel_x = ((tdir & 4) ? -32 : 0) + ((tdir & 8) ? 32 : 0)
			overlay.pixel_y = ((tdir & 1) ? -32 : 0) + ((tdir & 2) ? 32 : 0)
			overlays += overlay
			//world << "updating overlay... [overlay.pixel_x]|[overlay.pixel_y]|[overlay.icon_state]"


/obj/effect/phazon/proc/gets_drilled()
	for(var/i=0;i<ore;i++)
		new /obj/item/weapon/ore/phazon(src.loc)
	del(src)

/obj/effect/phazon/attackby(obj/item/weapon/W as obj, mob/user as mob)
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

		user << "\red You start picking."
		playsound(user, 'Genhit.ogg', 20, 1)

		if(do_after(user,W:digspeed))
			user << "\blue You finish mining the Phazon."
			gets_drilled()

	else
		return attack_hand(user)

/obj/effect/phazon/ex_act(severity)
	switch(severity)
		if(1.0)
			gets_drilled()
			return
		if(2.0)
			if (prob(50))
				gets_drilled()
				return
		if(3.0)
			if (prob(5))
				gets_drilled()
				return
		else
	return

/obj/item/weapon/ore/phazon
	name = "Phazon ore"
	icon_state = "Phazon"
	origin_tech = "biotech=5"
