/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapons()
	if(my_atom.next_firetime > world.time)
		usr << "<span class='warning'>Your weapons are recharging.</span>"
		return
	var/turf/firstloc
	var/turf/secondloc
	if(!my_atom.equipment_system || !my_atom.equipment_system.weapon_system)
		usr << "<span class='warning'>Missing equipment or weapons.</span>"
		my_atom.verbs -= text2path("[type]/proc/fire_weapons")
		return
	my_atom.battery.use(shot_cost)
	var/olddir
	for(var/i = 0; i < shots_per; i++)
		if(olddir != my_atom.dir)
			switch(my_atom.dir)
				if(NORTH)
					firstloc = get_step(my_atom, NORTH)
					firstloc = get_step(firstloc, NORTH)
					secondloc = get_step(firstloc,EAST)
				if(SOUTH)
					firstloc = get_step(my_atom, SOUTH)
					secondloc = get_step(firstloc,EAST)
				if(EAST)
					firstloc = get_step(my_atom, EAST)
					firstloc = get_step(firstloc, EAST)
					secondloc = get_step(firstloc,NORTH)
				if(WEST)
					firstloc = get_step(my_atom, WEST)
					secondloc = get_step(firstloc,NORTH)
		olddir = dir
		var/proj_type = text2path(projectile_type)
		var/obj/item/projectile/projone = new proj_type(firstloc)
		var/obj/item/projectile/projtwo = new proj_type(secondloc)
		projone.starting = get_turf(my_atom)
		//projone.shot_from = src
		projone.firer = usr
		projone.def_zone = "chest"
		projone.original = get_step(projone.starting,my_atom.dir)
		projone.yo = projone.original.y - projone.starting.y
		projone.xo = projone.original.x - projone.starting.x
		projtwo.starting = get_turf(my_atom)
		//projtwo.shot_from = src
		projtwo.firer = usr
		projtwo.def_zone = "chest"
		projtwo.original = get_step(projtwo.starting,my_atom.dir)
		projtwo.yo = projtwo.original.y - projtwo.starting.y
		projtwo.xo = projtwo.original.x - projtwo.starting.x
		spawn()
			playsound(src, fire_sound, 50, 1)
			projone.fired()
			projtwo.fired()
			//projone.dumbfire(my_atom.dir)
			//projtwo.dumbfire(my_atom.dir)
		sleep(2)
	my_atom.next_firetime = world.time + fire_delay

/datum/spacepod/equipment
	var/obj/spacepod/my_atom
	var/obj/item/device/spacepod_equipment/weaponry/weapon_system // weapons system
	var/obj/item/device/spacepod_equipment/misc/misc_system // misc system
	//var/obj/item/device/spacepod_equipment/engine/engine_system // engine system
	//var/obj/item/device/spacepod_equipment/shield/shield_system // shielding system

/datum/spacepod/equipment/New(var/obj/spacepod/SP)
	..()
	if(istype(SP))
		my_atom = SP

/obj/item/device/spacepod_equipment
	name = "equipment"
	var/obj/spacepod/my_atom
// base item for spacepod weapons

/obj/item/device/spacepod_equipment/weaponry
	name = "pod weapon"
	desc = "You shouldn't be seeing this"
	icon = 'icons/pods/ship.dmi'
	icon_state = "blank"
	var/projectile_type
	var/shot_cost = 0
	var/shots_per = 1
	var/fire_sound
	var/fire_delay = 20

/obj/item/device/spacepod_equipment/weaponry/taser
	name = "\improper taser system"
	desc = "A weak taser system for space pods, fires electrodes that shock upon impact."
	icon_state = "pod_taser"
	projectile_type = "/obj/item/projectile/energy/electrode"
	shot_cost = 250
	fire_sound = "sound/weapons/Taser.ogg"

/obj/item/device/spacepod_equipment/weaponry/tesla
	name = "\improper tesla beam system"
	desc = "A powerful teslacoil beam system for space pods."
	icon_state = "pod_b_taser"
	projectile_type = "/obj/item/projectile/beam/thunder"
	shot_cost = 1000
	fire_sound = "sound/effects/stealthoff.ogg"
	fire_delay = 60

/obj/item/device/spacepod_equipment/weaponry/burst_taser
	name = "\improper burst taser system"
	desc = "A weak taser system for space pods, this one fires 3 at a time."
	icon_state = "pod_b_taser"
	projectile_type = "/obj/item/projectile/energy/electrode"
	shot_cost = 350
	shots_per = 3
	fire_sound = "sound/weapons/Taser.ogg"
	fire_delay = 40

/obj/item/device/spacepod_equipment/weaponry/laser
	name = "\improper laser system"
	desc = "A weak laser system for space pods, fires concentrated bursts of energy"
	icon_state = "pod_w_laser"
	projectile_type = "/obj/item/projectile/beam"
	shot_cost = 300
	fire_sound = 'sound/weapons/Laser.ogg'
	fire_delay = 30

//TODO: all of these
/obj/item/device/spacepod_equipment/weaponry/shockcoil
	name = "\improper tesla beam system"
	desc = "A powerful teslacoil beam system for space pods."
	icon_state = "pod_b_taser"
	projectile_type = "/obj/item/projectile/beam/thunder"
	shot_cost = 1000
	fire_sound = "sound/effects/stealthoff.ogg"
	fire_delay = 60

/obj/item/device/spacepod_equipment/weaponry/magmaul
	name = "\improper tesla beam system"
	desc = "A powerful teslacoil beam system for space pods."
	icon_state = "pod_b_taser"
	projectile_type = "/obj/item/projectile/beam/thunder"
	shot_cost = 1000
	fire_sound = "sound/effects/stealthoff.ogg"
	fire_delay = 60

/obj/item/device/spacepod_equipment/weaponry/battlehammer
	name = "\improper tesla beam system"
	desc = "A powerful teslacoil beam system for space pods."
	icon_state = "pod_b_taser"
	projectile_type = "/obj/item/projectile/beam/thunder"
	shot_cost = 1000
	fire_sound = "sound/effects/stealthoff.ogg"
	fire_delay = 60

/obj/item/device/spacepod_equipment/weaponry/voltdriver
	name = "\improper tesla beam system"
	desc = "A powerful teslacoil beam system for space pods."
	icon_state = "pod_b_taser"
	projectile_type = "/obj/item/projectile/beam/thunder"
	shot_cost = 1000
	fire_sound = "sound/effects/stealthoff.ogg"
	fire_delay = 60

/obj/item/device/spacepod_equipment/weaponry/judicator
	name = "\improper tesla beam system"
	desc = "A powerful teslacoil beam system for space pods."
	icon_state = "pod_b_taser"
	projectile_type = "/obj/item/projectile/beam/thunder"
	shot_cost = 1000
	fire_sound = "sound/effects/stealthoff.ogg"
	fire_delay = 60

/obj/item/device/spacepod_equipment/weaponry/imperialist
	name = "\improper tesla beam system"
	desc = "A powerful teslacoil beam system for space pods."
	icon_state = "pod_b_taser"
	projectile_type = "/obj/item/projectile/beam/thunder"
	shot_cost = 1000
	fire_sound = "sound/effects/stealthoff.ogg"
	fire_delay = 60

//base item for spacepod misc equipment (tracker)
/obj/item/device/spacepod_equipment/misc
	name = "pod misc"
	desc = "You shouldn't be seeing this"
	icon = 'icons/pods/ship.dmi'
	icon_state = "blank"
	var/enabled

/obj/item/device/spacepod_equipment/misc/tracker
	name = "\improper spacepod tracking system"
	desc = "A tracking device for spacepods."
	icon_state = "pod_locator"
	enabled = 0

/obj/item/device/spacepod_equipment/misc/tracker/attackby(obj/item/I as obj, mob/user as mob, params)
	if(isscrewdriver(I))
		if(enabled)
			enabled = 0
			user.show_message("<span class='notice'>You disable \the [src]'s power.")
			return
		enabled = 1
		user.show_message("<span class='notice'>You enable \the [src]'s power.</span>")
	else
		..()