var/list/supplycatalogue = list()
var/list/basecatalogue = list()

proc/generate_goods()
	for(var/basetype in typesof(/datum/basegood))
		var/datum/basegood/good = new basetype()

		if(!good.typepath && !good.reagentid)
			continue

		basecatalogue += good

	generate_assembler_recipes()

	for(var/datum/assemblerprint/recipe in assembler_recipes)
		var/datum/supplygood/good = new /datum/supplygood()

		if(!recipe.typepath) continue
		if(ispath(recipe.typepath,/obj/item/chemmaker)) continue //Hacky
		if(!recipe.buyfactor) continue //For items that can't be bought.

		good.name = recipe.name
		good.recipe = recipe

		supplycatalogue += good

proc/calculate_anycost(var/times)
	for(var/i=0,i<times,i++)
		var/datum/supplygood/good = pick(supplycatalogue)
		var/price = calculate_cost(good,0)

		world << "[good.name] would cost [price]"

proc/calculate_cost(var/datum/supplygood/good,var/depth)
	if(depth > 8)
		return

	var/totalprice = 0
	var/list/components = good.recipe.components
	var/list/liquidcomponents = good.recipe.liquidcomponents

	for(var/solidcomponent in components)
		totalprice += find_solid_good(solidcomponent,depth)

	for(var/liquidcomponent in liquidcomponents)
		totalprice += find_liquid_good(liquidcomponent,liquidcomponents[liquidcomponent])

	return totalprice

proc/get_buy_price(var/datum/supplygood/good)
	return calculate_cost(good,0) * good.recipe.buyfactor

proc/get_sell_price(var/datum/supplygood/good)
	return calculate_cost(good,0) * good.recipe.sellfactor

proc/find_good(var/typepath)
	for(var/datum/supplygood/good in supplycatalogue)
		if(good.recipe.typepath == typepath)
			return good

proc/find_solid_good(var/typepath,var/depth)
	var/cost = 0

	for(var/datum/supplygood/good in supplycatalogue)
		if(cost) break

		if(good.recipe.typepath == typepath)
			cost = calculate_cost(good,depth+1)

	for(var/datum/basegood/good in basecatalogue)
		if(cost) break

		if(good.typepath == typepath)
			cost = good.price

	return cost

proc/find_liquid_good(var/reagentid,var/amt)
	for(var/datum/basegood/good in basecatalogue)
		if(good.reagentid == reagentid)
			return good.price * amt

	return 0

datum/basegood
	var/name = ""
	var/price = 0
	var/typepath
	var/reagentid

	fiber
		name = "Fiber"
		reagentid = "fiber"
		price = 0.2

	rubber
		name = "Rubber"
		reagentid = "rubber"
		price = 0.3

	iron
		name = "Iron"
		reagentid = "iron"
		price = 0.5

	glass
		name = "Glass"
		reagentid = "glass"
		price = 0.5

	copper
		name = "Copper"
		reagentid = "copper"
		price = 0.5

	silver
		name = "Silver"
		reagentid = "silver"
		price = 2.5

	gold
		name = "Gold"
		reagentid = "gold"
		price = 5

	diamond
		name = "Diamond"
		reagentid = "diamond"
		price = 20

	acid
		name = "Sulfuric Acid"
		reagentid = "acid"
		price = 1

	plasma
		name = "Plasma"
		reagentid = "plasma"
		price = 7

	uranium
		name = "Uranium"
		reagentid = "uranium"
		price = 17

	sodium
		name = "Sodium"
		reagentid = "sodium"
		price = 0.5

	phazite
		name = "Phazite Sheets"
		typepath = /obj/item/stack/sheet/phazon
		price = 1700

	carbonfiber
		name = "Carbon Fibers"
		reagentid = "coalfiber"
		price = 2

datum/supplygood
	var/name = ""
	var/price = 0
	var/datum/assemblerprint/recipe

	proc/order(var/obj/structure/closet/container)
		if(!container) return

		container += recipe.builditem()