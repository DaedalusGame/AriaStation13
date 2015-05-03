var/list/plants = list()

proc/populate_seed_list()
	plants.Cut()

	var/list/types = typesof(/datum/seed) - /datum/seed

	for(var/seedtype in types)
		var/datum/seed/S = new seedtype()

		plants[S.plantid] = S


/datum/seed
	var/plantname = "Plants"		//Name of plant when planted.
	var/plantid = ""
	var/species = ""				//Used to update icons. Should match the name in the sprites.
	var/product						//A type path. The thing that is created when the plant is harvested.
	var/product_cut
	var/product_fell
	var/plant_type = 0				//0 = 'normal plant'; 1 = shroom; 2 = weed; 3 = tree; 4 = grass
	var/rarity = 0					//How rare the plant is. Used for giving points to cargo when shipping off to Centcom.

	var/generation = 1				//Increases by one every time it mutates

	//var/health = 100				//How healthy the plant is
	var/endurance = 100 			//Amount of health the plant has.
	//var/dead = 0

	var/potency = 0				//The 'power' of a plant. Generally effects the amount of reagent in a plant, also used in other ways.
	var/size = 1					//How big the products of the plant are
	var/lifespan = 0 				//How long before the plant begins to take damage from age.

	var/age = 0
	var/maturation = 1 				//Used to determine which sprite to switch to when growing.
	//var/growthtime = 0				//Amount of growth sprites the plant has.

	var/production = 0 				//Changes the amount of time needed for a plant to become harvestable.

	//var/canharvest = 0
	var/yield = 0					//Amount of growns created per harvest. If is -1, the plant/shroom/weed is never meant to be harvested.
	var/oneharvest = 0				//If a plant is cleared from the tray after harvesting, e.g. a carrot.
	var/sterilerate = 80

	var/drinkspeed = 3

	var/lastmutation = 0
	var/mutationdelay = 200

	var/waterlevel = 0
	var/nutrientlevel = 0
	var/mutationlevel = 0
	var/toxinlevel = 0

	var/requireslattice = 1
	var/spreadwall = 0
	var/spreadspeed = 0
	var/collapsesize = 250
	var/slowdownsize = 30

	var/waterrequirement = 0.1
	var/nutrientrequirement = 0.05

	var/list/basemutations = list()

	var/list/mutations = list()
	var/list/basecolors = list("stem" = "#00FF00","0" = "#FFFFFF")
	var/list/colors = list()
	var/unripecolor = "#22FF00"
	var/deadcolor = "#555511"

	var/evopoints = 0
	var/nextevolevel = 0

	//List of chems that can be used as nutrients for this plant
	//
	var/list/nutrients = list("milk" = 0.1,			//sugarwater
							"phosphorus" = 0.1,		//bleh
							"sugar" = 0.1,			//sugar
							"beer" = 0.25,			//apparently because it's dorfy
							"sodawater" = 0.1,		//shittier sugarwater
							"ammonia" = 1.0,		//badass
							"diethylamine" = 2.0,	//badass fertilizer
							"nutriment" = 1.0,		//obvious
							"adminordrazine" = 1.0) //MIGHT AS WELL

	//List of chems that can be used as water for this plant
	//
	var/list/waters = list("water" = 1.0,
							"milk" = 0.9,
							"beer" = 0.75,
							"sodawater" = 0.9,
							"adminordrazine" = 1.0)

	//List of chems that can be used to mutate this plant
	//
	var/list/mutagens = list("mutagen" = 1.0, 		//Obvious.
							"radium" = 0.5,			//Poor man's mutagen
							"clonexadone" = -0.8)	//This stabilizes DNA

	//List of chems that kill the plant
	//
	var/list/toxins = list("toxin" = 1.0,			//Duh
							"acid" = 1.5,			//Duh
							"pacid" = 4.5,			//DUH
							"chlorine" = 1.0,		//Still duh
							"flourine" = 1.0,		//Yepp
							"radium" = 0.5,			//Radiates the crop
							"antitoxin" = -1.0,		//Removes toxin, duh.
							"plantbgone" = 5.0,		//Kills the plant really quickly
							//"cryoxadone" = -0.8,	//Only makes sense if plant is in cold enviroment
							"clonexadone" = -0.8)	//Restores tissue

	var/list/possiblemutations = list()
	/*var/list/possiblemutations = list(
		//Basic
		/datum/plantmutation/reagent = 180,
		/datum/plantmutation/reagent/seeping = 60,
		/datum/plantmutation/discoloration = 180,
		//Fucked it up, can't mutate any more
		/datum/plantmutation/immutable = 15,
		//Hostile
		/datum/plantmutation/volatile/true = 5,
		/datum/plantmutation/volatile/smoke = 25,
		/datum/plantmutation/volatile/foam = 25,
		/datum/plantmutation/radiates = 15,
		/datum/plantmutation/lasher = 30,
		/datum/plantmutation/traytakeover = 30
		)*/


	//var/obj/machinery/hydrotray/plantedtray

	New()
		..()

		possiblemutations = get_possible_mutations()

		for(var/muttype in basemutations)
			addmutation(new muttype())

		nextevolevel = maturation

		update_icon()

	proc/life(var/obj/effect/plantvine/vine)
		if(!vine || !vine.master) return

		var/obj/machinery/hydrotray/plantedtray = vine.get_tray()

		for(var/datum/plantmutation/mut in mutations)
			mut.life(vine)

		if(vine.dead) return

		if(vine.growthage > nextevolevel)
			nextevolevel += maturation
			evopoints++

		drink()

		//if(age > maturation) //We can harvest the plant if it ages beyond its maturity
			//canharvest = 1
			//age = maturation

		//if(generation > lifespan) //Eventually, the plant dies
			//health -= generation - lifespan

		if(waterlevel < waterrequirement)
			vine.health -= rand(1,3)

		if(nutrientlevel < nutrientrequirement)
			vine.health -= rand(1,3)

		if(waterlevel > waterrequirement && nutrientlevel > nutrientrequirement)
			vine.health += rand(0,2)

		if(toxinlevel)
			vine.health -= rand(1,3)
			toxinlevel -= 1

		if(plantedtray && plantedtray.pestlevel > 5)
			vine.health -= rand(1,3)

		waterlevel -= waterrequirement
		nutrientlevel -= nutrientrequirement

		if(mutationlevel >= 15)
			mutationlevel -= 15
			vine.mutate()

		waterlevel = max(0,waterlevel)
		nutrientlevel = max(0,nutrientlevel)
		toxinlevel = max(0,toxinlevel)
		mutationlevel = max(0,mutationlevel)

		//if(health <= 0)
		//	health = 0
		//	dead = 1

	//Drink chemicals from the tray
	proc/drink(var/obj/effect/plantvine/vine)
		if(!vine || !vine.master) return

		var/obj/machinery/hydrotray/plantedtray = vine.get_tray()

		if(!plantedtray) return

		for(var/datum/plantmutation/mut in mutations)
			mut.drink(plantedtray.reagents)

		var/nutrient = 0
		var/water = 0
		var/mutagen = 0
		var/toxin = 0

		for(var/datum/reagent/R in plantedtray.reagents.reagent_list)
			if(R.id in nutrients)
				nutrient += R.volume * nutrients[R.id]
			if(R.id in waters)
				water += R.volume * waters[R.id]
			if(R.id in toxins)
				toxin += R.volume * toxins[R.id]
			if(R.id in mutagens)
				mutagen += R.volume * mutagens[R.id]

		waterlevel += min(water,drinkspeed)
		nutrientlevel += min(nutrient,drinkspeed)
		mutationlevel += min(mutagen,drinkspeed)
		toxinlevel += min(toxin,drinkspeed)

		//if(nutrient < 1)
		//	health -= 1

		//if(water < 1)
		//	health -= 1

		//if(toxin >= 1)
		//	health -= max(-10,min(toxin,10))

		/*if(mutagen > 10 && world.time > lastmutation + mutationdelay)
			var/muttype = pickweight(possiblemutations)
			var/datum/plantmutation/mut = new muttype()
			mutate(mut)*/


		plantedtray.reagents.remove_any(drinkspeed)

	proc/copy()
		var/datum/seed/S = new type()

		S.plantname = plantname
		S.species = species
		S.product = product
		S.product_cut = product_cut
		S.product_fell = product_fell
		//S.growthstages = growthstages
		S.plant_type = plant_type
		S.rarity = rarity

		S.generation = generation
		//S.health = health
		S.lifespan = lifespan
		S.endurance = endurance
		S.maturation = maturation
		S.production = production
		S.yield = yield
		S.oneharvest = oneharvest
		S.potency = potency

		S.drinkspeed = drinkspeed

		S.requireslattice = requireslattice
		S.spreadwall = spreadwall
		S.spreadspeed = spreadspeed
		S.collapsesize = collapsesize
		S.slowdownsize = slowdownsize
		S.sterilerate = sterilerate

		S.waterrequirement = waterrequirement
		S.nutrientrequirement = nutrientrequirement

		S.waterlevel = waterlevel
		S.nutrientlevel = nutrientlevel
		S.mutationlevel = mutationlevel
		S.toxinlevel = toxinlevel

		S.basecolors = basecolors.Copy()
		S.mutations = copymutations()

		S.unripecolor = unripecolor
		S.deadcolor = deadcolor

		S.nutrients = nutrients
		S.waters = waters
		S.mutagens = mutagens
		S.toxins = toxins

		S.evopoints = evopoints
		S.nextevolevel = nextevolevel

		S.update_icon()

		return S

	proc/crossbreed(var/datum/seed/S2)
		var/datum/seed/S1 = src
		var/datum/seed/S = new type()

		var/N1 = lentext(S1.plantname)
		var/N2 = lentext(S2.plantname)

		S.plantname = copytext(S1.plantname,0,N1/2) + copytext(S2.plantname,-N2/2)
		S.species = pick(S1.species,S2.species)
		S.product = pick(S1.product,S2.product)
		S.product_cut = pick(S1.product_cut,S2.product_cut)
		S.product_fell = pick(S1.product_fell,S2.product_fell)
		//S.growthstages = S1.growthstages
		S.plant_type = pick(S1.plant_type,S2.plant_type)
		S.rarity = (S1.rarity + S2.rarity) * 0.75

		S.generation = 1 //This is a new plant
		//S.health = (S1.health + S2.health) * 0.5
		S.lifespan = (S1.lifespan + S2.lifespan) * 0.75
		S.endurance = (S1.endurance + S2.endurance) * 0.75
		S.maturation = (S1.maturation + S2.maturation) * 0.5
		S.production = (S1.production + S2.production) * 0.5
		S.yield = (S1.yield + S2.yield) * 0.75
		S.oneharvest = pick(S1.oneharvest,S2.oneharvest)
		S.potency = (S1.potency + S2.potency) * 0.75

		S.drinkspeed = (S1.drinkspeed + S2.drinkspeed) * 0.5

		S.requireslattice = pick(S1.requireslattice,S2.requireslattice)
		S.spreadwall = pick(S1.spreadwall,S2.spreadwall)
		S.spreadspeed = (S1.spreadspeed + S2.spreadspeed) * 0.5
		S.collapsesize = (S1.collapsesize + S2.collapsesize) * 0.5
		S.slowdownsize = (S1.slowdownsize + S2.slowdownsize) * 0.5
		S.sterilerate = (S1.sterilerate + S2.sterilerate) * 0.5

		S.waterrequirement = (S1.waterrequirement + S2.waterrequirement) * 0.5
		S.nutrientrequirement = (S1.nutrientrequirement + S2.nutrientrequirement) * 0.5

		S.waterlevel = S1.waterlevel + S2.waterlevel
		S.nutrientlevel = S1.nutrientlevel + S2.nutrientlevel
		S.mutationlevel = S1.mutationlevel + S2.mutationlevel
		S.toxinlevel = S1.toxinlevel + S2.toxinlevel

		var/list/colors = pick(S1.basecolors,S2.basecolors)

		S.basecolors = colors.Copy()
		S.mutations = S1.copymutations() + S2.copymutations()

		S.unripecolor = pick(S1.unripecolor,S2.unripecolor)
		S.deadcolor = pick(S1.deadcolor,S2.deadcolor)

		S.nutrients = pick(S1.nutrients,S2.nutrients)
		S.waters = pick(S1.waters,S2.waters)
		S.mutagens = pick(S1.mutagens,S2.mutagens)
		S.toxins = pick(S1.toxins,S2.toxins)

		S.evopoints = min(S1.evopoints,S2.evopoints)
		S.nextevolevel = min(S1.nextevolevel,S2.nextevolevel)

		S.update_icon()

		return S


	proc/get_possible_mutations()
		var/list/rlist = list()

		for(var/muttype in typesof(/datum/plantmutation) - /datum/plantmutation)
			var/datum/plantmutation/testmut = new muttype()

			if(testmut.weight)
				rlist[muttype] = testmut.weight

		return rlist

	proc/copymutations(var/datum/seed/P)
		var/list/rlist = list()

		for(var/datum/plantmutation/mut in mutations)
			rlist += mut.copy(P)

		return rlist

	proc/mutate(var/datum/plantmutation/mut)
		if(locate(/datum/plantmutation/immutable) in mutations)
			return src

		var/datum/seed/S = copy()

		S.addmutation(mut)
		S.generation++

		return S

	proc/addmutation(var/datum/plantmutation/mut)
		if(mut in mutations) return

		mutations += mut
		mut.plant = src

		mut.mutate()

	proc/removemutation(var/datum/plantmutation/mut)
		if(mut in mutations)
			mutations -= mut
			mut.demutate()
			del(mut)

	proc/hasmutation(var/muttype)
		if(locate(muttype) in mutations)
			return 1

		return 0

	proc/canharvest()
		return age > maturation

	proc/harvest(var/obj/effect/plantvine/vine,var/atom/user)
		var/datum/seed/S = copy()
		S.generation++

		for(var/datum/plantmutation/mut in mutations)
			mut.harvest(user)

		for(var/i=0, i<yield, i++)
			producefruit(get_turf(vine))

		return S

	proc/consume(var/atom/user,var/atom/product)
		for(var/datum/plantmutation/mut in mutations)
			mut.consume(user,product)

	proc/producefruit(var/atom/location)
		if(!location) return

		var/atom/PA

		if(product)
			PA = new product(location)
			PA:parentplant = src
			PA:update_icon()

		return PA


	proc/update_icon()
		colors = basecolors.Copy()

		for(var/datum/plantmutation/mut in mutations)
			if(mut.colorid && mut.color)
				if(!colors[mut.colorid])
					colors[mut.colorid] = mut.color
				else
					colors[mut.colorid] = BlendRGBasHSV(colors[mut.colorid],mut.color,0.5)


/obj/item/seed
	name = "seed"
	icon = 'seeds.dmi'
	icon_state = "seed" // unknown plant seed - these shouldn't exist in-game
	flags = FPRINT | TABLEPASS
	w_class = 1.0 // Makes them pocketable
	var/basename = ""
	var/mypath = "/obj/item/seed"
	var/datum/seed/internal
	var/defaultplant
	var/seedamt = 1

	New()
		..()

		if(defaultplant)
			internal = plants[defaultplant]

		name = "[basename][internal.plantname] [seedamt>0 ? "seeds" : "seed"]"

	packet
		seedamt = 10
		icon_state = "seed-generic"
		basename = "packet of "

		chili
			icon_state = "seed-chili"
			defaultplant = "chili"

		eggplant
			icon_state = "seed-eggplant"
			defaultplant = "eggplant"

		tomato
			icon_state = "seed-tomato"
			defaultplant = "tomato"

		potato
			icon_state = "seed-potato"
			defaultplant = "potato"

		banana
			icon_state = "seed-banana"
			defaultplant = "banana"

		grass
			icon_state = "seed-grass"
			defaultplant = "grass"

		wheat
			icon_state = "seed-wheat"
			defaultplant = "wheat"

		plasmapod
			//icon_state = "seed-wheat"
			defaultplant = "plasmapod"

		kudzu
			//icon_state = "seed-wheat"
			defaultplant = "kudzu"

		maneater
			//icon_state = "seed-wheat"
			defaultplant = "maneater"

		mold
			//icon_state = "seed-wheat"
			defaultplant = "mold"