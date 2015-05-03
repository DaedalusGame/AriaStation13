var/list/recipeblacklist = list(
	/datum/assemblerprint,
	/datum/assemblerprint/engine,
	/datum/assemblerprint/security,
	/datum/assemblerprint/mining,
	/datum/assemblerprint/medical,
	/datum/assemblerprint/robots,
	/datum/assemblerprint/civil)

proc/generate_assembler_recipes()
	if(!assembler_recipes.len)
		for(var/recipe in typesof(/datum/assemblerprint) - recipeblacklist)
			var/datum/assemblerprint/newrecipe = new recipe(src)

			if(!newrecipe.typepath)
				continue

			assembler_recipes += newrecipe

var/recipeidcounter = 0

datum/assemblerprint
	var/id
	var/name
	var/desc
	//var/typepath = /obj
	var/typepath
	var/simplicity = 0
	var/list/components = list()
	var/list/liquidcomponents = list()
	var/duration = 0
	var/powerusage = 0
	var/tech = ""
	//var/tech
	var/deploy

	var/icon
	var/icon_state = ""
	var/color
	var/preicon

	var/list/sentusers = list()

	var/buyfactor = 1.0
	var/sellfactor = 1.0

	New()
		if(!typepath) return

		var/obj/testobj = new typepath(src)
		id = recipeidcounter
		recipeidcounter += 1

		if(!name)
			name = testobj.name

		if(!icon)
			icon = testobj.icon
			icon_state = testobj.icon_state
			color = testobj.color

		if(!desc)
			if(liquidcomponents.len)
				desc += "Required materials:<BR>"
				for(var/R in liquidcomponents)
					var/datum/reagent/RE = chemical_reagents_list[R]

					if(RE)
						var/ammount = liquidcomponents[R]
						var/rname = RE.name

						desc += "[ammount] units of [rname]<BR>"
				desc += "<BR>"
			if(components.len)
				desc += "Required components:<BR>"
				for(var/comp in components)
					var/obj/O = new comp(src)

					desc += "[O.name]<BR>"

					del(O)

			desc += "<BR>"
			desc += "Requires [powerusage]W<BR>"
			desc += "Takes [duration/10] seconds<BR>"

		del(testobj)

	proc/builditem(var/location)
		var/obj/O

		if(deploy)
			var/obj/item/weapon/deployframe/D = new(location)
			D.deploytypes += typepath
			O = D
		else
			O = new typepath(location)

		return O

	proc/build(var/obj/machinery/assembler/a)
		if(a.building)
			return

		if(a.has_components(components,liquidcomponents))
			a.building = 1

			a.use_power(powerusage / getupgrade("assembler_efficiency"))
			sleep(duration / getupgrade("assembler_speed"))

			var/obj/O = builditem(a)

			O.loc = a

			/*if(deploy)
				var/obj/item/weapon/deployframe/D = new(src)
				D.deploytypes += typepath
				O = D
			else
				O = new typepath(a)*/

			a.building = 0

			if(!istype(O,/obj/item/chemmaker))
				a.eject(O)
			else
				del(O)

			return 1

	proc/destroy(var/obj/machinery/disassembler/a)
		if(a.building)
			return

		a.building = 1

		a.use_power(powerusage / getupgrade("disassembler_efficiency"))
		sleep(duration / getupgrade("disassembler_speed"))

		for(var/objtype in components)
			if(prob(simplicity))
				var/obj/O = new objtype(a)
				a.eject(O)

		for(var/R in liquidcomponents)
			a.reagents.add_reagent(R,liquidcomponents[R]*(simplicity/100))

		a.building = 0

		if(a.canresearch)
			if(a.doresearch(src))
				return 1

		return

	proc/getrecipeicon(mob/user as mob)
		if(!user) return ""

		var/resname = "recipe[id]"

		if(!preicon)
			var/icon/recipeicon = icon(icon,icon_state,SOUTH,1)
			if(color)
				recipeicon.Blend(color)
			preicon = fcopy_rsc(recipeicon)

		if(!(user.client in sentusers))
			user << browse_rsc(preicon,resname)
			sentusers += user.client

		return resname