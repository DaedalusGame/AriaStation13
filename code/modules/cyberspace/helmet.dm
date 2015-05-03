/mob/proc/get_cyberspace_interface()
	return null

/mob/living/silicon/get_cyberspace_interface()
	return ..() //TODO: give silicons an integrated cyberspace interface

/mob/living/silicon/pAI/get_cyberspace_interface()
	return ..() //TODO: pAIs need to be jacked in for le evil hacks

/mob/living/carbon/human/get_cyberspace_interface()
	if(istype(src.head,/obj/item/clothing/head/helmet/cyber))
		return src.head:cyuser //Forgive me
	//TODO: Implant?
	return ..()

/obj/item/clothing/head/helmet/cyber
	name = "cyberjacket helmet"
	desc = "This makes you look really stupid, nerd."
	icon_state = "cyberhead"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES
	see_face = 0.0
	item_state = "cyber"
	armor = list(melee = 10, bullet = 5, laser = 10,energy = 0, bomb = 10, bio = 5, rad = 10)
	flags_inv = HIDEEARS|HIDEEYES
	var/mob/living/carbon/lastworn
	var/atom/jacktarget
	var/obj/machinery/power/netterm/jacksource
	var/datum/cyberuser/cyuser
	var/list/programstorage = list(/obj/effect/cyberspace/program/hack1)

/obj/item/clothing/head/helmet/cyber/New()
	cyuser = new()

/obj/item/clothing/head/helmet/cyber/attack_self()
	toggle()

/obj/item/clothing/head/helmet/cyber/verb/toggle()
	set category = "Object"
	set name = "Jack into Cyberspace"

	//world << "Begin jacking..."

	if(!istype(loc,/mob/living/carbon/human)) return

	//world << "Human identity confirmed."

	var/mob/living/carbon/human/M = loc

	if(usr.canmove && usr.stat != 2) //Fuck it, allow jacking while restrained :>
		if(jacktarget)
			toggle_off()
		else if(M.head == src)
			//world << "Jacking..."
			lastworn = M
			jack_into_nearest()
			M.client.show_cyberspace()
			update()
			processing_objects.Add(src)

/obj/item/clothing/head/helmet/cyber/proc/jack_into_nearest()
	var/obj/machinery/power/netterm/NT = locate() in range(1,lastworn)

	if(!NT) return

	NT.requestid()

	world << "Found [NT]"

	var/list/allterms = NT.getallhosts()
	var/list/cyberterms = list()

	for (var/obj/machinery/power/netterm/term in allterms)
		var/cybermap = term.get_cybermap(1)

		world << "Testing [term] of [term.master] [cybermap]"

		if(cybermap) cyberterms["[term.netid] ([term.nettype])"] = term

	if(cyberterms.len)
		var/pickedtarget = input("Select a device to jack into.","Device Lookup",pick(cyberterms)) in cyberterms

		jacktarget = cyberterms[pickedtarget]
		jacksource = NT
		cyuser.currentmap = jacktarget.get_cybermap(1)

		world << "Found cybermap in [jacktarget]"

/obj/item/clothing/head/helmet/cyber/proc/update()
	var/mob/living/carbon/human/M = loc

	if(!cyuser || !cyuser.currentmap)
		M.client.hide_cyberspace()
		return

	if(M && M.head == src && M.client)
		M.client.update_cyberspace(cyuser)

	spawn(5) .()

/obj/item/clothing/head/helmet/cyber/proc/toggle_off()
	jacktarget = null
	jacksource = null
	lastworn = null
	processing_objects.Remove(src)

/obj/item/clothing/head/helmet/cyber/process()
	var/turf/curloc = get_turf(src)

	var/closejack = lastworn && jacktarget && jacksource /*&& (jacksource in curloc || curloc in range(1,jacksource))*/

	if(!closejack)
		toggle_off()
	//else
	//	lastworn.enter_cyberspace(jacktarget,1)

/*mob/proc/enter_cyberspace(var/atom/A,var/level)
	if(!A) return

	var/obj/effect/cyberspace/mapholder/map = A.get_cybermap(level)

	if(!map) return
	if(!src.client) return

	src.client.enter_cyberspace(map)*/