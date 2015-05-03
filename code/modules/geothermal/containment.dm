var/list/engines = list()

#define ENG_EXPLODE 1
#define ENG_SILENT 2
#define ENG_RADIATE 4

proc/find_engine(var/id)
	var/datum/magmaengine/r

	for(var/datum/magmaengine/e in engines)
		if(e.id == id)
			r = e
			break

	if(!r)
		r = new()
		r.id = id
		engines += r

	return r


/datum/magmaengine
	var/id = ""
	var/heat = 0
	var/maxheat = 0
	var/heatdamage = 0
	var/containment_broke = 0
	var/running = 0
	var/flags

	proc/getheatlevel()
		return heat / maxheat

	proc/getintegrity()
		return maxheat / (maxheat + heatdamage)

/obj/effect/mapmarker/engine
	var/id = ""
	var/datum/magmaengine/engine
	var/maxheat = 100

	proc/heat(var/i)
		engine.heat += i
		engine.heat = max(0,engine.heat)

	proc/get_heat()
		return engine.heat

	New()
		engine = find_engine(id)

		if(engine)
			engine.maxheat += maxheat

		processing_objects.Add(src)

		..()

	Del()
		processing_objects.Remove(src)

		..()

	process()
		if(engine.heat > engine.maxheat)
			if(engine.flags | ENG_EXPLODE)
				processing_objects.Remove(src)
				explosion(src.loc, 8,16,33,48)
		return

/obj/structure/containment
	name = "containment wall"
	icon = 'walls.dmi'
	icon_state = "reactor"
	density = 1
	opacity = 1
	anchored = 1
	var/autoconnect = 1
	var/id = ""
	var/maxheat = 100
	var/datum/magmaengine/engine
	var/connectstate = 0

	proc/heat(var/i)
		engine.heat += i
		engine.heat = max(0,engine.heat)

		if(prob(33)) heatdamage(1) //Hooking the cooling up to space doesn't work indefinitely.

	proc/heatdamage(var/i)
		engine.heatdamage += i
		engine.maxheat -= i
		engine.maxheat = max(engine.maxheat,0)

	proc/get_heat()
		return engine.heat

	proc/get_heatlevel()
		return engine.getheatlevel()

	New()
		..()

		engine = find_engine(id)

		if(engine)
			engine.maxheat += maxheat

		spawn(2)
			connectadjacent()

		processing_objects.Add(src)

	Del()
		if(!engine.containment_broke)
			message_admins("Engine Containment breached! Lagspike imminent!")
			log_game("Engine Containment breached!")

			engine.containment_broke = 1

		processing_objects.Remove(src)

		..()

	ex_act(severity)
		if(severity > 1)
			heatdamage(100 / severity)
		else
			..()

	proc/connectadjacent()
		if(!autoconnect)
			return

		for(var/d in cardinal)
			var/turf/T = get_step(src,d)

			if(T)
				var/obj/structure/containment/C = locate(/obj/structure/containment) in T

				if(C)
					connectstate |= d


		icon_state = "[icon_state][connectstate]"

	CanPass(atom/movable/mover, turf/target, height, air_group)
		if(!height || air_group) return 0
		else return ..()

	liquid_pass(var/obj/effect/liquid/l)
		if(l.liquidtype == "lava")
			if(prob(33))
				heat(rand(1,5))

			//heatsink()

			if(prob(10) && engine.heat > engine.maxheat)
				del(src)

		return 0

/obj/structure/containment/window
	icon_state = "reactorw"
	opacity = 0
	autoconnect = 0
	maxheat = 50

/turf/simulated/floor/engine/containment
	name = "containment"
	icon_state = "reactor"
	carbon_dioxide = 50000

/turf/simulated/floor/engine/molten
	name = "molten floor"
	icon_state = "cult"
	intact = 0
	burnt = 1

	New()
		..()
		if(prob(5))
			var/damagestate = rand(1,7)
			icon_state = "cultdamage" + (damagestate == 1 ? "" : "[damagestate]")

	attackby(obj/item/weapon/C as obj, mob/user as mob)
		return

/obj/machinery/atmospherics/unary/containment_cooler
//currently the same code as cold_sink but anticipating process() changes

	icon = 'portables_connector.dmi'
	icon_state = "intact"

	name = "Containment Cooler"
	desc = "Cools engine containment."

	var/set_temperature = T20C
	var/coolinglevel = 0.5
	var/id = ""

	update_icon()
		icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
		return

	process()
		..()

		var/turf/T = loc

		if(!T)
			return

		var/obj/structure/containment/C = locate(/obj/structure/containment) in T

		if(!C)
			return

		if(air_contents.temperature < T20C && C.get_heatlevel() > coolinglevel)
			var/old_temperature = air_contents.temperature

			C.heat(air_contents.temperature - T20C)

			var/datum/gas_mixture/flow = air_contents.remove_ratio(0.03)

			if(flow)
				flow.temperature = max(set_temperature,flow.temperature)

			air_contents.merge(flow) //Then put it back where you found it.

			if(abs(old_temperature-air_contents.temperature) > 1)
				network.update = 1

		//C.heatsink()

		return 1