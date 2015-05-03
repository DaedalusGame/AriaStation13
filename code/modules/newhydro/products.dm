/obj/item/weapon/reagent_containers/food/snacks/fruit
	icon = 'harvestproduct.dmi'
	var/defaultplant = "plant"
	var/datum/seed/parentplant
	var/base_icon_state = ""
	var/growthsize = 0.5
	volume = 50
	var/obj/effect/plantvine/vine

	On_Consume()
		parentplant.consume(usr,src)

	New()
		..()
		parentplant = plants[defaultplant]
		update_icon()
		src.pixel_x = rand(-12.0, 12)
		src.pixel_y = rand(-12.0, 12)

	attack_hand(mob/user as mob)
		if(istype(usr,/mob/living/silicon))		//How does AI know what plant is?
			return

		if(vine)
			harvest()

		..()

	proc/set_vine(var/obj/effect/plantvine/v)
		vine = v
		vine.fruits += src
		anchored = 1

	proc/harvest()
		if(!vine) return

		if(growthsize < parentplant.size)
			return

		vine.fruits -= src
		vine = null
		anchored = 0

	update_icon()
		var/icon/curricon
		var/unripe = growthsize < parentplant.size


		for(var/colid in parentplant.colors)
			var/pcolor = parentplant.colors[colid]
			var/list/pcolorlist = ReadRGB(pcolor)
			var/icon/newicon = icon('harvestproduct.dmi',"[base_icon_state][colid]")

			if(!newicon) continue

			var/truer = pcolorlist[1]/255
			var/trueg = pcolorlist[2]/255
			var/trueb = pcolorlist[3]/255
			var/overstretch = 0.5

			newicon.MapColors(overstretch+truer,overstretch+trueg,overstretch+trueb, overstretch+truer,overstretch+trueg,overstretch+trueb, overstretch+truer,overstretch+trueg,overstretch+trueb, -overstretch,-overstretch,-overstretch)

			if(unripe)
				newicon.Blend(parentplant.unripecolor,ICON_MULTIPLY)

			if(curricon)
				curricon.Blend(newicon,ICON_OVERLAY)
			else
				curricon = newicon

		icon = curricon
		var/matrix/M = matrix()
		M.Scale(growthsize)
		transform = M

/obj/item/weapon/reagent_containers/food/snacks/fruit/banana
	icon_state = "banana0"
	defaultplant = "banana"
	base_icon_state = "banana"

/obj/item/weapon/reagent_containers/food/snacks/fruit/eggplant
	icon_state = "eggplant0"
	defaultplant = "eggplant"
	base_icon_state = "eggplant"

/obj/item/weapon/reagent_containers/food/snacks/fruit/potato
	icon_state = "potato0"
	defaultplant = "potato"
	base_icon_state = "potato"

/obj/item/weapon/reagent_containers/food/snacks/fruit/chili
	icon_state = "chili0"
	defaultplant = "chili"
	base_icon_state = "chili"

/obj/item/weapon/reagent_containers/food/snacks/fruit/kudzupod
	icon_state = "kudzupod0"
	defaultplant = "kudzu"
	base_icon_state = "kudzupod"

/obj/item/weapon/reagent_containers/food/snacks/fruit/plasmapod
	icon_state = "alienpod0"
	defaultplant = "plasmapod"
	base_icon_state = "alienpod"

/obj/item/weapon/reagent_containers/food/snacks/fruit/berry
	icon_state = "berry0"
	defaultplant = "plasmapod"
	base_icon_state = "berryvine"

	New()
		..()

	set_vine()
		..()

		if(vine)
			pixel_x = 0
			pixel_y = 0
			base_icon_state = "berryvine"
			update_icon()

	harvest()
		..()

		if(!vine)
			base_icon_state = "berry"

			pixel_x = rand(-12.0, 12)
			pixel_y = rand(-12.0, 12)

		update_icon()