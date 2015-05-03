/atom/proc/get_cybermap(var/level)
	return null

/atom/proc/make_cybermap(var/sizew,var/sizeh,var/list/programs)
	var/obj/effect/cyberspace/mapholder/newmap = new()

	newmap.generate(sizew,sizeh,max(sizew,sizeh))
	var/list/freetiles = newmap.get_free_spots()

	for(var/progtype in programs)
		var/obj/effect/cyberspace/sector/S = pick(freetiles)
		S.deploy(progtype)
		freetiles -= S

	return newmap


/obj/machinery/computer
	var/list/cyber_baseprograms = list(/obj/effect/cyberspace/program/sentinel1)
	var/cyber_mapsize = 7 //minimum size until better ui code
	var/obj/effect/cyberspace/mapholder/cyber_mapobj

	get_cybermap(var/level)
		if(!cyber_mapobj)
			cyber_mapobj = make_cybermap(cyber_mapsize,cyber_mapsize,cyber_baseprograms)

		return cyber_mapobj

/obj/machinery/power/netterm/get_cybermap(var/level)
	if(master)
		return master.get_cybermap(level)