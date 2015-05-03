

/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "densecrate"
	density = 1
	flags = FPRINT

/obj/structure/largecrate/extreme
	name = "superdense crate"
	desc = "A hefty crate made from a plasteel-tungsten alloy."
	icon = 'icons/obj/storage.dmi'
	icon_state = "extremecrate"
	density = 1
	flags = FPRINT

/obj/structure/largecrate/attack_hand(mob/user as mob)
	return

/obj/structure/largecrate/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/crowbar))
		user << "The plating on this crate is too hard to pry off."
	else if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		user.visible_message("<span class='notice'>[user] wrenches \the [src] [anchored ? "to" : "from"] the floor.</span>", \
							 "<span class='notice'>You wrench \the [src] [anchored ? "to" : "from"] the floor.</span>", \
							 "<span class='notice'>You hear a wrenching sound.</span>")
	else
		return attack_hand(user)

/obj/structure/largecrate/mule
	icon_state = "mulecrate"

/obj/machinery/vending/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I,/obj/item/weapon/crowbar))
		if(istype(src,/obj/machinery/vending/wallmed1) || istype(src,/obj/machinery/vending/wallmed2))
			..()
			return
		if(anchored)
			playsound(src.loc, 'sound/items/Crowbar.ogg', 80, 1)
			user << "You struggle to pry the vending machine up off the floor."
			if(do_after(user, 40))
				user.visible_message( \
					"[user] lifts \the [src], which clicks.", \
					"\blue You have lifted \the [src], and wheels dropped into place underneath. Now you can pull it safely.", \
					"You hear a scraping noise and a click.")
				anchored = 0
		else
			user.visible_message( \
					"[user] pokes \his crowbar under \the [src], which settles with a loud bang", \
					"\blue You poke the crowbar at \the [src]'s wheels, and they retract.", \
					"You hear a scraping noise and a loud bang.")
			anchored = 1
			power_change()
		return
	..()

/obj/machinery/disposal/container
	name = "waste container unit"
	desc = "A portable waste disposal unit."
	icon_state = "container"

	process()
		if(!anchored)
			return
		..()

	flush()
		if(!anchored)
			return
		..()

	attackby(var/obj/item/I, var/mob/user)
		if(stat & BROKEN || !I || !user)
			return

		if(istype(I, /obj/item/weapon/crowbar))
			if(anchored)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 80, 1)
				user << "You struggle to pry the waste container unit up off the floor."
				if(do_after(user, 40))
					user.visible_message( \
						"[user] lifts \the [src], which clicks.", \
						"\blue You have lifted \the [src], and wheels dropped into place underneath. Now you can pull it safely.", \
						"You hear a scraping noise and a click.")
					anchored = 0

				trunk = null
				mode = 0
				flush = 0
			else
				user.visible_message( \
						"[user] pokes \his crowbar under \the [src], which settles with a loud bang", \
						"\blue You poke the crowbar at \the [src]'s wheels, and they retract.", \
						"You hear a scraping noise and a loud bang.")
				anchored = 1
				power_change()
				trunk = locate() in src.loc

				if(!trunk || !anchored)
					mode = 0
					flush = 0
				else
					trunk.linked = src
		else
			..()

	update()
		overlays = null
		if(stat & BROKEN)
			mode = 0
			flush = 0
			return

		// flush handle
		if(flush)
			overlays += image('disposal.dmi', "container-handle")

		// only handle is shown if no power
		if(stat & NOPOWER || mode == -1)
			return

		// 	check for items in disposal - occupied light
		if(contents.len > 0)
			overlays += image('disposal.dmi', "container-full")

		// charging and ready light
		if(mode == 1)
			overlays += image('disposal.dmi', "container-charge")
		else if(mode == 2)
			overlays += image('disposal.dmi', "container-ready")

/obj/item/weapon/melee/energy/vidari
	name = "vidari"
	desc = "And this is how you slice up people!"
	icon_state = "vidari"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 8
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD
	origin_tech = "magnets=3;syndicate=4"

	var/broken = 0
	var/mob/shanked = null
	var/toxindelay = 0

/obj/item/weapon/melee/energy/vidari/IsShield()
	if(active && prob(25))
		return 1
	return 0

/obj/item/weapon/melee/energy/vidari/attack(mob/living/M as mob, mob/user as mob)
	if (!istype(M, /mob/living/carbon))
		return
	if (user && user != M && active == 2)
		user.drop_item()
		if(hasorgans(M))
			var/datum/organ/external/target = M:get_organ(check_zone(user.zone_sel.selecting))
			if(target.status & ORGAN_DESTROYED)
				user << "What [target.display_name]?"
				return
			src.loc = target //Probably horrible.
			target.take_damage(15, 0, 1, src)
			user.visible_message("\red \The [user] stabs \the [M]'s [target.display_name] with \the [src]!","\red You stab \the [M]'s [target.display_name] with \the [src]!")
		else
			src.loc = M
			M.apply_damage(15,BRUTE)
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'> Stabbed with [src] by [user] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src] to stab [M] ([M.ckey])</font>")
		log_admin("ATTACK: [user] ([user.ckey]) stabbed [M] ([M.ckey]) with [src].")
		message_admins("ATTACK: [user] ([user.ckey]) stabbed [M] ([M.ckey]) with [src].")
		log_attack("<font color='red'>[user.name] ([user.ckey]) stabbed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")
		shanked = M
		shank(M)
		active = 0
		if(prob(10))
			broken = 1
	else
		..()

/obj/item/weapon/melee/energy/vidari/New()
	itemcolor = pick("red","blue","green","purple")

/obj/item/weapon/melee/energy/vidari/proc/updatestate()
	switch(active)
		if(0)
			force = 3
			throwforce = 5.0
			icon_state = "vidari"
			w_class = 2
			//playsound(user, 'saberoff.ogg', 50, 1)
		if(1)
			force = 15
			throwforce = 15.0
			icon_state = "vidari[itemcolor]"
			w_class = 4
			//playsound(user, 'saberon.ogg', 50, 1)

/obj/item/weapon/melee/energy/vidari/attack_self(mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50) && active)
		user << "\red You accidentally cut yourself with [src]."
		user.take_organ_damage(5,5)
	if(broken)
		user << "\red It won't turn on..."
		return
	active = (active + 1) % 3
	updatestate()
	switch(active)
		if(0)
			//playsound(user, 'saberoff.ogg', 50, 1)
			user << "\blue [src] Mode: Off"
		if(1)
			//playsound(user, 'saberon.ogg', 50, 1)
			user << "\blue [src] Mode: On"
		if(2)
			playsound(user, 'saberoff.ogg', 50, 1)
			user << "\blue [src] Mode: Magno"
	add_fingerprint(user)
	user.update_clothing()
	return

/obj/item/weapon/melee/energy/vidari/process()
	var/mob/living/M = shanked

	if(world.time < toxindelay)	return

	toxindelay = world.time + rand(5,600)

	if(isnull(shanked)) // If the mob got gibbed
		del(src)
	else if(!isnull(M))
		M.apply_damage(rand(1,3),TOX)



/obj/item/weapon/melee/energy/vidari/proc/shank(mob/source as mob)
	processing_objects.Add(src)

/obj/item/weapon/melee/energy/vidari/blue
	New()
		itemcolor = "blue"

/obj/item/weapon/melee/energy/vidari/red
	New()
		itemcolor = "red"

/obj/item/weapon/melee/energy/vidari/green
	New()
		itemcolor = "green"

/obj/item/weapon/melee/energy/vidari/purple
	New()
		itemcolor = "purple"

//Vibro Blade

/obj/item/projectile/beam/mining
	name = "mining laser"
	icon_state = "mining"
	damage = 5

	on_hit(var/atom/target, var/blocked = 0)
		if(!ismob(target))
			if(prob(60))
				target.ex_act(2)
			else
				target.ex_act(3)
		else
			..()
		return 1

/turf/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam/mining))
		src.ex_act(2)
	..()
	return 0

/obj/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam/mining))
		if(prob(60))
			src.ex_act(3)
		else
			src.ex_act(2)
	..()
	return 0

/obj/item/weapon/gun/energy/mining_laser
	name = "\improper Industrial Vibro-pulse Mining Laser"
	desc = "A heavy-duty mining laser powered by a vibrating energy crystal. The crystal can be detached at any time."
	icon_state = "mininglaser1"
	item_state = "pulse100"
	force = 5
	fire_sound = 'pulse.ogg'
	charge_cost = 200
	projectile_type = "/obj/item/projectile/beam/mining"
	cell_type = "/obj/item/weapon/cell/infinite"
	automatic = 1
	//var/mode = 2
	var/vibro = 1

	load_into_chamber()
		if(in_chamber)
			if(!istype(in_chamber, projectile_type))
				del(in_chamber)
				in_chamber = new projectile_type(src)
			return 1
		if(!vibro)	return 0
		if(!projectile_type)	return 0
		in_chamber = new projectile_type(src)
		return 1

	attack_self(mob/living/user as mob)
		if(..())
			vibro = 0
			update_icon()
			new /obj/item/weapon/melee/energy/vibro(user.loc)
			user << "You eject the vibro crystal."
		return

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I, /obj/item/weapon/melee/energy/vibro))
			if(!vibro)
				user.drop_item()
				del(I)
				vibro = 1
				update_icon()
				user << "\blue You plug the vibrocrystal into the mining laser."
			else
				usr << "\red The mining laser already has a vibrocrystal attached."

	update_icon()
		icon_state = "mininglaser[vibro]"

/obj/item/weapon/melee/energy/vibro
	name = "vibro-blade"
	desc = "Actually a power source."
	icon_state = "vibroblade"
	force = 9.0
	throwforce = 8.0
	throw_speed = 1
	throw_range = 5
	w_class = 4
	active = 1
	flags = FPRINT | TABLEPASS | NOSHIELD
	origin_tech = "magnets=4;material=2"

/obj/item/weapon/melee/energy/vibro/IsShield()
	if(active && prob(10))
		return 1
	return 0

/obj/item/weapon/melee/energy/vibro/attack(target as mob, mob/user as mob)
	..()

///obj/item/weapon/melee/energy/vibro/New()
	//itemcolor = pick("red","blue","green","purple")

/*/obj/item/weapon/melee/energy/vibro/attack_self(mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red You accidentally cut yourself with [src]."
		user.take_organ_damage(5,5)
	active = (active + 1) % 3
	switch(active)
		if(0)
			force = 3
			icon_state = "vidari"
			w_class = 2
			playsound(user, 'saberoff.ogg', 50, 1)
			user << "\blue [src] Mode: Off"
		if(1)
			force = 15
			icon_state = "vidari[itemcolor]"
			w_class = 4
			playsound(user, 'saberon.ogg', 50, 1)
			user << "\blue [src] Mode: On"
		if(2)
			user << "\blue [src] Mode: Magno"
	add_fingerprint(user)
	user.update_clothing()
	return*/

// LANCE
/obj/item/weapon/melee/energy/lance
	name = "energy lance"
	desc = "Stabbity stabbity~"
	icon_state = "elance0"
	item_state = "elance0"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 8
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD
	origin_tech = "magnets=3;syndicate=4"

/obj/item/weapon/melee/energy/lance/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/melee/energy/lance/attack(target as mob, mob/user as mob)
	..()

/obj/item/weapon/melee/energy/lance/New()
	itemcolor = pick("blue")

/obj/item/weapon/melee/energy/lance/attack_self(mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red You accidentally stab yourself with [src]. How did you even do that!?"
		user.take_organ_damage(10,10)
	active = !active
	if (active)
		force = 30
		icon_state = "elance[itemcolor]"
		item_state = "elance[itemcolor]"
		w_class = 4
		playsound(user, 'saberon.ogg', 50, 1)
		user << "\blue [src] is now active."
	else
		force = 3
		icon_state = "elance0"
		item_state = "elance0"
		w_class = 4
		playsound(user, 'saberoff.ogg', 50, 1)
		user << "\blue No seriously, you cannot fucking conceal this. A lance doesn't go in your backpack."
	add_fingerprint(user)
	user.update_clothing()
	return

/obj/structure/window/reinforced/tinted/random
	name = "tinted window"
	icon_state = "twindow"
	opacity = 0

	New()
		..()
		color = HSVtoRGB(hsv(rand(0,1536),255,255))

/obj/item/clothing/head/bio_hood/hazmat_botany
	icon_state = "hazmat_botany"
	item_state = "hazhat_botany"

/obj/item/clothing/suit/bio_suit/hazmat_botany
	icon_state = "hazmat_green"
	item_state = "hazsuit_green"