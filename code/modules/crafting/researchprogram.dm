datum/researchprogram
	var/name
	var/desc
	var/totalresearchtime
	var/researchtime = 0
	var/list/prereqs = list()
	var/tech = ""
	var/switching = 0
	var/unlocked
	var/enabled
	var/autoenable

	New()
		totalresearchtime = researchtime

	proc/unlock(var/obj/machinery/algorithm_server/aserv)
		unlocked = 1

		if(autoenable)
			enable()

	proc/enable()
		enabled = 1

	proc/disable()
		enabled = 0

	recipe
		name = "Construction Research (Random Recipe)"
		desc = "All recipe research completed."
		researchtime = 200
		var/recipetech

		enable()
			return

		disable()
			return

		unlock(var/obj/machinery/algorithm_server/aserv)
			var/list/possiblerecipes = list()
			var/datum/assemblerprint/chosenrecipe

			possiblerecipes = getpotentialrecipes(recipetech, aserv.possiblerecipes)

			if(possiblerecipes.len)
				chosenrecipe = pick(possiblerecipes)

			if(chosenrecipe)
				aserv.possiblerecipes += chosenrecipe
				researchtime = initial(researchtime)
			else
				unlocked = 1
				enabled = -1

		proc/getpotentialrecipes(techfilter,var/list/recipefilter)
			var/list/possiblerecipes = list()
			var/first = 1

			for(var/datum/assemblerprint/assprint in assembler_recipes)
				if(!first && !prob(assprint.simplicity)) continue
				if(assprint in recipefilter) continue
				if(!recipetech || assprint.tech == recipetech)
					possiblerecipes += assprint
					first = 0

			return possiblerecipes

		civilianrecipe
			name = "Civil Research (Random Recipe)"
			desc = "All civil recipe research completed."
			prereqs = list(/datum/researchprogram/recipe)
			researchtime = 80
			recipetech = "civilian"

		medicalrecipe
			name = "Medical Research (Random Recipe)"
			desc = "All medical recipe research completed."
			prereqs = list(/datum/researchprogram/recipe)
			researchtime = 80
			recipetech = "medical"

		engineeringrecipe
			name = "Engineering Research (Random Recipe)"
			desc = "All engineering recipe research completed."
			prereqs = list(/datum/researchprogram/recipe)
			researchtime = 80
			recipetech = "engineering"

		securityrecipe
			name = "Security Research (Random Recipe)"
			desc = "All security recipe research completed."
			prereqs = list(/datum/researchprogram/recipe)
			researchtime = 80
			recipetech = "security"

		miningrecipe
			name = "Mining Research (Random Recipe)"
			desc = "All mining recipe research completed."
			prereqs = list(/datum/researchprogram/recipe)
			researchtime = 80
			recipetech = "mining"

		roboticsrecipe
			name = "Robotics Research (Random Recipe)"
			desc = "All robotics recipe research completed."
			prereqs = list(/datum/researchprogram/recipe)
			researchtime = 80
			recipetech = "robotics"



datum/researchprogram/upgrade
	var/upgradetype
	var/upgradeaddition
	var/upgrademultiplier
	var/datum/upgrade/currentupgrade
	autoenable = 1

	enable()
		var/datum/upgrade/u = new(upgradetype, upgradeaddition, upgrademultiplier)
		upgrades += u
		currentupgrade = u
		..()

	disable()
		if(currentupgrade)
			upgrades -= currentupgrade
		..()

	researchspeed1
		name = "Optimization"
		desc = "All Algorithm Servers run their calculations 40% quicker."
		researchtime = 200
		upgradetype = "research_speed"
		upgradeaddition = 0.4

	researchspeed2
		name = "Concurrent Processing"
		desc = "Multithreading allows the Servers to calculate at 200% speed."
		researchtime = 400
		prereqs = list(/datum/researchprogram/upgrade/researchspeed1)
		upgradetype = "research_speed"
		upgrademultiplier = 2.0

	researchspeed3
		name = "Quantum Heisen Debugging"
		desc = "Ancient technology another Research Algorithms +80% speed increase."
		researchtime = 800
		prereqs = list(/datum/researchprogram/upgrade/researchspeed2)
		upgradetype = "research_speed"
		upgradeaddition = 0.8

	researchspeed4
		name = "Field Studies"
		desc = "Field studies in the fields of informatics and data science grant an extra +60% boost to research speed."
		researchtime = 900
		prereqs = list(/datum/researchprogram/upgrade/researchspeed3)
		upgradetype = "research_speed"
		upgradeaddition = 0.6

	researchspeed5
		name = "NP=P"
		desc = "The agelong question has finally been solved. Now we can optimize our algorithms to run at double the speed!"
		researchtime = 1000
		prereqs = list(/datum/researchprogram/upgrade/researchspeed4)
		upgradetype = "research_speed"
		upgrademultiplier = 2.0

	assemblerspeed1
		name = "Fast Finishing"
		desc = "All Assemblers work at 120% efficiency."
		researchtime = 100
		upgradetype = "assembler_speed"
		upgrademultiplier = 1.2

	assemblerspeed2
		name = "Low-Energy Assembly Laser"
		desc = "All Assemblers work at an additional +10% efficiency."
		researchtime = 200
		prereqs = list(/datum/researchprogram/upgrade/assemblerspeed1)
		upgradetype = "assembler_speed"
		upgradeaddition = 0.1

	assemblerspeed3
		name = "Fully Automated Analysis And Optimization."
		desc = "All Assemblers work at 150% efficiency"
		researchtime = 400
		prereqs = list(/datum/researchprogram/upgrade/assemblerspeed2)
		upgradetype = "assembler_speed"
		upgrademultiplier = 1.5

	mechspeed1
		name = "Walker Servomotor Overdrive"
		desc = "All Exosuits have their speed increased to 120%."
		researchtime = 200
		upgradetype = "mech_speed"
		upgrademultiplier = 1.2

	mechspeed2
		name = "Longer Step Algorithms"
		desc = "Bigger steps mean a +40% speed increase."
		researchtime = 400
		prereqs = list(/datum/researchprogram/upgrade/mechspeed1)
		upgradetype = "mech_speed"
		upgradeaddition = 0.4

	mechspeed3
		name = "Improved Inverse Kinematics"
		desc = "Professor J.Khurch's breakthroughs in this area allow for a fantastic +60% increase in mech walking speed."
		researchtime = 700
		prereqs = list(/datum/researchprogram/upgrade/mechspeed2)
		upgradetype = "mech_speed"
		upgradeaddition = 0.6

	maraudersmoke1
		name = "Marauder Chaff Ejection Optimizer"
		desc = "All Marauders can recharge their smoke ejection 20% quicker."
		researchtime = 500
		upgradetype = "mech_smoke_speed"
		upgradeaddition = 0.2

	nerf
		autoenable = 0

		throttle_mechspeed1
			name = "Walker Servomotor Throttle"
			desc = "All Exosuits have their speed reduced to 80%."
			researchtime = 300
			upgradetype = "mech_speed"
			upgrademultiplier = 0.8

		throttle_mechspeed2
			name = "'Shackles' Experimental Anti-Mobility Virus"
			desc = "Exosuits move at a debilitating 10% of their usual speed."
			researchtime = 5000
			prereqs = list(/datum/researchprogram/upgrade/nerf/throttle_mechspeed1)
			upgradetype = "mech_speed"
			upgrademultiplier = 0.1