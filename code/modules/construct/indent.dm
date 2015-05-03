/obj/machinery/indent
	name = "indent"
	icon = 'indent.dmi'
	icon_state = "indent"
	desc = "A wall-indent for storing things."
	anchored = 1
	var/tdir = null
	var/mob/occupant
	var/obj/item/stack/cover
	var/obj/item/weapon/storage/backpack/vault
	var/icon/iconcover = list()
	var/secured = 0
	var/health = 14.0
	var/reinf = 0
	var/initcover = ""

	New(turf/loc, var/ndir, var/building=0)
		..()

		if (building)
			dir = ndir
		src.tdir = dir		// to fix Vars bug
		dir = SOUTH

		pixel_x = (src.tdir & 3)? 0 : (src.tdir == 4 ? 32 : -32)
		pixel_y = (src.tdir & 3)? (src.tdir ==1 ? 32 : -32) : 0

		var/obj/item/weapon/storage/backpack/v = new()
		v.loc = src.loc
		v.name = "indent"
		v.invisibility = 101
		v.distanceoverride = 1
		vault = v

		switch(initcover)
			if("metal")
				overlays = list("metal")
				cover = new/obj/item/stack/sheet/metal(src,1)
			if("glass")
				overlays = list("glass")
				cover = new/obj/item/stack/sheet/glass(src,1)
			if("rmetal")
				overlays = list("metal")
				cover = new/obj/item/stack/sheet/r_metal(src,1)
			if("rglass")
				overlays = list("glass")
				cover = new/obj/item/stack/sheet/rglass(src,1)
			if("grate")
				overlays = list("grate")
				cover = new/obj/item/stack/rods(src,1)
			if("circuit")
				overlays = list("circuit")
				cover = new/obj/item/stack/sheet/circuit(src,1)
			else
				overlays = list()
				cover = null
	 	return

	Del()
		for(var/obj/item/I in vault)
			I.loc = get_step(src.loc,tdir)
		if(cover)
			cover.loc = get_step(src.loc,tdir)
		..()

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if (!cover)
			if (user.s_active)
				user.s_active.close(user)
			vault.show_to(user)
		src.add_fingerprint(user)
		return

	attackby(obj/item/I as obj, mob/user as mob)
		src.add_fingerprint(user)
		if(!cover)
			var/obj/item/stack/S = I

			if(istype(I,/obj/item/stack/sheet/metal))
				S.use(1)
				overlays = list("metal")
				cover = new/obj/item/stack/sheet/metal(src,1)
			else if(istype(I,/obj/item/stack/sheet/r_metal))
				S.use(1)
				overlays = list("metal")
				cover = new/obj/item/stack/sheet/r_metal(src,1)
			else if(istype(I,/obj/item/stack/sheet/glass))
				S.use(1)
				overlays = list("glass")
				cover = new/obj/item/stack/sheet/glass(src,1)
			else if(istype(I,/obj/item/stack/sheet/rglass))
				S.use(1)
				overlays = list("glass")
				reinf = 1
				cover = new/obj/item/stack/sheet/rglass(src,1)
			else if(istype(I,/obj/item/stack/sheet/circuit))
				S.use(1)
				overlays = list("circuit")
				cover = new/obj/item/stack/sheet/circuit(src,1)
			else if(istype(I,/obj/item/stack/rods))
				S.use(1)
				overlays = list("grate")
				cover = new/obj/item/stack/rods(src,1)
			else
				vault.attackby(I,user)
		else
			if(istype(I,/obj/item/weapon/screwdriver))
				if(!secured)
					user << "You secure the cover."
					secured = 1
				else
					user << "You unscrew the cover."
					secured = 0
			else if(istype(I,/obj/item/weapon/crowbar))
				if(cover)
					if(!secured)
						overlays = list()
						reinf = 0
						health = 14.0
						cover.loc = src.loc
						cover = null
						user << "You pry off the cover."
					else
						user << "The cover is secured."
			else if(istype(I,/obj/item/weapon/weldingtool))
				//restore wall to normal if on
			else
				var/obj/item/weapon/W = I
				if(istype(cover,/obj/item/stack/sheet/glass) || istype(cover,/obj/item/stack/sheet/rglass))
					if(W)
						var/aforce = W.force
						if(reinf) aforce /= 2.0
						src.health = max(0, src.health - aforce)
						playsound(src.loc, 'Glasshit.ogg', 75, 1)
						user << "You bash at the cover!"
						if (src.health <= 7)
							overlays = list("glass_damage")
						if (src.health <= 0)
							overlays = list("glass_broken")
							secured = 0
							cover.loc = null
							cover = null
							user << "The cover shatters!"