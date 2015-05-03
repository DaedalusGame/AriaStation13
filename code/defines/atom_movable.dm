/atom/movable
	var/inertia_dir = 0

	proc/Process_Spacemove(var/movement_dir = 0)
		//if(has_gravity(src))
		//	return 1

		//if(pulledby)
		//	return 1

		if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
			return 1

		return 0