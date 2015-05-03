/obj/machinery/bot/fetchbot
	name = "Fetchbot"
	desc = "A multi-utility arm effector robot"
	icon_state = "fetchbot0"
	health = 25 //yeah, it's tougher than ed209 because it is a big metal box with wheels --rastaf0
	maxhealth = 25
	fire_dam_coeff = 1.7
	brute_dam_coeff = 0.8
	var/obj/item/carried = null		// the loaded item

	var/atom/target
	req_access = list() // added robotics access so assembly line drop-off works properly -veyveyr //I don't think so, Tim. You need to add it to the MULE's hidden robot ID card. -NEO
	var/path[] = new()

	var/blockcount	= 0		//number of times retried a blocked path
	var/reached_target = 1 	//true if already reached the target

/obj/machinery/bot/fetchbot/New()
	..()
	botcard = new(src)
	botcard.access = get_access("Quartermaster")
	botcard.access += ACCESS_ROBOTICS

	//verbs -= /atom/movable/verb/pull

/obj/machinery/bot/fetchbot/process()
	if(!has_power())
		on = 0
		return
	if(on)
		process_bot()

	//if(refresh) updateDialog()

/obj/machinery/bot/fetchbot/proc/process_bot()
	//if(mode) world << "Mode: [mode]"
	switch(mode)
		if(0)		// idle
			return
		if(1)		// loading/unloading
			return
		if(2,3,4)		// navigating to deliver,home, or blocked

			if(loc == target)		// reached target
				at_target()
				return

			else if(path.len > 0 && target)		// valid path

				var/turf/next = path[1]
				reached_target = 0
				if(next == loc)
					path -= next
					return


				if(istype( next, /turf/simulated))
					//world << "at ([x],[y]) moving to ([next.x],[next.y])"
					var/moved = step_towards(src, next)	// attempt to move
					if(moved)	// successful move
						//world << "Successful move."
						blockcount = 0
						path -= loc

						if(destination == home_destination)
							mode = 3
						else
							mode = 2

					else		// failed to move
						blockcount++
						mode = 4
						if(blockcount == 3)
							src.visible_message("[src] makes an annoyed buzzing sound", "You hear an electronic buzzing sound.")
							playsound(src.loc, 'buzz-two.ogg', 50, 0)

						if(blockcount > 5)	// attempt 5 times before recomputing
							// find new path excluding blocked turf
							src.visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
							playsound(src.loc, 'buzz-sigh.ogg', 50, 0)

							spawn(2)
								calc_path(next)
								if(path.len > 0)
									src.visible_message("[src] makes a delighted ping!", "You hear a ping.")
									playsound(src.loc, 'ping.ogg', 50, 0)
								mode = 4
							mode =6
							return
						return
				else
					src.visible_message("[src] makes an annoyed buzzing sound", "You hear an electronic buzzing sound.")
					playsound(src.loc, 'buzz-two.ogg', 50, 0)
					//world << "Bad turf."
					mode = 5
					return
			else
				//world << "No path."
				mode = 5
				return

		if(5)		// calculate new path
			//world << "Calc new path."
			mode = 6
			spawn(0)

				calc_path()

				if(path.len > 0)
					blockcount = 0
					mode = 4
					src.visible_message("[src] makes a delighted ping!", "You hear a ping.")
					playsound(src.loc, 'ping.ogg', 50, 0)

				else
					src.visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
					playsound(src.loc, 'buzz-sigh.ogg', 50, 0)

					mode = 7
		//if(6)
			//world << "Pending path calc."
		//if(7)
			//world << "No dest / no route."
	return


// calculates a path to the current destination
// given an optional turf to avoid
/obj/machinery/bot/fetchbot/proc/calc_path(var/turf/avoid = null)
	src.path = AStar(src.loc, get_turf(src.target), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_ortho, 0, 250, id=botcard, exclude=avoid)
	src.path = reverselist(src.path)

/obj/machinery/bot/fetchbot/proc/fetch(var/obj/item/I)
	if(carried) return 0

	if(in_range(I,src))
		flick("fetchbot-c",src)
		carried = I
		update_icon()
		return 1

	return 0

/obj/machinery/bot/fetchbot/proc/update_icon()
	overlays.Cut()

	if(carried)
		icon_state = "fetchbot-i"

		var/icon/I = icon('items_lefthand.dmi',carried.item_state,SOUTH)
		I.Turn(270)
		var/image/II = image(I)
		II.pixel_x = -5
		II.pixel_y = -2
		overlays += II
	else
		icon_state = "fetchbot0"