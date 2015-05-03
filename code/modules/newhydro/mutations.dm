/datum/plantmutation
	var/name = "Unknown Mutation"
	var/desc = "Report this."
	var/datum/seed/plant
	var/colorid
	var/color = "#FFFFFF"

	var/weight = 0

	var/identified = 0
	var/mutationtype = ""

	var/nodemutate = 0
	var/noremove = 0
	var/nostack = 0

	var/additivestack = 0

	//New(var/datum/seed/P)
	//	plant = P
	proc/get_name()
		return name

	proc/get_description()
		return desc

	proc/copy(var/datum/seed/P)
		var/datum/plantmutation/M = new type(P)

		M.colorid = colorid
		M.color = color

		return M

	//When the plant first mutates
	proc/mutate()
		if(nostack)
			for(var/datum/plantmutation/mut in plant.mutations)
				if(ispath(mut.type,type) && mut != src)
					if(additivestack)
						addstack(mut)
					plant.mutations -= mut

		plant.update_icon()

	proc/demutate()
		plant.update_icon()

	proc/randomize()

	proc/upgrade()

	proc/downgrade()

	proc/addstack(var/datum/plantmutation/mut)

	//When the plant drinks from the tray
	proc/drink()

	//When a person eats this plant
	proc/consume(var/mob/user,var/atom/product)

	//When someone processes the plant
	proc/process(var/atom/processor,var/atom/product)

	//When someone harvests the plant
	proc/harvest(var/atom/user,var/atom/product)

	//While the plant lives
	proc/life(var/obj/effect/plantvine/vine)

	//While the product exists
	proc/productlife(var/atom/product)

	specieschange
		name = "Species Change"
		var/defaultplant

		mutationtype = "special"
		nostack = 1
		weight = 1

		mutate()
			plant.removemutation(src)

	requirement		//Growth Requirements
		name = "Requirement"
		mutationtype = "growth"

		weight = 0
		nostack = 1

		life(var/obj/effect/plantvine/vine)
			if(!meets_requirement(vine))
				vine.health -= rand(1,3)

		proc/meets_requirement(var/obj/effect/plantvine/vine)
			return 0

		temperature
			name = "Temperature Tolerance"
			weight = 1
			var/temp_ideal
			var/temp_tolerance

			get_description()
				return "Grows in [temp_ideal]K (&plusmn;[temp_tolerance])"

			meets_requirement(var/obj/effect/plantvine/vine)
				if(!vine) return 0

				var/turf/T = get_turf(vine)
				var/env_temp = T.temperature
				var/datum/gas_mixture/enviroment = T.return_air()

				if(enviroment)
					env_temp = enviroment.temperature	//environment.return_pressure()

				if(env_temp >= temp_ideal - temp_tolerance && env_temp < temp_ideal + temp_tolerance)
					return 1

				return 0

		pressure
			name = "Pressure Tolerance"
			weight = 1
			var/kpa_ideal
			var/kpa_tolerance

			get_description()
				return "Grows in [kpa_ideal]kPa (&plusmn;[kpa_tolerance])"

			meets_requirement(var/obj/effect/plantvine/vine)
				if(!vine) return 0

				var/turf/T = get_turf(vine)
				var/env_pressure = 0
				var/datum/gas_mixture/enviroment = T.return_air()

				if(enviroment)
					env_pressure = enviroment.return_pressure()

				if(env_pressure >= kpa_ideal - kpa_tolerance && env_pressure < kpa_ideal + kpa_tolerance)
					return 1

				return 0

	underfloor
		name = "Underfloor"
		weight = 20
		mutationtype = "growth"
		nostack = 1

	traytakeover	//Takes over adjacent trays
		name = "Tray Takeover"
		weight = 20
		var/range = 1
		nostack = 1

		mutationtype = "growth"

		moving		//Only jumps, deletes the original

	spread
		name = "Spread"
		weight = 50
		var/spreadspeed
		var/slowsize = 1
		var/maxsize = 1
		var/needlattice = 1
		nostack = 1

		New()
			..()
			if(!spreadspeed)
				spreadspeed = rand(1,100)
				slowsize = rand(10,100)
				maxsize = slowsize * 2

		mutate()
			..()
			plant.spreadspeed = spreadspeed
			plant.slowdownsize = slowsize
			plant.requireslattice = needlattice

		free
			needlattice = 0

	discoloration	//Recolor
		name = "Discoloration"
		mutationtype = "cosmetic"
		weight = 100

		New()
			color = rgb(rand(255),rand(255),rand(255))

		mutate()
			colorid = pick(plant.basecolors)
			..()

	reagent			//Contains additional reagent
		name = "Additional Reagent"
		weight = 100
		var/reagentid			//Which reagent the product will contain
		var/reagentmin = 0		//How much the product contains by default
		var/reagentmax = 0		//How much the product can contain
		var/reagentscale = 0	//How the reagent scales to potency

		get_description()
			return "Produces traces of up to [reagentmax] units of [reagentid]"

		var/list/reagentwhitelist = list("water",
										//Deadly stuff
										"toxin",
										"stoxin",
										"acid",
										"pacid",		//Death Nettle had this before
										"amatoxin",
										"plasma",		//This is a remarkably bad idea
										"poisonberryjuice",
										"zombiepowder",	//Breed it out of nothing instead of grabbing Stasisflower
										"cryptobiolin",
										"lexorin",		//Poor-mans Stealthtox
										"impedrezene",
										//Condiment
										"nutriment",	//All of these on a sliding scale of sense
										"sugar",
										"milk",
										"glycerol",
										"nicotine",
										"capsaicin",
										"soysauce",
										"ketchup",
										"frostoil",
										"sodiumchloride",
										"blackpepper",
										"coco",
										"cornoil",
										"enzyme",
										"orangejuice",
										"limejuice",
										"lemonjuice",
										"carrotjuice",
										"grapejuice",
										"berryjuice",
										"watermelonjuice",
										"lemonjuice",
										"banana",
										"potato",
										"tea",
										"ethanol",
										//Drugs
										"psilocybin",
										"space_drugs",
										"LSD",
										//Materials
										"fiber",
										"rubber",			//Makes some sense.
										"iron",
										"gold",
										"ultraglue",		//No use yet. Be afraid.
										"plantlube",		//Fucking Syndies will regret this
										"sulfur",
										"blood", 			//WHY
										//Medicine
										"anti_toxin",		//Antidote Plants
										"stoxin2", 			//Natural healing through sleep or something
										"inaprovaline",		//Not very useful but eh
										"leporazine",		//Stabilize Temperature, somewhat exotic
										"tricordrazine",	//Ambrosia Deus
										"kelotane",			//Some lower tier wide-spectrums
										"dexalin",
										"synaptizine",
										"tramadol",
										"oxycodone",
										"alkysine",
										"imidazoline",
										"bicaridine",
										"hyperzine",
										"lipozine")			//Leek

		mutationtype = "product"

		New()
			..()

			spawn(1)
				if(!reagentid)
					reagentid = pick(reagentwhitelist)
					reagentmin = rand(0,10)
					reagentmax = rand(reagentmin+1,100)
					reagentscale = rand(10,90) / 100

		life(var/obj/effect/plantvine/vine)
			if(!vine || !vine.master)
				return

			if(!vine.master.reagents.has_reagent(reagentid,reagentmax))
				vine.master.reagents.add_reagent(reagentid,reagentscale)

			for(var/obj/fruit in vine.fruits)
				if(!fruit.reagents)
					continue
				if(fruit.reagents.has_reagent(reagentid,reagentmax))
					continue
				fruit.reagents.add_reagent(reagentid,reagentscale)

		harvest(var/atom/user,var/atom/product)
			if(!product.reagents)
				return

			if(reagentid)
				var/amt = min(reagentmax,max(reagentmin,plant.potency * reagentscale))

				product.reagents.add_reagent(reagentid,amt)

		seeping
			weight = 5

			harvest(var/atom/user,var/atom/product)
				if(reagentid)
					var/amt = min(reagentmax,max(reagentmin,plant.potency * reagentscale)) / 3

					var/datum/reagent/R = chemical_reagents_list[reagentid]
					if(ismob(user))
						R.reaction_mob(user,TOUCH,amt)
					else
						R.reaction_obj(user,amt)

	dense			//Grows until it obscures tile
		name = "Dense Growth"
		mutationtype = "growth"
		weight = 1
		nostack = 1

		super		//Blocks passage
			name = "Superdense Growth"
			mutationtype = "special"

			hyper	//Blocks airflow. Badass.
				name = "Hyperdense Growth"


	immutable 		//Never mutates
		name = "Immutable"
		mutationtype = "special"
		weight = 1
		nostack = 1

	inert 			//Never takes any actions
		name = "Inert"
		mutationtype = "special"
		weight = 1
		nostack = 1

	dying
		name = "Decaying"
		mutationtype = "special"
		weight = 1
		nostack = 1

		var/rate

		New()
			if(!rate)
				rate = rand(1,100)

		life(var/obj/effect/plantvine/vine)
			vine.health -= rand(1,3)

	emitgas
		name = "Gas Emitter"
		mutationtype = "product"
		weight = 5
		nostack = 1
		additivestack = 1

		var/o2
		var/n2
		var/plasma
		var/co2

		get_description()
			var/dat = ""

			if(o2) dat += "Produces traces of up to [o2] moles of oxygen"
			if(n2) dat += "Produces traces of up to [n2] moles of nitrogen"
			if(co2) dat += "Produces traces of up to [co2] moles of carbondioxide"
			if(plasma) dat += "Produces traces of up to [plasma] moles of plasma"

			return dat

		addstack(var/datum/plantmutation/emitgas/mut)
			if(!mut) return

			o2 = (o2 + mut.o2) * 0.75
			n2 = (n2 + mut.n2) * 0.75
			co2 = (co2 + mut.co2) * 0.75
			plasma = (plasma + mut.plasma) * 0.75

		New()
			..()

			spawn(1)
				if(o2 + n2 + plasma + co2 <= 0)
					var/gastype = pick(prob(200);"o2",prob(100);"n2",prob(30);"co2",prob(10);"tox",prob(5);"fuel")

					switch(gastype)
						if("o2")
							o2 = rand(0,2000) / 1000
						if("n2")
							n2 = rand(0,2000) / 1000
						if("co2")
							co2 = rand(0,2000) / 1000
						if("tox")
							plasma = rand(0,2000) / 1000
						if("fuel")
							o2 = rand(0,1000) / 1000
							plasma = rand(0,1000) / 1000
						//if("n2o")

		life(var/obj/effect/plantvine/vine)
			if(!vine) return 0

			var/turf/T = get_turf(vine)

			if(!T) return

			var/datum/gas_mixture/enviroment = T.return_air()

			if(enviroment)
				enviroment.adjust(o2, co2, n2, plasma)

	heat
		name = "Exothermic"
		mutationtype = "aggressive"
		nostack = 1
		weight = 5

		var/temperature

		New()
			..()
			if(!temperature)
				temperature = rand(1,50) * 100

		get_description()
			return "Emits short bursts of heat of up to [temperature]K"

		life(var/obj/effect/plantvine/vine)
			if(!vine) return 0

			var/turf/T = get_turf(vine)

			if(!T) return

			T.hotspot_expose(temperature,500,1)

	bioluminosity
		name = "Bioluminosity"
		mutationtype = "cosmetic"

		var/redglow = 0
		var/greenglow = 0
		var/blueglow = 0
		var/maxglow = 0

		weight = 15

		nostack = 1
		additivestack = 1

		get_description()
			var/glowstrength = get_glowstrength()
			var/glowcolor = get_glowcolor()

			return "Glows [glowstrength][glowcolor]in darkness"

		proc/get_glowstrength()
			var/glow = min((redglow + greenglow + blueglow) / 3, maxglow)

			switch(glow)
				if(0.1 to 1) return "dimly "
				if(1 to 2) return ""
				if(2 to 4) return "brightly "
				if(4 to INFINITY) return "very brightly "

		proc/get_glowcolor()
			if(redglow == greenglow && greenglow == blueglow)
				return ""
			else if(redglow == greenglow && redglow > blueglow)
				return "yellowish "
			else if(redglow == blueglow && blueglow > greenglow)
				return "magentaish "
			else if(blueglow == greenglow && greenglow > redglow)
				return "cyanish "
			else if(redglow > greenglow && redglow > blueglow)
				return "reddish "
			else if(greenglow > redglow && greenglow > blueglow)
				return "greenish "
			else if(blueglow > greenglow && blueglow > redglow)
				return "bluish "

			return ""

		addstack(var/datum/plantmutation/bioluminosity/mut)
			if(!mut) return

			redglow += mut.redglow
			greenglow += mut.greenglow
			blueglow += mut.blueglow
			maxglow = round((maxglow + mut.maxglow) * 0.75)

		life(var/obj/effect/plantvine/vine)
			if(!vine) return 0

			if(isturf(vine.loc) && vine.LuminosityBlue)
				set_bioluminosity(vine)
			else
				set_bioluminosity(vine.loc)

		proc/set_bioluminosity(var/atom/A)
			var/r = min(maxglow,redglow)
			var/g = min(maxglow,greenglow)
			var/b = min(maxglow,blueglow)

			if(A.LuminosityRed != r || A.LuminosityGreen != g || A.LuminosityBlue != b)
				A.ul_SetLuminosity(r, g, b)

	radiates		//Radiates nearby mobs
		name = "Radioactive"
		mutationtype = "aggressive"
		nostack = 1
		additivestack = 1
		weight = 2

		var/rate = 0.2

		New()
			rate = rand(10,180) / 100

		get_description()
			return "Irradiates nearby objects at [rate]sv per cycle" //This is probably demonstrably wrong.

		addstack(var/datum/plantmutation/radiates/mut)
			if(!mut) return

			rate += mut.rate

	proc/get_aggression(var/aggr)
		switch(aggr)
			if(0) return "Doesn't"
			if(1 to 15) return "Harmlessly"
			if(15 to 30) return "Sometimes"
			if(30 to 50) return "Regularly"
			if(50 to 60) return "Often"
			if(70 to 80) return "Aggressively"
			if(80 to 90) return "Very aggressively"
			if(90 to INFINITY) return "Extremely aggressively"

	entangling		//Entangles mobs
		name = "Entangling"
		mutationtype = "aggressive"
		weight = 5

		var/aggressiveness = 10

		get_description()
			var/aggrtext = get_aggression(aggressiveness)

			return "[aggrtext] entangles close lifeforms."

		life(var/obj/effect/plantvine/vine)
			if(prob(aggressiveness))
				vine.grab()

	uprooting		//Radiates nearby mobs
		name = "Uprooting"
		mutationtype = "aggressive"
		weight = 10

		var/rate = 10

		get_description()
			var/aggrtext = get_aggression(rate)

			return "[aggrtext] uproots floortiles."

		New()
			rate = rand(1,100)

	carnivore	//Eats pests
		name = "Carnivore"
		mutationtype = "growth"
		nostack = 1
		weight = 25

		get_description()
			return "Devours pests in its tray for nutrients."

		life(var/obj/effect/plantvine/vine)
			var/obj/machinery/hydrotray/plantedtray = vine.get_tray()

			if(plantedtray && plantedtray.pestlevel > 0)
				vine.plant.nutrientlevel += 10
				plantedtray.pestlevel--

		biter	//Bites nearby mobs, dealing brute damage
			name = "Biting"
			mutationtype = "aggressive"
			additivestack = 1
			weight = 20

			var/aggressiveness = 10 //Chance to lash
			var/maxmouth

			New()
				..()
				if(!maxmouth)
					maxmouth = rand(1,4)

			get_description()
				var/aggrtext = get_aggression(aggressiveness)

				return "[aggrtext] bites nearby creatures. " + ..()

			addstack(var/datum/plantmutation/carnivore/biter/mut)
				if(!mut) return

				aggressiveness += mut.aggressiveness

			life(var/obj/effect/plantvine/vine)
				..()

				for(var/mob/living/carbon/human/M in range(1,vine))
					if(prob(aggressiveness))
						vine.bite(M)

			devourer
				name = "Flesh-eating"
				mutationtype = "aggressive"
				weight = 15

				get_description()
					return "Devours dead creatures in close contact. " + ..()

				life(var/obj/effect/plantvine/vine)
					..()

					if(prob(aggressiveness))
						vine.devour()

	lasher		//Lashes out at nearby mobs, dealing brute damage
		name = "Lashing"
		mutationtype = "aggressive"
		nostack = 1
		additivestack = 1
		weight = 40

		var/aggressiveness = 10 //Chance to lash
		var/lashes = 1

		get_description()
			var/aggrtext = get_aggression(aggressiveness)

			return "[aggrtext] lashes at nearby creatures and plants."

		addstack(var/datum/plantmutation/lasher/mut)
			if(!mut) return

			aggressiveness += mut.aggressiveness

		life(var/obj/effect/plantvine/vine)
			..()

			for(var/mob/living/carbon/human/M in range(1,vine))
				if(prob(aggressiveness))
					vine.lash(M,lashes)

	volatile
		name = "Volatile"
		mutationtype = "aggressive"
		weight = 0

		var/range = 1
		var/volatility = 10		//Chance of detonation
		var/plantexplodes = 0	//Plant explodes
		var/fruitexplodes = 0	//Fruit explodes
		var/idleexplodes = 0	//Explodes without provocation

		productlife(var/atom/product)
			..()

			if(!fruitexplodes) return

			var/willexplode = prob(volatility * plant.potency)
			if(!willexplode) return

			if(idleexplodes)
				detonate(product)

		process(var/atom/processor,var/atom/product)
			..()

			if(!fruitexplodes) return

			var/willexplode = prob(volatility * plant.potency)
			if(!willexplode) return

			detonate(product)

		proc/detonate(var/atom/product)
			del(product)


		true		//Actual bomb explosion THIS SHOULD BE HELLA RARE HOLY FUCK
			name = "Highly Explosive"
			weight = 1

			detonate(var/atom/product)
				var/turf/T = get_turf(product)

				if(T) explosion(T, -1, round(range / 2), round(range), round(range+1))

				..()

		smoke		//Just chemsmoke. phew.
			name = "High Content Pressure"
			weight = 10

			detonate(var/atom/product)
				var/turf/T = get_turf(product)
				var/datum/reagents/holder = product.reagents

				var/datum/effect/effect/system/chem_smoke_spread/S = new /datum/effect/effect/system/chem_smoke_spread
				S.attach(T)
				S.set_up(holder, 10, 0, T)
				playsound(T, 'smoke.ogg', 50, 1, -3)
				spawn(0)
					S.start()
					sleep(10)
					S.start()

				..()


		foam		//Chemical foam.
			name = "High Liquid Pressure"
			weight = 10

			detonate(var/atom/product)
				var/turf/T = get_turf(product)
				var/datum/reagents/holder = product.reagents

				if(!holder) return

				var/datum/effect/effect/system/foam_spread/s = new()
				s.set_up(holder.total_volume, T, holder, 0)
				s.start()

				..()