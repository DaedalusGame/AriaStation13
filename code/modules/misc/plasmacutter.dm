/obj/item/weapon/gun/plasmacutter
	name = "Plasma Cutter"
	icon = 'items.dmi'
	icon_state = "plasmacutter"
	item_state = "gun"
	w_class = 3.0 //it is smaller than the pickaxe
	damtype = "fire"
	origin_tech = "materials=4;plasmatech=3;engineering=3"
	desc = "A rock cutter that uses bursts of hot plasma. You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	var/projectile_type = "/obj/item/projectile/energy"
	var/obj/item/ammo_casing/plasma/clip = null
	var/recentpump = 0

	load_into_chamber()
		if(!clip) return 0

		if(in_chamber)
			if(!istype(in_chamber, clip.projectile_type))
				del(in_chamber)
				in_chamber = new clip.projectile_type(src)
			return 1

		if(!clip.ammo) return 0
		if(!clip.projectile_type)	return 0
		in_chamber = new clip.projectile_type(src)
		clip.ammo--
		return 1

	attack_self()
		if(..())
			if(recentpump)	return
			if(!clip) return
			clip.loc = get_turf(src)
			clip = null
			recentpump = 1
			spawn(10)
				recentpump = 0
		return

	attack(mob/living/M as mob, mob/living/user as mob, def_zone)
		if(user.zone_sel.selecting != "chest" && hasorgans(M))
			var/mob/living/carbon/H = M
			var/datum/organ/external/S = H:organs[user.zone_sel.selecting]
			if(S.status & ORGAN_DESTROYED)
				return

			for(var/mob/O in viewers(H, null))
				O.show_message(text("\red [H] gets \his [S.display_name] sawed at with [src] by [user]... It looks like [user] is trying to cut it off!"), 1)
			if(!do_after(user, rand(20,40)))
				for(var/mob/O in viewers(H, null))
					O.show_message(text("\red [user] tried to cut [H]'s [S.display_name] off with [src], but failed."), 1)
				return
			if(S.status & ORGAN_ROBOT)
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, M)
				spark_system.attach(M)
				spark_system.start()
				spawn(10)
					del(spark_system)
			for(var/mob/O in viewers(H, null))
				O.show_message(text("\red [H] gets \his [S.display_name] sawed off with [src] by [user]."), 1)

			S.droplimb(1)
			H:update_body()
		else
			return ..()

	attackby(var/obj/item/A as obj, mob/user as mob)
		if(istype(A, /obj/item/ammo_casing/plasma))
			if(!clip)
				user.drop_item()
				A.loc = src
				clip = A
		if(clip)
			user << "\blue You load /the [clip] into /the [src]!"
		return


/obj/item/ammo_casing/plasma
	name = "plasma casing"
	desc = "A casing that contains gases which can turn into plasma."
	icon = 'ammo.dmi'
	icon_state = "plasma"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 2
	w_class = 1.0
	projectile_type = "/obj/item/projectile/energy/cut"//The bullet type to create when New() is called
	var/ammo = 10

	military
		icon_state = "plasma-m"

	New()
		..()
		pixel_x = rand(-10.0, 10)
		pixel_y = rand(-10.0, 10)

/obj/item/projectile/energy/cut
	name = "\improper Plasma Bolt"
	icon_state = "pulse0_bl"
	damage = 20
	damage_type = BRUTE