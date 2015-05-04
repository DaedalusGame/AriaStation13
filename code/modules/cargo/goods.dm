var/list/supplycatalogue = list()
var/list/basecatalogue = list()

proc/generate_goods()
	for(var/basetype in typesof(/datum/basegood))
		var/datum/basegood/good = new basetype()

		if(istype(good,/datum/basegood/component))
			var/datum/basegood/component/solidgood = good

			if(!solidgood.typepath)
				continue


		if(istype(good,/datum/basegood/liquid))
			var/datum/basegood/liquid/liquidgood = good

			if(!liquidgood.reagentid)
				continue

		basecatalogue += good

	//Initialize snowflake goods
	for(var/datum/basegood/component/good in basecatalogue)
		if(!good.buyfactor) continue

		var/datum/supplygood/newgood = basegood2supplygood(good)

		if(!newgood) continue

		supplycatalogue += newgood

	//Initialize goods from assembler recipes
	generate_assembler_recipes()

	for(var/datum/assemblerprint/recipe in assembler_recipes)
		var/datum/supplygood/assemblerprint/good = new()

		if(!recipe.typepath) continue
		if(ispath(recipe.typepath,/obj/item/chemmaker)) continue //Hacky
		if(!recipe.buyfactor) continue //For items that can't be bought.

		good.name = recipe.name
		good.recipe = recipe

		supplycatalogue += good

proc/basegood2supplygood(var/datum/basegood/component/good) //Don't even ask
	if(!good || !istype(good,/datum/basegood/component)) return

	var/datum/supplygood/basegood/newgood = new()
	var/atom/A = new good.typepath()

	newgood.name = good.name
	newgood.price = good.price
	newgood.buyfactor = good.buyfactor
	newgood.sellfactor = good.sellfactor
	newgood.typepath = good.typepath

	if(!newgood.icon)
		newgood.icon = A.icon
		newgood.iconstate = A.icon_state
		newgood.color = A.color

	del(A)

	return newgood

/*proc/calculate_anycost(var/times)
	for(var/i=0,i<times,i++)
		var/datum/supplygood/good = pick(supplycatalogue)
		var/price = calculate_cost(good,0)

		world << "[good.name] would cost [price]"*/

proc/find_good(var/typepath)
	for(var/datum/supplygood/good in supplycatalogue)
		if(good.get_typepath() == typepath)
			return good

proc/find_solid_good(var/typepath,var/depth)
	var/cost = 0

	for(var/datum/supplygood/good in supplycatalogue)
		if(cost) break //if you fuck around with this you can make it find the most expensive thing that matches for no raisins

		if(good.get_typepath() == typepath)
			cost = good.calculate_cost(depth+1)

	for(var/datum/basegood/component/good in basecatalogue) //This is almost unneeded because components should be added to the supplycatalogue now
		if(cost) break //ditto but that would be stupid

		if(good.typepath == typepath)
			cost = good.price

	return cost

proc/find_liquid_good(var/reagentid,var/amt)
	for(var/datum/basegood/liquid/good in basecatalogue)
		if(good.reagentid == reagentid)
			return good.price * amt

	return 0

datum/basegood //Starting to look exactly like supplygood farther down this file. Merge it if you dare.
	var/name = ""
	var/price = 0
	var/buyfactor = 1
	var/sellfactor = 1

	var/icon
	var/icon_state
	var/color //I don't think this even works in skins but whatever

datum/basegood/component
	var/typepath

	phazite
		name = "Phazite Sheets"
		typepath = /obj/item/stack/sheet/phazon
		price = 1700

datum/basegood/liquid
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

	carbonfiber
		name = "Carbon Fibers"
		reagentid = "coalfiber"
		price = 2

datum/supplygood //if this one ever shows up anywhere i will nuke your hometown
	var/name = ""
	var/price = 0
	var/buyfactor = 1
	var/sellfactor = 1
	var/icon
	var/iconstate
	var/color

	proc/get_icon()
		return icon

	proc/get_iconstate()
		return iconstate

	proc/get_iconcolor()
		return color

	proc/get_typepath() //honky tonky doki doki darknet did 9/11
		return null

	proc/is_storage()
		return 0

	proc/order(var/obj/structure/closet/container)
		return

	proc/calculate_cost(var/depth = 0)
		return price

	proc/get_buy_price()
		return calculate_cost() * src.buyfactor

	proc/get_sell_price()
		return calculate_cost() * src.sellfactor

datum/supplygood/basegood
	var/typepath

	get_typepath()
		return typepath

	order(var/obj/structure/closet/container)
		var/atom/movable/A = new typepath(container) //Hacky? do better than me

		return A

datum/supplygood/assemblerprint
	var/datum/assemblerprint/recipe

	calculate_cost(var/depth = 0)
		if(depth > 8) //For infinite recursion but that never happens
			return

		var/totalprice = 0
		var/list/components = recipe.components
		var/list/liquidcomponents = recipe.liquidcomponents

		for(var/solidcomponent in components)
			totalprice += find_solid_good(solidcomponent,depth)

		for(var/liquidcomponent in liquidcomponents)
			totalprice += find_liquid_good(liquidcomponent,liquidcomponents[liquidcomponent])

		return totalprice

	get_icon()
		return recipe.icon

	get_iconstate()
		return recipe.icon_state

	get_iconcolor()
		return recipe.color

	get_typepath()
		return recipe.typepath

	get_buy_price()
		return calculate_cost() * recipe.buyfactor

	get_sell_price()
		return calculate_cost() * recipe.sellfactor

	is_storage()
		return istype(recipe,/datum/assemblerprint/storage)

	order(var/obj/structure/closet/container)
		var/atom/movable/A = recipe.builditem()

		if(container)
			container += A

		return A
