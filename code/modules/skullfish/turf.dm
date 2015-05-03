//var/maxZ = 4
//var/minZ = 1

/*
/turf/simulated/floor/open
	name = "open space"
	intact = 0
	icon_state = "open"
	pathweight = 100000 //Seriously, don't try and path over this one numbnuts
	var/icon/darkoverlays = null
	var/turf/floorbelow
	var/obj/machinery/zvent/bottom = null
	//floorstrength = 1
	mouse_opacity = 2

	New()
		..()
		spawn(1)
			if(!istype(src, /turf/simulated/floor/open)) //This should not be needed but is.
				return
			floorbelow = locate(x, y, z + 1)
			if(floorbelow)
				//Fortunately, I've done this before. - Aryn
				if(istype(floorbelow,/turf/space) || floorbelow.z > maxZ)
					new/turf/space(src)
				else if(!istype(floorbelow,/turf/simulated/floor))
					new/turf/simulated/floor/plating(src)
				else
					//if(ticker)
						//find_zone()
					new /obj/machinery/zvent(src)
					bottom = new /obj/machinery/zvent(floorbelow)

					update()
			else
				new/turf/space(src)

	Del()
		for(var/obj/machinery/zvent/v in src)
			del(v)
		if(bottom)
			del(bottom)
		. = ..()

	Enter(var/atom/movable/AM)
		if (..()) //TODO make this check if gravity is active (future use) - Sukasa
			spawn(1)
				if(AM)
					AM.Move(locate(x, y, z + 1))
					if (istype(AM, /mob) && !istype(AM.loc, /turf/simulated/floor/open))
						AM:bruteloss += 20 //You were totally doin it wrong. 5 damage? Really? - Aryn
						AM:weakened = max(AM:weakened,5)
						AM:updatehealth()
		return ..()

	attackby()
		//nothing

	proc/update() //Update the overlayss to make the openspace turf show what's down a level
		if(!floorbelow) return
		/*src.clearoverlays()
		src.addoverlay(floorbelow)
		for(var/obj/o in floorbelow.contents)
			src.addoverlay(image(o, dir=o.dir, layer = TURF_LAYER+0.05*o.layer))
		var/image/I = image('ULIcons.dmi', "[min(max(floorbelow.LightLevelRed - 4, 0), 7)]-[min(max(floorbelow.LightLevelGreen - 4, 0), 7)]-[min(max(floorbelow.LightLevelBlue - 4, 0), 7)]")
		I.layer = TURF_LAYER + 0.2
		src.addoverlay(I)
		I = image('ULIcons.dmi', "1-1-1")
		I.layer = TURF_LAYER + 0.2
		src.addoverlay(I)*/
*/

/turf/simulated/flesh //wall piece
	name = "flesh wall"
	icon = 'walls.dmi'
	icon_state = "meat2"
	opacity = 1
	density = 1
	blocks_air = 1
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500
	var/flesheye

/turf/simulated/flesh/New()
	if(prob(10) && icon_state == "meat2")
		icon_state = "meat3"
		//Add occular organ

/turf/simulated/flesh/Del()
	return

/turf/simulated/flesh/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				src.ReplaceWithFloor()
		if(1.0)
			src.ReplaceWithFloor()
	return

/turf/simulated/flesh/ReplaceWithFloor()
	if(!icon_old) icon_old = icon_state
	var/turf/simulated/floor/plating/flesh/W
	var/old_dir = dir

	W = new /turf/simulated/floor/plating/flesh( locate(src.x, src.y, src.z) )
	W.dir = old_dir

	/*
	W.icon_old = old_icon
	if(old_icon) W.icon_state = old_icon
	*/
	W.opacity = 1
	W.ul_SetOpacity(0)
	W.levelupdate()
	return W

/turf/simulated/floor/plating/flesh //floor piece
	name = "flesh"
	icon = 'floors.dmi'
	icon_state = "meat3"
	oxygen = 20
	nitrogen = 80
	temperature = TCMB
	icon_plating = "meat3"

/turf/simulated/floor/plating/flesh/New()
	var/proper_name = name
	..()
	name = proper_name

/turf/simulated/floor/plating/flesh/ex_act(severity)
	return

/turf/simulated/mainframe //wall piece
	name = "mainframe wall"
	icon = 'walls.dmi'
	icon_state = "future0"
	oxygen = 0
	nitrogen = 0
	opacity = 1
	density = 1
	blocks_air = 1
	temperature = TCMB
	var/flesheye

/turf/simulated/mainframe/New()
	if(icon_state == "future0")
		if(prob(10))
			icon_state = "future4"
			spawn(2)
				ul_SetLuminosity(2,2,4)
		else
			icon_state = "future[rand(0,3)]"


/turf/simulated/mainframe/Del()
	ul_SetLuminosity(0,0,0)
	..()

/turf/simulated/mainframe/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				src.ReplaceWithFloor()
		if(1.0)
			src.ReplaceWithFloor()
	return

/turf/simulated/mainframe/ReplaceWithFloor()
	if(!icon_old) icon_old = icon_state
	var/turf/simulated/floor/mainframe/W
	var/old_dir = dir

	W = new /turf/simulated/floor/mainframe( locate(src.x, src.y, src.z) )
	W.dir = old_dir

	/*
	W.icon_old = old_icon
	if(old_icon) W.icon_state = old_icon
	*/
	W.opacity = 1
	W.ul_SetOpacity(0)
	W.levelupdate()
	return W

/turf/simulated/floor/mainframe //floor piece
	name = "mainframe floor"
	icon = 'floors.dmi'
	icon_state = "future"
	oxygen = 0
	nitrogen = 100
	temperature = 80
	icon_plating = "plating"

/turf/simulated/floor/mainframe/New()
	var/proper_name = name
	..()
	name = proper_name

/turf/simulated/floor/mainframe/ex_act(severity)
	return