// -------------------------------------
//    Not yet identified chemical.
//        Could be anything!
// -------------------------------------

/obj/item/weapon/reagent_containers/glass/bottle/random_reagent
	name = "Unlabelled Bottle"
	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/bottle/B = new(loc)
		var/datum/reagent/R = pick(chemical_reagents_list)
		var/global/list/rare_chems = list("nanites","xenomicrobes","adminordrazine")
		if(rare_chems.Find(R))
			B.reagents.add_reagent(R,10)
		else
			B.reagents.add_reagent(R,rand(2,3)*10)
		B.name = "Unlabelled Bottle"
		B.pixel_x = rand(-10,10)
		B.pixel_y = rand(-10,10)
		spawn(1)
			del src

//Cuts out the food and drink reagents
/obj/item/weapon/reagent_containers/glass/bottle/random_chem
	name = "Unlabelled Chemical"
	New()
		var/global/list/chems_only = list("metroid","blood","water","lube","anti_toxin","toxin","cyanide","stoxin","stoxin2","inaprovaline","space_drugs","serotrotium","oxygen","copper","nitrogen","hydrogen","potassium","mercury","sulfur","carbon","chlorine","fluorine","sodium","phosphorus","lithium","sugar","acid","pacid","glycerol","radium","ryetalyn","thermite","mutagen","virusfood","iron","gold","silver","uranium","aluminum","silicon","fuel","cleaner","plantbgone","plasma","leporazine","cryptobiolin","lexorin","kelotane","dermaline","dexalin","dexalinp","tricordrazine","synaptizine","impedrezene","hyronalin","arithrazine","alkysine","imidazoline","bicaridine","hyperzine","cryoxadone","clonexadone","spaceacillin","carpotoxin","zombiepowder","fluorosurfactant","foaming_agent","nicotine","ethanol","ammonia","diethylamine","ethylredoxrazine","chloralhydrate","lipozine","condensedcapsaicin","frostoil","amatoxin","psilocybin","enzyme","nothing","doctorsdelight","antifreeze","neurotoxin")
		var/global/list/rare_chems = list("nanites","xenomicrobes","adminordrazine")

		var/obj/item/weapon/reagent_containers/glass/bottle/B = new(loc)
		var/datum/reagent/R = pick(chems_only + rare_chems)
		if(rare_chems.Find(R))
			B.reagents.add_reagent(R,10)
		else
			B.reagents.add_reagent(R,rand(2,3)*10)
		B.name = "Unlabelled Bottle"
		B.pixel_x = rand(-10,10)
		B.pixel_y = rand(-10,10)
		spawn(1)
			del src

/obj/item/weapon/reagent_containers/glass/bottle/random_good_chem
	name = "Labelled Chemical"
	New()
		var/global/list/chems_only = list("metroid","blood","water","lube","anti_toxin","toxin","cyanide","stoxin","stoxin2","inaprovaline","space_drugs","serotrotium","oxygen","copper","nitrogen","hydrogen","potassium","mercury","sulfur","carbon","chlorine","fluorine","sodium","phosphorus","lithium","sugar","acid","pacid","glycerol","radium","ryetalyn","thermite","mutagen","virusfood","iron","gold","silver","uranium","aluminum","silicon","fuel","cleaner","plantbgone","plasma","leporazine","cryptobiolin","lexorin","kelotane","dermaline","dexalin","dexalinp","tricordrazine","synaptizine","impedrezene","hyronalin","arithrazine","alkysine","imidazoline","bicaridine","hyperzine","cryoxadone","clonexadone","spaceacillin","carpotoxin","zombiepowder","fluorosurfactant","foaming_agent","nicotine","ethanol","ammonia","diethylamine","ethylredoxrazine","chloralhydrate","lipozine","condensedcapsaicin","frostoil","amatoxin","psilocybin","enzyme","nothing","doctorsdelight","antifreeze","neurotoxin")
		var/global/list/rare_chems = list()

		var/obj/item/weapon/reagent_containers/glass/bottle/B = new(loc)
		var/datum/reagent/R = pick(chems_only + rare_chems)
		if(rare_chems.Find(R))
			B.reagents.add_reagent(R,10)
		else
			B.reagents.add_reagent(R,rand(2,3)*10)
		B.name = "[B.reagents.get_master_reagent_name()] Bottle"
		B.pixel_x = rand(-10,10)
		B.pixel_y = rand(-10,10)
		spawn(1)
			del src

/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink
	name = "Unlabelled Drink"
	New()
		var/list/drinks_only = list("beer2","hot_coco","orangejuice","tomatojuice","limejuice","carrotjuice","berryjuice","poisonberryjuice","watermelonjuice","lemonjuice","banana","nothing","potato","milk","soymilk","cream","coffee","tea","icecoffee","icetea","cola","nuka_cola","spacemountainwind","thirteenloko","dr_gibb","space_up","lemon_lime","beer","whiskey","specialwhiskey","gin","rum","vodka","holywater","tequilla","vermouth","wine","tonic","kahlua","cognac","hooch","ale","sodawater","ice","bilk","atomicbomb","threemileisland","goldschlager","patron","gintonic","cubalibre","whiskeycola","martini","vodkamartini","whiterussian","screwdrivercocktail","booger","bloodymary","gargleblaster","bravebull","tequillasunrise","toxinsspecial","beepskysmash","doctorsdelight","irishcream","manlydorf","longislandicedtea","moonshine","b52","irishcoffee","margarita","blackrussian","manhattan","manhattan_proj","whiskeysoda","antifreeze","barefoot","snowwhite","demonsblood","vodkatonic","ginfizz","bahama_mama","singulo","sbiten","devilskiss","red_mead","mead","iced_beer","grog","aloe","andalusia","alliescocktail","soy_latte","cafe_latte","acidspit","amasec","neurotoxin","hippiesdelight","bananahonk","silencer","changelingsting","irishcarbomb","syndicatebomb","erikasurprise","driestmartini")
		drinks_only += list("chloralhydrate","cyanide","tricordrazine","blood")

		var/obj/item/weapon/reagent_containers/food/drinks/bottle/B = new(loc)
		var/datum/reagent/R = pick(drinks_only)
		B.reagents.add_reagent(R,B.volume)
		B.name = "Unlabelled Bottle"
		B.icon = 'icons/obj/drinks.dmi'
		B.icon_state = pick("alco-white","alco-green","alco-blue","alco-clear","alco-red")
		B.pixel_x = rand(-5,5)
		B.pixel_y = rand(-5,5)
		spawn(1)
			del src
/obj/item/weapon/reagent_containers/food/drinks/bottle/random_reagent // Same as the chembottle code except the container
	name = "Unlabelled Drink?"
	New()
		var/obj/item/weapon/reagent_containers/food/drinks/bottle/B = new(loc)
		var/datum/reagent/R = pick(chemical_reagents_list)
		var/global/list/rare_chems = list("nanites","xenomicrobes","adminordrazine")
		if(rare_chems.Find(R))
			B.reagents.add_reagent(R,10)
		else
			B.reagents.add_reagent(R,rand(3,10)*10)
		B.name = "Unlabelled Bottle"
		B.icon = 'icons/obj/drinks.dmi'
		B.icon_state = pick("alco-white","alco-green","alco-blue","alco-clear","alco-red")
		B.pixel_x = rand(-5,5)
		B.pixel_y = rand(-5,5)
		spawn(0)
			del src

/obj/item/weapon/storage/pill_bottle/random_meds
	name = "Unlabelled Pillbottle"
	desc = "The sheer recklessness of this bottle's existence astounds you."

	New()
		..()
		var/global/list/meds_only = list("blood","anti_toxin","toxin","cyanide","stoxin","stoxin2","inaprovaline","space_drugs","serotrotium","ryetalyn","mutagen","leporazine","cryptobiolin","lexorin","kelotane","dermaline","dexalin","dexalinp","tricordrazine","synaptizine","impedrezene","hyronalin","arithrazine","alkysine","imidazoline","bicaridine","hyperzine","spaceacillin","carpotoxin","zombiepowder","mindbreaker","nicotine","ethanol","ammonia","diethylamine","ethylredoxrazine","chloralhydrate","lipozine","condensedcapsaicin","frostoil","amatoxin","psilocybin","nothing","doctorsdelight","neurotoxin")
		var/global/list/rare_meds = list("nanites","xenomicrobes","adminordrazine")

		var/i = 1
		while(i < storage_slots)
			var/datum/reagent/R = pick(meds_only + rare_meds)
			var/obj/item/weapon/reagent_containers/pill/P = new(src)
			if(rare_meds.Find(R))
				P.reagents.add_reagent(R,10)
			else
				P.reagents.add_reagent(R,rand(2,5)*10)
			P.name = "Unlabelled Pill"
			P.desc = "Something about this pill entices you to try it, against your better judgement."
			i++
		pixel_x = rand(-10,10)
		pixel_y = rand(-10,10)
		return

/obj/item/weapon/storage/pill_bottle/random_good_meds
	name = "Labelled Pillbottle"
	desc = "Contains NT-regulated medicine. Or not."

	New()
		..()
		var/global/list/meds_only = list("anti_toxin","stoxin2","inaprovaline","serotrotium","ryetalyn","leporazine","cryptobiolin","lexorin","kelotane","dermaline","dexalin","dexalinp","tricordrazine","synaptizine","impedrezene","hyronalin","arithrazine","alkysine","imidazoline","bicaridine","hyperzine","spaceacillin","nicotine","diethylamine","ethylredoxrazine","lipozine")
		var/global/list/rare_meds = list()

		var/i = 1
		while(i < storage_slots)
			var/datum/reagent/R = pick(meds_only + rare_meds)
			var/obj/item/weapon/reagent_containers/pill/P = new(src)
			if(rare_meds.Find(R))
				P.reagents.add_reagent(R,10)
			else
				P.reagents.add_reagent(R,rand(2,5)*10)
			P.name = "[P.reagents.get_master_reagent_name()] Pill"
			i++
		pixel_x = rand(-10,10)
		pixel_y = rand(-10,10)
		return

/obj/item/weapon/storage/pill_bottle/unity_good_meds
	name = "Labelled Pillbottle"
	desc = "Contains NT-regulated medicine. Or not."

	New()
		..()
		var/global/list/meds_only = list("anti_toxin","stoxin2","inaprovaline","serotrotium","ryetalyn","leporazine","cryptobiolin","lexorin","kelotane","dermaline","dexalin","dexalinp","tricordrazine","synaptizine","impedrezene","hyronalin","arithrazine","alkysine","imidazoline","bicaridine","hyperzine","spaceacillin","nicotine","diethylamine","ethylredoxrazine","lipozine")
		var/global/list/rare_meds = list()

		var/bottlelabel = "Labelled"

		var/i = 1
		var/datum/reagent/R = pick(meds_only + rare_meds)
		while(i < storage_slots)
			var/obj/item/weapon/reagent_containers/pill/P = new(src)
			if(rare_meds.Find(R))
				P.reagents.add_reagent(R,10)
			else
				P.reagents.add_reagent(R,rand(2,5)*10)
			P.name = "[P.reagents.get_master_reagent_name()] Pill"
			bottlelabel = P.reagents.get_master_reagent_name()
			i++
		name = "[bottlelabel] Pillbottle"
		pixel_x = rand(-10,10)
		pixel_y = rand(-10,10)
		return

// -------------------------------------
//    Containers full of unknown crap
// -------------------------------------

/obj/structure/closet/secure_closet/unknownchemicals
	name = "Unlabelled Chemical Closet"
	desc = "Potentially dangerous chemicals closet."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(ACCESS_CHEMISTRY)

	New()
		..()
		sleep(2)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_chem(src)
		while(prob(50))
			new/obj/item/weapon/reagent_containers/glass/bottle/random_reagent(src)

		new/obj/item/weapon/storage/pill_bottle/random_meds(src)
		while(prob(25))
			new/obj/item/weapon/storage/pill_bottle/random_meds(src)
		return

/obj/structure/closet/secure_closet/knownchemicals
	name = "Labelled Chemical Closet"
	desc = "Standard issue chemicals closet."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(ACCESS_CHEMISTRY)

	New()
		..()
		sleep(2)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_good_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_good_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_good_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_good_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_good_chem(src)
		while(prob(50))
			new/obj/item/weapon/reagent_containers/glass/bottle/random_good_chem(src)

		new/obj/item/weapon/storage/pill_bottle/random_good_meds(src)
		while(prob(25))
			new/obj/item/weapon/storage/pill_bottle/random_good_meds(src)
		return

/obj/structure/closet/secure_closet/random_drinks
	name = "Unlabelled Booze"
	req_access = list(ACCESS_BAR)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

	New()
		..()
		sleep(2)
		new/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink(src)
		new/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink(src)
		new/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink(src)
		new/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink(src)
		new/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink(src)
		while(prob(25))
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/random_reagent(src)
		return

/datum/supply_packs/randomised/goodchemicals
	name = "White-market Medicine Grab Pack"
	num_contained = 6
	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/random_good_chem,
					/obj/item/weapon/storage/pill_bottle/random_good_meds)
	cost = 30
	containertype = /obj/structure/closet/crate/medical
	containername = "NT-regulated Chemicals Crate"
	access = ACCESS_CHEMISTRY

/datum/supply_packs/randomised/chemicals
	name = "Grey-market Chemicals Grab Pack"
	num_contained = 6
	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/random_reagent,
					/obj/item/weapon/reagent_containers/glass/bottle/random_chem,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/random_reagent,
					/obj/item/weapon/storage/pill_bottle/random_meds)
	cost = 100
	containertype = /obj/structure/closet/crate/secure
	containername = "Unregulated Chemicals Crate"
	access = ACCESS_CHEMISTRY
	contraband = 1