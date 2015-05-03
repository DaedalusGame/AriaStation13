/proc/findliquidstorage(var/id)
	var/ports = 0

	for(var/obj/machinery/liquidport/qport/QP in world)
		if(QP.id == id)
			ports += 1

	//world << "searching compatible quantumnet [id] with [ports] ports"
	var/obj/effect/liquidstorage/LS = findliquidmarker(id)

	if(LS && ports < 2)
		//world << "insufficient ports, deleting quantumnet: [LS]"
		del(LS)
		return null
	if(!LS && ports >= 2)
		LS = new(locate(1,1,1))
		LS.id = id
		//world << "making new compatible quantumnet: [LS]"

	return LS

/proc/findliquidmarker(var/id)
	for(var/obj/effect/liquidstorage/L in world)
		if(L.id == id)
			//world << "found compatible quantumnet"
			return L

/obj/effect/liquidstorage
	var/id = ""
	flags = NOREACT

	New()
		var/datum/reagents/R = new/datum/reagents(1000000)
		reagents = R
		R.my_atom = src

		processing_objects.Add(src)

		..()

	Del()
		processing_objects.Remove(src)

		..()

	process()
		return

/obj/machinery/liquidport/qport
	name = "liquid quantum superposition port"
	desc = "A connector to the main material storage of the ship."
	icon_state = "qport"
	var/id = ""

	get_reagents()
		var/obj/effect/liquidstorage/LS = findliquidstorage(id)

		if(LS)
			return LS.reagents
		else
			return null