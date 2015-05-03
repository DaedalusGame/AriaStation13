/obj/item/weapon/gun/tanklauncher
	name = "tank launcher"
	icon = 'gun.dmi'
	icon_state = "tankgun"
	item_state = "riotgun"
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	var/list/grenades = new/list()
	var/max_grenades = 3
	m_amt = 2000

	examine()
		set src in view()
		..()
		if (!(usr in view(2)) && usr!=src.loc) return
		usr << "\icon [src] Tank launcher:"
		usr << "\blue [grenades] / [max_grenades] Tanks."

	attackby(obj/item/I as obj, mob/user as mob)

		if(istype(I, /obj/item/weapon/tank) && !istype(I, /obj/item/weapon/tank/plasma) && !istype(I, /obj/item/weapon/tank/jetpack))
			if(grenades.len < max_grenades)
				user.drop_item()
				I.loc = src
				grenades += I
				user << "\blue You put the tank in the tank launcher."
				user << "\blue [grenades.len] / [max_grenades] Tanks."
			else
				usr << "\red The tank launcher cannot hold more tanks."

	afterattack(obj/target, mob/user , flag)

		if (istype(target, /obj/item/weapon/storage/backpack ))
			return

		else if (locate (/obj/structure/table, src.loc))
			return

		else if(target == user)
			return

		if(grenades.len)
			spawn(0) fire_grenade(target,user)
		else
			usr << "\red The tank launcher is empty."

	proc
		fire_grenade(atom/target, mob/user)
			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red [] fired a tank!", user), 1)
			user << "\red You fire the tank launcher!"
			if (istype(grenades[1], /obj/item/weapon/tank))
				var/obj/item/weapon/tank/F = grenades[1]
				grenades -= F
				F.loc = user.loc
				F.throw_at(target, 30, 2)
				message_admins("[key_name_admin(user)] fired a tank from a tank launcher ([src.name]).")
				log_game("[key_name_admin(user)] used a tank launcher ([src.name]).")
				playsound(user.loc, 'armbomb.ogg', 75, 1, -3)
				spawn(2)
					F.air_contents.volume /= 6