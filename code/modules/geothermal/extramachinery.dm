/obj/machinery/enginethermometer
	name = "Mounted thermometer"
	desc = "A wall-mounted temperature measure."
	icon = 'liquidmachinery.dmi'
	icon_state = "enginetemp0"
	var/id = null
	var/disable = 0
	var/temperature = 0
	anchored = 1

/obj/machinery/enginethermometer/New()
	..()

/obj/machinery/enginethermometer/process()
	var/obj/structure/containment/cwall = locate(/obj/structure/containment) in get_step(src,dir)

	if(disable) return

	if(cwall)
		temperature = 0
		if(cwall.engine)
			temperature = cwall.engine.heat / cwall.engine.maxheat

		switch(temperature)
			if(0.0 to 0.2) icon_state = "enginetemp1"
			if(0.2 to 0.4) icon_state = "enginetemp2"
			if(0.4 to 0.6) icon_state = "enginetemp3"
			if(0.6 to 0.8) icon_state = "enginetemp4"
			if(0.8 to 1.0) icon_state = "enginetemp5"
			if(1.0 to INFINITY) icon_state = "enginetemp6"
	else
		icon_state = "enginetemp0"

/obj/machinery/enginethermometer/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	if (istype(W, /obj/item/weapon/screwdriver))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("\red [user] has disabled the [src]!", "\red You disable the connection to the [src].")
		if (!src.disable)
			user.visible_message("\red [user] has reconnected the [src]!", "\red You fix the connection to the [src].")

/obj/machinery/programmable/engineinsertion
	name = "Engine insertion/extraction port"
	desc = "A programmable engine interface."

	icon = 'liquidmachinery.dmi'
	icon_state = "engineport"

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I,/obj/item/weapon/card/emag))
			user << "You swipe the [name] with your card.  After a moment's grinding, it beeps in a sinister fashion."
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)
			emagged = 1
			overrides += emag_overrides

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 1, src)
			s.start()

			return