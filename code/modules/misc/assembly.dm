/obj/item/device/bombassembly
	name = "bomb assembly"
	desc = "A holder for explosive materials."
	icon = 'assemblies.dmi'
	icon_state = "bombassembly00"
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	w_class = 2.0
	m_amt = 100
	g_amt = 0
	w_amt = 0
	throwforce = 2
	throw_speed = 3
	throw_range = 10
	origin_tech = "magnets=1"

	var/obj/item/weapon/ore/gem/coronium/coro1
	var/obj/item/weapon/ore/gem/coronium/coro2
	var/timer = 15
	var/ready = 0
	var/timing = 0

	var/atom/target = null

	done
		name = "coronium two-component bomb"
		icon_state = "bombassembly11"

		New()
			coro1 = new(src)
			coro2 = new(src)
			ready = 1
			update_icon()

/obj/item/device/bombassembly/update_icon()
	icon_state = "bombassembly[coro2 != null][coro1 != null]"

/obj/item/device/bombassembly/attackby(obj/item/item, mob/user)
	if(!item || timing)
		return

	if(istype(item, /obj/item/weapon/ore/gem/coronium))
		if(coro1 && coro2)
			user << "<span class='warning'>There are already two pieces of coronium attached.</span>"
			return

		if(!coro1)
			coro1 = item
			user.drop_item()
			item.loc = src
			user << "<span class='notice'>You attach the [item] to the assembly.</span>"
		else if(!coro2)
			coro2 = item
			user.drop_item()
			item.loc = src
			user << "<span class='notice'>You attach the [item] to the assembly.</span>"

		update_icon()

	else if(istype(item, /obj/item/weapon/screwdriver))
		if(coro1 && coro2 && !ready)
			ready = 1
			name = "coronium two-component bomb"
			user << "<span class='notice'>You ready the assembly.</span>"

/obj/item/device/bombassembly/attack_self(mob/user as mob)
	if (!ready)
		return

	if (timing)
		user << "<span class='warning'>You push the two halves together!</span>"
		user.visible_message("\red [user.name] pushes the bomb assembly together! It looks like \he's trying to commit suicide!")
		icon_state = "bombassemblyXX"

		spawn(3)
			var/turf/T = get_turf(src)

			if(T)
				explosion(T, 1, 3, 5, 12)
				if (src)
					del(src)

		return

	user << "You activate the assembly. Timer counting down from [timer]."
	log_admin("[user] ([user.ckey]) has activated a [src].")
	message_admins("[user] ([user.ckey]) activated a [src].")

	timing = 1

	spawn(timer*9.9)
		icon_state = "bombassemblyXX"

		sleep(3)

		var/turf/T = get_turf(src)

		if(T)
			explosion(T, 1, 3, 5, 12)
			if (src)
				del(src)


/obj/item/device/bombassembly/afterattack(atom/target as obj|turf, mob/user as mob, flag)
	if (!flag)
		return
	if (istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/item/weapon/storage/) || ismob(target))
		return
	if (!ready || timing)
		return
	user << "Attaching assembly..."
/*	if(ismob(target))
		user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] tried planting [name] on [target:real_name] ([target:ckey])</font>"
		user.visible_message("\red [user.name] is trying to plant some kind of explosive on [target.name]!")	*/
	if(do_after(user, 20) && in_range(user, target))
		user.drop_item()
		target = target
		loc = null
		timing = 1
		var/location
		if (isturf(target)) location = target
		if (isobj(target)) location = target.loc
		target.overlays += image('assemblies.dmi', "bombassembly11")
		log_admin("[user] ([user.ckey]) has planted a [src].")
		message_admins("[user] ([user.ckey]) planted a [src].")
		user << "Assembly has been attached. Timer counting down from [timer]."
		spawn(timer*10)
			if(target)
				explosion(location, 1, 3, 5, 12)
				if (src)
					del(src)

/obj/item/weapon/liquidcartridge
	icon = 'stock_parts.dmi'
	name = "chem cartridge"
	icon_state = "cartridge"
	w_class = 3.0
	var/volume = 100

/obj/item/weapon/liquidcartridge/New()
	var/datum/reagents/R = new/datum/reagents(volume)
	reagents = R
	R.my_atom = src

	pixel_x = rand(0,12)-6
	pixel_y = rand(0,12)-6

/obj/item/weapon/gascartridge
	icon = 'tank.dmi'
	name = "plasma cartridge"
	icon_state = "plasma_s"
	w_class = 3.0
	var/volume = 45
	var/datum/gas_mixture/air_contents = null
	pressure_resistance = ONE_ATMOSPHERE*2.5
	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4

/obj/item/weapon/gascartridge/New()
	src.air_contents = new /datum/gas_mixture()
	src.air_contents.volume = volume //liters
	src.air_contents.temperature = T20C

	src.air_contents.toxins = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

	pixel_x = rand(0,8)-4
	pixel_y = rand(0,8)-4

/obj/effect/deployhologram
	name = "content preview"
	layer = MOB_LAYER + 1
	mouse_opacity = 0
	anchored = 1

/obj/item/weapon/deployframe
	icon = 'stock_parts.dmi'
	name = "deployment frame"
	icon_state = "deploy0"
	w_class = 4.0
	var/list/deploytypes = list()
	var/deploydir = 2
	var/ready = 0
	var/obj/effect/deployhologram/currentholo

/obj/item/weapon/deployframe/New()
	..()

	pixel_x = rand(0,8)-4
	pixel_y = rand(0,8)-4

	processing_objects.Add(src)

/obj/item/weapon/deployframe/Del()
	processing_objects.Remove(src)

/obj/item/weapon/deployframe/attackby(obj/item/item, mob/user)
	if(istype(item, /obj/item/weapon/wrench))
		if(ready)
			user << "\blue You deploy the frame. It's contents expand!"
			deploy()
		else
			user << "\blue You prepare the deployframe. Use a screwdiver to rotate the frame. Crowbar to pick it up."

			user.before_take_item(src)
			loc = get_turf(user)
			ready()

	else if(istype(item, /obj/item/weapon/screwdriver))
		if(ready)
			deploydir = turn(deploydir, 90)
			makehologram()
			icon_state = "deploy[deploydir]"

	else if(istype(item, /obj/item/weapon/crowbar))
		if(ready)
			unready()

/obj/item/weapon/deployframe/proc/ready()
	icon_state = "deploy[deploydir]"
	ready = 1
	anchored = 1
	makehologram()

/obj/item/weapon/deployframe/proc/makehologram()
	if(!currentholo) currentholo = new(loc)

	var/icon/newicon

	for(var/typepath in deploytypes)
		var/obj/O = new typepath(src)

		if(!O)
			continue

		O.setdirection(src.dir)

		if(!newicon) newicon = icon(O.icon, O.icon_state, O.dir, 1)
		else newicon.Blend(icon(O.icon, O.icon_state, O.dir, 1), ICON_OVERLAY)

		currentholo.pixel_x = O.pixel_x
		currentholo.pixel_y = O.pixel_y

		del(O)

	currentholo.icon = getHologramIcon(newicon, 1, rgb(20,240,60))

/obj/item/weapon/deployframe/process()
	if(currentholo)
		currentholo.loc = get_turf(src)

/obj/item/weapon/deployframe/proc/unready()
	icon_state = "deploy0"
	ready = 0
	anchored = 0
	if(currentholo)
		del(currentholo)
		currentholo = null

/obj/item/weapon/deployframe/proc/deploy()
	for(var/typepath in deploytypes)
		var/obj/O = new typepath(src.loc)
		if(O)
			O.dir = deploydir

	del(src)

/obj/item/weapon/deployframe/Del()
	if(currentholo)
		del(currentholo)
	..()

/obj/item/weapon/blueprintdisk
	icon = 'stock_parts.dmi'
	name = "blueprint disk"
	icon_state = "bluedisk"
	w_class = 2.0
	var/list/recipes = list()
	var/list/researches = list()
	var/researchlevel = 0

///obj/item/weapon/blueprintdisk/robots
	//New()
	//	..()
	//	for(var/datum/assemblerprint/recipe in assembler_recipes)
	//		recipes += recipe

/obj/item/weapon/blueprintdisk/New()
	..()

	for(var/datum/assemblerprint/recipe in assembler_recipes)
		//world << "[recipe.name]: [recipe.tech] in researches [recipe.tech in researches] - [recipe.simplicity] [recipe.simplicity >= max(0,100-researchlevel)]"

		if((!researches.len || !recipe.tech || (recipe.tech in researches)) && (recipe.simplicity >= max(0,100-researchlevel)))
			//world << "added."
			src.recipes += recipe

	pixel_x = rand(0,12)-6
	pixel_y = rand(0,12)-6

/obj/item/weapon/blueprintdisk/robotics
	name = "robotics blueprint disk"
	researches = list("robotics")

/obj/item/weapon/blueprintdisk/engineering
	name = "engineering blueprint disk"
	researches = list("engineering")

/obj/item/weapon/blueprintdisk/medical
	name = "medical blueprint disk"
	researches = list("medical")

/obj/item/weapon/blueprintdisk/civilian
	name = "civilian blueprint disk"
	researches = list("civilian")

/obj/item/weapon/blueprintdisk/clothing
	name = "clothing blueprint disk"
	researches = list("clothing")

/obj/item/weapon/blueprintdisk/mining
	name = "mining blueprint disk"
	researches = list("mining")

/obj/item/weapon/blueprintdisk/security
	name = "security blueprint disk"
	researches = list("security")

/obj/item/weapon/blueprintdisk/botany
	name = "botany blueprint disk"
	researches = list("botany")

/obj/item/weapon/blueprintdisk/omni
	name = "completed research disk"
	//researches = list("","civilian","robotics","engineering","medical","mining","security","clothing","security","botany")
	researches = list()
	researchlevel = 100

///obj/item/weapon/blueprintdisk/omni/New()
//	..()
//	for(var/datum/assemblerprint/recipe in assembler_recipes)
//		recipes += recipe

/obj/machinery/proc/get_idinfo()
	return ""

/obj/item/scrapblock
	name = "scrapblock"
	icon = 'scrap.dmi'
	icon_state = "mixedblock"
	item_state = "scrap-metal"
	desc = "A compacted block of scrap"
	var/classtext = ""
	m_amt = 0
	g_amt = 0
	w_amt = 0
	var/blood = 0		// 0=none, 1=blood-stained, 2=bloody

	throwforce = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4
	flags = FPRINT | TABLEPASS | CONDUCT

	random
		New()
			..()
			set_components(rand(100,500),rand(100,500),rand(100,500))

	metal
		icon_state = "metalblock"
		New()
			..()
			set_components(rand(100,500),0,0)

	glass
		icon_state = "glassblock"
		New()
			..()
			set_components(0,rand(100,500),0)

	waste
		icon_state = "wasteblock"
		New()
			..()
			set_components(0,0,rand(100,500))

/obj/item/scrapblock/proc/total()
	return m_amt + g_amt + w_amt

/obj/item/scrapblock/proc/set_components(var/m, var/g, var/w)
	m_amt = m
	g_amt = g
	w_amt = w

	update()

/obj/item/scrapblock/proc/update()
	var/total = total()

	// determine bloodiness
	var/bloodtext = ""
	switch(blood)
		if(0)
			bloodtext = ""
		if(1)
			bloodtext = "blood-stained "
		if(2)
			bloodtext = "bloody "


	// find mixture and composition
	var/class = 0		// 0 = mixed, 1=mostly. 2=pure
	var/major = "waste"		// the major component type

	var/max = 0

	if(m_amt > max)
		max = m_amt
	else if(g_amt > max)
		max = g_amt
	else if(w_amt > max)
		max = w_amt

	if(max == total)
		class = 2		// pure
	else if(max/total > 0.6)
		class = 1		// mostly
	else
		class = 0		// mixed

	if(class>0)
		var/remain = total - max
		if(m_amt > remain)
			major = "metal"
		else if(g_amt > remain)
			major = "glass"
		else
			major = "waste"


		if(class == 1)
			desc = "A compacted block of mostly [major] [bloodtext]scrap."
			classtext = "mostly [major] [bloodtext]"
		else
			desc = "A compacted block of [bloodtext][major] scrap."
			classtext = "[bloodtext][major] "
		icon_state = "[major]block"
		if(blood)
			overlays += "blood[blood]"
	else
		desc = "A compacted block of [bloodtext]mixed scrap."
		classtext = "[bloodtext]mixed"
		icon_state = "mixedblock"
		if(blood)
			overlays += "blood[blood]"

	pixel_x = rand(-5,5)
	pixel_y = rand(-5,5)

	// clear or set conduction flag depending on whether scrap is mostly metal
	if(major=="metal")
		flags |= CONDUCT
	else
		flags &= ~CONDUCT

	item_state = "scrap-[major]"

/obj/item/gibblock
	name = "meatcube"
	icon = 'scrap.dmi'
	icon_state = "gibblock"
	//item_state = "scrap-metal"
	desc = "A compacted block of grisly gibs"
	m_amt = 0
	g_amt = 0
	w_amt = 0
	var/gibamount = 10
	var/quality = 50
	var/bones = 0

	throwforce = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4
	flags = FPRINT | TABLEPASS

	New()
		..()
		quality = rand(20,70)

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(is_cut(W))
			if(prob(10))
				new /obj/effect/decal/cleanable/blood/splatter(src.loc)

			if(prob(quality))
				new /obj/item/weapon/reagent_containers/food/snacks/meat/cube(src.loc)
			else if(prob(33))
				new /obj/effect/decal/cleanable/blood/gibs(src.loc)
			gibamount--

			if(!gibamount)
				new /obj/effect/decal/cleanable/blood/gibs(src.loc)
				if(bones)
					new /obj/effect/decal/remains/human(src.loc)
				del(src)


/obj/item/pipeassembly
	name = "pipe assembly"
	desc = "Part of a pipe manifold."
	icon = 'assemblies.dmi'
	icon_state = "atmosA"
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	w_class = 3.0
	var/buildstatus = 0

/obj/item/pipeassembly/New()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)

/obj/item/pipeassembly/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W,/obj/item/pipeassembly/valve) && src.buildstatus == 0)
		desc = "Part of a pipe manifold with a valve attached."
		icon_state = "atmosAB"
		buildstatus = 1
		user.before_take_item(W)
		del(W)
	if(istype(W,/obj/item/pipeassembly/endpiece))
		var/obj/item/pipeassembly/endpiece/E = W

		if(E.buildstatus == 1 && src.buildstatus == 1)
			new/obj/item/weapon/gun/projectile/gasgun(user.loc)
			user.before_take_item(W)
			del(W)
			user.before_take_item(src)
			del(src)


/obj/item/pipeassembly/endpiece
	desc = "A small, bent piece."
	icon_state = "atmosC1"

/obj/item/pipeassembly/endpiece/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W,/obj/item/pipeassembly/endpiece) && buildstatus == 0)
		desc = "A handle made from a pipe."
		icon_state = "atmosC2"
		buildstatus = 1
		user.before_take_item(W)
		del(W)

/obj/item/pipeassembly/valve
	desc = "A valve part."
	icon_state = "atmosB"

/obj/item/weapon/gun/projectile/gasgun
	name = "pipe gun"
	desc = "All hail Atmosia!"
	icon = 'assemblies.dmi'
	icon_state = "atmosABC"
	item_state = "gun"
	max_shells = 3
	w_class = 4.0
	force = 10
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	slot_flags = SLOT_BACK
	caliber = "pipegun"
	origin_tech = "combat=3;materials=1"
	var/obj/item/weapon/tank/attached = null
	var/wired = 0
	//ammo_type = "/obj/item/ammo_casing/shotgun/beanbag"

	done/New()
		attached = new /obj/item/weapon/tank/oxygen(src)
		wired = 1
		..()

	New()
		update_icon()
		return

	load_into_chamber()
//		if(in_chamber)
//			return 1 {R}
		if(!loaded.len)
			return 0

		var/obj/item/AC = loaded[1] //load next casing.
		loaded -= AC //Remove casing from loaded list.

		if(!attached)
			return 0

		if(attached.air_contents.return_pressure() < ONE_ATMOSPHERE * 0.01)
			return 0

		if(istype(AC,/obj/item/weapon/reagent_containers/food/snacks/grown/potato))
			del(AC)
			in_chamber = new /obj/item/projectile/bullet/potato(src)
			return 1
		if(istype(AC,/obj/item/stack/rods))
			del(AC)
			in_chamber = new /obj/item/projectile/bullet/rod(src)
			return 1
		if(istype(AC,/obj/item/weapon/shard))
			del(AC)
			in_chamber = new /obj/item/projectile/bullet/glass(src)
			return 1
		return 0

	Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)
		if(!..())
			return

		if(!attached)
			return

		if(attached.air_contents.temperature > 0)
			var/transfer_moles = (attached.air_contents.return_pressure())*50/(attached.air_contents.temperature * R_IDEAL_GAS_EQUATION)

			var/datum/gas_mixture/removed = attached.air_contents.remove(transfer_moles)

			loc.assume_air(removed)


	update_icon()
		overlays = null

		if(attached)
			overlays += "atmos_[attached.icon_state]"

		if(wired)
			overlays += "atmos+w"

		return

	attackby(var/obj/item/A as obj, mob/user as mob)
		if(istype(A, /obj/item/weapon/reagent_containers/food/snacks/grown/potato) || istype(A, /obj/item/weapon/shard))
			if((loaded.len < max_shells))	//forgive me father, for i have sinned
				user.drop_item()
				A.loc = src
				loaded += A
				user << "<span class='notice'>You load a [A.name] into \the [src]!</span>"
		if(istype(A, /obj/item/stack/rods))
			var/obj/item/stack/rods/R = A

			if((loaded.len < max_shells) && (contents.len < max_shells))	//forgive me father, for i have sinned
				R.use(1)
				loaded += new /obj/item/stack/rods(src)
				user << "<span class='notice'>You load a [R.singular_name] into \the [src]!</span>"
		if(istype(A,/obj/item/weapon/tank/oxygen) || istype(A,/obj/item/weapon/tank/air) || istype(A,/obj/item/weapon/tank/anesthetic))
			if(!attached)
				user.before_take_item(A)
				A.loc = src
				attached = A
		if(istype(A,/obj/item/weapon/cable_coil) && attached)
			var/obj/item/weapon/cable_coil/C = A

			if(C)
				C.use(2)
				wired = 1
		if(istype(A,/obj/item/weapon/wirecutters) && wired)
			var/turf/T = get_turf(src)
			if(T)
				attached.loc = T
			else
				del(attached)
			attached = null
			wired = 0


		update_icon()