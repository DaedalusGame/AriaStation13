datum/objective/crew
	var/jobrequired = list()
	weight = 20

	get_weight(var/job)
		if(job in jobrequired)
			return weight
		return 0

	get_points(var/job)
		if(job in jobrequired)
			return weight
		else
			return weight*3.0 //This is never going to happen without admining.

	valvebomb
		jobrequired = list("Scientist")
		explanation_text = "Assemble a valve bomb."

		New()
			..()
			if(prob(66))
				explanation_text = "Assemble [rand(2,5)] valve-bombs."

	corobomb
		jobrequired = list("Scientist")
		explanation_text = "Assemble a coronium two-component bomb."

		New()
			..()
			if(prob(66))
				explanation_text = "Assemble [rand(2,3)] coronium two-component bombs."

	grenade
		jobrequired = list("Chemist")
		explanation_text = "Assemble a chemgrenade(tm)."

		New()
			..()
			if(prob(33))
				explanation_text = "Assemble [rand(2,3)] chemgrenades(tm)."

	mine
		jobrequired = list("Scientist","Assistant")
		explanation_text = "Mine x piece of y ore"

		New()
			..()

			var/possiblematerials = list("Iron","Gold","Silver","Plasma","Coal")
			var/possiblerare = list("Diamond","Uranium","Adamantine","Phazon")
			var/possibleammount = rand(5,50)

			if(prob(66))
				explanation_text = "Mine [possibleammount] pieces of [pick(possiblematerials)]."
			else
				explanation_text = "Mine some [pick(possiblerare)]."

	process
		jobrequired = list("Scientist","Assistant")
		explanation_text = "Process your minerals to x items."

		New()
			..()

			var/possiblematerials = list("metal sheets","plasma sheets","plasteel sheets","reinforced glass sheets","carbon plates")
			var/possiblerare = list("gold ingots","silver ingots","adamantine ingots","phazite plates")
			var/possibleammount = rand(5,50)
			var/possiblerareamt = rand(3,6)

			if(prob(66))
				explanation_text = "Process your minerals to [possibleammount] [pick(possiblematerials)]."
			else
				explanation_text = "Process your minerals to [possiblerareamt] [pick(possiblerare)]."

	getchem
		jobrequired = list("Scientist","Chemist","Bartender","Assistant")
		explanation_text = "Acquire x ammount of y chemical"

		New()
			..()
			var/possiblereagents = list("Adminordrazine","Metroid Jam","Space drugs","Polytrinic acid","Unstable mutagen","Phazon","Carpotoxin","Chloral Hydrate","Condensed Capsaicin")
			var/possiblecontainers = list("unit","bottle","beaker")
			var/possibleammount = rand(1,25)

			explanation_text = "Acquire [possibleammount == 1 ? "one" : possibleammount] [pick(possiblecontainers)][possibleammount != 1 ? "s" : ""] of [pick(possiblereagents)]"

	mixchem
		jobrequired = list("Chemist")
		explanation_text = "Mix x ammount of y chemical."

		New()
			..()
			var/possiblereagents = list("Polytrinic Acid","Tricordrazine","Space Lube","Kelotane","Dexalin","Lexorin","Tramadol","Dexalin Plus","Clonexadone","Cryoxadone","Hyperzine")
			var/possiblecontainers = list("bottle","beaker")
			var/possibleammount = rand(1,25)

			explanation_text = "Mix [possibleammount == 1 ? "one" : possibleammount] [pick(possiblecontainers)][possibleammount != 1 ? "s" : ""] of [pick(possiblereagents)]"

	nobomb
		jobrequired = list("Research Director","Scientist")
		explanation_text = "Your department has caused enough damage, do not build anymore bombs!"

	research
		jobrequired = list("Research Director","Scientist")
		explanation_text = "Research to the best of your ability."

		New()
			..()

			var/techs = list()

			for(var/tt in typesof(/datum/tech) - /datum/tech)
				var/datum/tech/te = new tt(src)
				techs += te.name

			explanation_text = "Research to [rand(2,6)] levels in [pick(techs)]."

	design
		jobrequired = list("Research Director","Scientist")
		explanation_text = "Research to the best of your ability."

		New()
			..()

			var/techs = list()

			for(var/D in typesof(/datum/design) - /datum/design)
				var/datum/design/de = new D(src)
				techs += de.name

			explanation_text = "Research and construct [pick(techs)]."

	backup
		jobrequired = list("Scientist","Research Director")
		explanation_text = "Backup all your research on disks and return with them to CentComm."

	nofire
		jobrequired = list("Scientist","Research Director","Chemist","Atmospheric Technician")
		explanation_text = "Make sure your department doesn't catch on fire."

	thenight
		jobrequired = list("Assistant","Head of Security","Head of Personnel")
		explanation_text = "Be the night."

		New()
			..()

			if(prob(20))
				explanation_text = "Stalk the maintenance tunnels and bring justice to the station."
			else
				explanation_text = "You are the [pick("night","law","owl","batman")]. Act like it."

	build
		jobrequired = list("Station Engineer","Chief Engineer","Atmospheric Technician")
		explanation_text = "Build and expand the station."

		New()
			..()

			var/possibletext = list("Build more storage rooms.",
			"Build more dorms.",
			"Refurnish destroyed rooms.",
			"Turn the cafeteria into a casino.",
			"Relocate all of RnD to the Mining Labs.",
			"Build a singularity engine.",
			"Build an incinerator in Waste Disposals.",
			"Repair any reported hullbreaches.")

			explanation_text = pick(possibletext)





	noescape
		jobrequired = list("Head of Personnel","Head of Security","Chief Engineer","Research Director","Chief Medical Officer")
		explanation_text = "In case of emergency, convince the other heads to stay and repair the damage."

	getmoney
		jobrequired = list()
		explanation_text = "Require monetary compensation for you to do your job."

		New()
			jobrequired = civilian_positions + science_positions + medical_positions

			..()

	openshop
		jobrequired = list()
		explanation_text = "You feel the need to open a shop."

		New()
			jobrequired = civilian_positions

			..()

	clone
		jobrequired = list("Geneticist")
		explanation_text = "Successfully clone a dead crewmember."

	virus
		jobrequired = list("Medical Doctor","Chief Medical Officer")
		explanation_text = "Successfully contain a virus outbreak, should one occur."

	medicine
		jobrequired = list("Medical Doctor","Chief Medical Officer")
		explanation_text = "Administer x units of y medicine."

		New()
			..()

			var/possiblereagents = list("Spaceacillin","Bicaridine","Imidazoline","Alkysine","Hyronalin","Oxycodone","Tramadol","Kelotane","Dexalin","Ryetalyn","Leporazine","Dermaline","Tricordrazine","Synaptizine")
			var/possiblecontainers = list("unit","pill","syringe")
			var/possibleammount = rand(1,25)

			explanation_text = "Administer [possibleammount == 1 ? "one" : possibleammount] [pick(possiblecontainers)][possibleammount != 1 ? "s" : ""] of [pick(possiblereagents)]."


	coldmetroid
		jobrequired = list("Scientist")
		explanation_text = "Breed cold-resistant Metroids."

	shockmetroid
		jobrequired = list("Scientist")
		explanation_text = "Breed Metroids that are affected by electricity."