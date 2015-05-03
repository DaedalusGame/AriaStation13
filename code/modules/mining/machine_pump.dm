/obj/machinery/mineral/pump
	name = "liquid pump"

	icon = 'liquidmachinery.dmi'
	icon_state = "pump0"
	density = 1

	var/on = 0
	var/volume = 2500
	var/valve = 1

/obj/machinery/mineral/pump/New()
	var/datum/reagents/R = new/datum/reagents(volume)
	reagents = R
	R.my_atom = src
	..()

/obj/machinery/mineral/pump/Del()
	del(reagents)
	..()

/obj/machinery/mineral/pump/process()
	if(!on)
		return

	for(var/turf/simulated/floor/plating/airless/lava/L in orange(1,src))
		reagents.add_reagent("lava",rand(10,30))

	for(var/obj/machinery/liquidtank/T in orange(1,src))
		reagents.trans_to(T,100)
		T.update_icon()

	if(anchored)
		var/obj/machinery/liquidport/P = locate(/obj/machinery/liquidport) in loc
		if(P)
			P.valve = valve


/obj/machinery/mineral/pump/update_icon()
	if(on)
		icon_state = "pump1"
	else
		icon_state = "pump0"

	return

/obj/machinery/mineral/pump/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/mineral/pump/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/mineral/pump/attack_hand(var/mob/user as mob)
	if(!user || user.stat)
		return

	on = !on
	if(on)
		user << "\blue You turn on the pump."
	else
		user << "\blue You turn off the pump."
	update_icon()

/obj/machinery/mineral/pump/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (W.is_open_container())
		return 1
	else if (istype(W, /obj/item/weapon/wrench))
		if(anchored)
			user << "\blue You wrench the pump from the floor."
			playsound(src.loc, 'Ratchet.ogg', 75, 1)
			anchored = 0
		else
			var/turf/T = get_turf(src)

			if(!T)
				return

			if(!istype(T,/turf/simulated/floor) || istype(T,/turf/simulated/floor/plating/airless/lava))
				user << "\red You can't anchor the pump here!"
			else
				user << "\blue You wrench the pump to \the [T.name]"
				playsound(src.loc, 'Ratchet.ogg', 75, 1)
				anchored = 1

