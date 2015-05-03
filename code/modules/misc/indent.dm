/obj/item/indent_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 2 )
		del(src)

/obj/item/indent_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf(usr)
	for(var/obj/machinery/indent/T in loc)
		if (T.dir == ndir)
			usr << "\red The wall is already indented in this place."
			return
	new /obj/machinery/indent(loc, ndir, 1)
	del(src)


/obj/machinery/indent
	name = "indent"
	icon = 'indent.dmi'
	icon_state = "build"
	desc = "A wall-indent for storing things."
	anchored = 1
	var/tdir = null
	var/obj/item/stack/cover
	var/icon/iconcover = list()
	var/secured = 0
	var/health = 14.0
	var/reinf = 0
	var/initcover = ""
	var/build


	New(turf/loc, var/ndir, var/building=0)
		..()

		// offset 24 pixels in direction of dir
		// this allows the APC to be embedded in a wall, yet still inside an area
		if (building)
			build = 1
			dir = ndir
		src.tdir = dir		// to fix Vars bug
		dir = SOUTH

		pixel_x = (src.tdir & 3)? 0 : (src.tdir == 4 ? 32 : -32)
		pixel_y = (src.tdir & 3)? (src.tdir ==1 ? 32 : -32) : 0

		switch(initcover)
			if("metal")
				overlays = list("metal")
				cover = new/obj/item/stack/sheet/metal(src,1)
			if("glass")
				overlays = list("glass")
				cover = new/obj/item/stack/sheet/glass(src,1)
			if("rmetal")
				overlays = list("metal")
				cover = new/obj/item/stack/sheet/plasteel(src,1)
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
		for(var/atom/movable/I in contents)
			I.Move(loc)
		..()

	process()
		var/turf/T = get_step(src,tdir)
		if(!istype(T,/turf/simulated/wall))
			del(src)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if (!cover && !build)
			var/obj/item/stuff = contents[contents.len]
			stuff.Move(loc)
		src.add_fingerprint(user)
		return

	attackby(obj/item/I as obj, mob/user as mob)
		src.add_fingerprint(user)
		if(build)
			if(istype(I,/obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = I
				if( WT.remove_fuel(0,user) )
					user << "<span class='notice'>You slice an indent into the plating.</span>"
					playsound(src.loc, 'Welder.ogg', 100, 1)
					build = 0
					icon_state = "indent"
					overlays = list("metal")
					cover = new/obj/item/stack/sheet/metal(src,1)
				else
					user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
					return
			else if(istype(I,/obj/item/weapon/wrench))
				user << "<span class='notice'>You wrench the indent frame off.</span>"
				playsound(src.loc, 'Ratchet.ogg', 75, 1)
				new /obj/item/indent_frame( get_turf(src.loc) )
				del(src)

		else if(!cover)
			var/obj/item/stack/S = I

			if(istype(I,/obj/item/stack/sheet/metal))
				S.use(1)
				overlays = list("metal")
				cover = new/obj/item/stack/sheet/metal(src,1)
			else if(istype(I,/obj/item/stack/sheet/plasteel))
				S.use(1)
				overlays = list("metal")
				cover = new/obj/item/stack/sheet/plasteel(src,1)
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
				usr.before_take_item(I)
				I.loc = src
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