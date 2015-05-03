/obj/item/weapon/beach_ball/bball
	name = "basketball"
	icon = 'icons/obj/bball.dmi'
	icon_state = "bball"
	item_state = "bball"
	desc = "Do the spacejam!"
	w_class = 4 //Stops people from hiding it in their bags/pockets
	var/jamheight = 2
	var/jampower = 0
	var/shimmers = 0

	New()
		..()
		update_icon()

	throw_impact(atom/hit_atom)
		var/turf/T = hit_atom.loc

		if(isturf(hit_atom))
			T = hit_atom

		if(jampower)
			explosion(T, 1*jampower, 3*jampower, 5*jampower, 6*jampower)
		..()

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I, /obj/item/weapon/shimmerglobe))
			if(shimmers < 1)
				user.drop_item()
				del(I)
				shimmers += 1
				update_icon()
				user << "\blue SHWOOOOOOOM!!"
				user.update_clothing()
			else
				usr << "\red The world cannot handle that much AWESOME."

	update_icon()
		switch(shimmers)
			if(0)
				name = "basketball"
				desc = "Do the spacejam!"
				icon_state = "bball"
				item_state = "bball"
				jamheight = 2
				jampower = 0
			if(1)
				name = "hellball"
				desc = "Shut up and jam."
				icon_state = "hellball"
				item_state = "hellball"
				jamheight = 20
				jampower = 1
			if(2)
				name = "double dribble"
				desc = "Shut shut up up and and jam jam."
				icon_state = "hellball"
				item_state = "hellball"
				jamheight = 20
				jampower = 5

/obj/item/weapon/beach_ball/bball/hellball
	name = "hellball"
	icon = 'icons/obj/bball.dmi'
	icon_state = "bball"
	item_state = "hellball"
	desc = "Shut up and jam."
	shimmers = 1

/obj/item/weapon/shimmerglobe
	name = "shimmerglobe"
	icon = 'icons/obj/bball.dmi'
	icon_state = "shimmerglobe"
	item_state = "nothing"
	desc = "It's the legendary shimmerglobe!"
	w_class = 4 //Stops people from hiding it in their bags/pockets