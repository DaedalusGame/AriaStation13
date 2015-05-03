/datum/seed/banana
	plantname = "Banana Tree"
	plantid = "banana"
	species = "banana"
	product	= /obj/item/weapon/reagent_containers/food/snacks/fruit/banana
	//growthstages = 5
	plant_type = 0
	rarity = 1

	lifespan = 50

	maturation = 180
	production = 6
	yield = 3
	potency = 1

	basemutations = list(/datum/plantmutation/reagent{reagentid = "banana"; reagentmin = 1; reagentscale = 0.1})
	basecolors = list("_leaf" = "#00FF00","_stem" = "#6C3527","0" = "#FFFF00")

/datum/seed/chili
	plantname = "Chili Pepper"
	plantid = "chili"
	species = "chili"
	product	= /obj/item/weapon/reagent_containers/food/snacks/fruit/chili
	//growthstages = 5
	plant_type = 0
	rarity = 1

	lifespan = 50

	maturation = 180
	production = 6
	yield = 3
	potency = 1

	basemutations = list(/datum/plantmutation/reagent{reagentid = "capsaicin"; reagentmin = 1; reagentscale = 0.1})
	basecolors = list("_leaf" = "#00FF00","_stem" = "#6C3527","0" = "#FF0000")

/datum/seed/eggplant
	plantname = "Eggplant"
	plantid = "eggplant"
	species = "eggplant"
	product	= /obj/item/weapon/reagent_containers/food/snacks/fruit/eggplant
	//growthstages = 5
	plant_type = 0
	rarity = 1

	lifespan = 50

	maturation = 180
	production = 6
	yield = 3
	potency = 1

	basemutations = list()
	basecolors = list("_leaf" = "#6B8E23","_stem" = "#6B8E23","0" = "#800080")

/datum/seed/potato
	plantname = "Potato"
	plantid = "potato"
	species = "potato"
	product	= /obj/item/weapon/reagent_containers/food/snacks/fruit/potato
	//growthstages = 5
	plant_type = 0
	rarity = 1

	lifespan = 50

	maturation = 180
	production = 6
	yield = 3
	potency = 1

	basemutations = list(/datum/plantmutation/underfloor)
	basecolors = list("_leaf" = "#32CD32","_stem" = "#F0E68C","0" = "#DAA520")

/datum/seed/grass
	plantname = "Grass"
	plantid = "grass"
	species = "grass"
	//product	= /obj/item/weapon/reagent_containers/food/snacks/fruit/banana
	//growthstages = 5
	plant_type = 4
	rarity = 1

	lifespan = 60
	maturation = 180
	production = 5
	yield = 5

	basemutations = list(/datum/plantmutation/inert)
	basecolors = list("_stem" = "#F0E68C","0" = "#00FF00")

/datum/seed/wheat
	plantname = "Wheat"
	plantid = "wheat"
	species = "wheat"
	//product	= /obj/item/weapon/reagent_containers/food/snacks/fruit/wheat
	//growthstages = 5
	plant_type = 4
	rarity = 1

	lifespan = 60
	maturation = 180
	production = 5
	yield = 5

	basemutations = list()
	basecolors = list("_stem" = "#F0E68C","0" = "#DAA520")

/datum/seed/vine
	plantname = "Space Vines"
	plantid = "vine"
	species = "vine"
	plant_type = 0
	rarity = 100

	lifespan = 50

	maturation = 180
	production = 6
	yield = 3
	potency = 1

	waterrequirement = 0
	nutrientrequirement = 0

	basemutations = list(/datum/plantmutation/spread/free{spreadspeed = 100})
	basecolors = list("_stem" = "#008000","0" = "#008000")

/datum/seed/plasmapod
	plantname = "Plasmapod"
	plantid = "plasmapod"
	species = "plasmapod"
	product	= /obj/item/weapon/reagent_containers/food/snacks/fruit/plasmapod
	plant_type = 0
	rarity = 100

	lifespan = 50

	maturation = 180
	production = 6
	yield = 3
	potency = 1

	waterrequirement = 0
	nutrientrequirement = 0

	basemutations = list(/datum/plantmutation/spread/free{spreadspeed = 2;slowsize = 30;maxsize = 60},
						/datum/plantmutation/reagent{reagentid = "plasma"; reagentmin = 1; reagentscale = 0.1},
						/datum/plantmutation/emitgas{plasma = 0.1},
						/datum/plantmutation/heat{temperature = 1000},
						/datum/plantmutation/volatile/true{range = 1})
	basecolors = list("_stem" = "#4B0082","0" = "#FF4500")
	unripecolor = "#BA55D3"

/datum/seed/kudzu
	plantname = "Kudzu"
	plantid = "kudzu"
	species = "kudzu"
	product	= /obj/item/weapon/reagent_containers/food/snacks/fruit/kudzupod
	plant_type = 0
	rarity = 100

	lifespan = 50

	maturation = 180
	production = 6
	yield = 3
	potency = 1

	waterrequirement = 0
	nutrientrequirement = 0

	basemutations = list(/datum/plantmutation/spread/free{spreadspeed = 100})
	basecolors = list("_leaf" = "#32CD32","_stem" = "#32CD32","0" = "#32CD32")

/datum/seed/maneater
	plantname = "Maneater"
	plantid = "maneater"
	species = "maneater"
	plant_type = 0
	rarity = 100

	lifespan = 50

	maturation = 180
	production = 6
	yield = 3
	potency = 1

	waterrequirement = 0
	nutrientrequirement = 0

	basemutations = list(/datum/plantmutation/carnivore/biter/devourer{aggressiveness=70;maxmouth=3},
						/datum/plantmutation/spread/free{spreadspeed = 30;slowsize = 10;maxsize = 20})
	basecolors = list("_leaf" = "#32CD32","_stem" = "#32CD32","0" = "#32CD32")

/datum/seed/mold
	plantname = "Mold"
	plantid = "mold"
	species = "mold"
	plant_type = 1
	rarity = 1

	lifespan = 50

	maturation = 180
	production = 6
	yield = 3
	potency = 1

	waterrequirement = 0
	nutrientrequirement = 0

	basemutations = list(/datum/plantmutation/spread/free{spreadspeed = 30},
						/datum/plantmutation/underfloor)
	basecolors = list("0" = "#412821")
