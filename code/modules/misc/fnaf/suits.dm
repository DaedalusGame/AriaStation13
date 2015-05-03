/obj/item/clothing/suit/fake_animatronic
	w_class = 4
	slowdown = 0.2
	flags = FPRINT | TABLEPASS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 10, bullet = 30, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/fake_animatronic/freddy
	name = "Freddy Suit"
	desc = "An animatronic suit of a bear mascot."
	icon_state = "freddy"
	item_state = "freddy"

/obj/item/clothing/suit/fake_animatronic/chica
	name = "Chica Suit"
	desc = "An animatronic suit of a chicken mascot."
	icon_state = "chica"
	item_state = "chica"

/obj/item/clothing/suit/fake_animatronic/bonnie
	name = "Bonnie Suit"
	desc = "An animatronic suit of a bunny mascot."
	icon_state = "bonnie"
	item_state = "bonnie"

/obj/item/clothing/suit/fake_animatronic/foxy
	name = "Foxy Suit"
	desc = "An animatronic suit of a fox mascot."
	icon_state = "foxy"
	item_state = "foxy"


//The real deal. Look away, I'm doing science.
/obj/item/clothing/suit/animatronic
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	heat_transfer_coefficient = 0.01
	protective_temperature = 2000
	flags = FPRINT | TABLEPASS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 0.2 //Moves really slow
	//allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/pen,/obj/item/device/flashlight/pen)
	armor = list(melee = 100, bullet = 100, laser = 20,energy = 20, bomb = 50, bio = 100, rad = 100)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

	New()
		..()
		processing_objects.Add(src)

	Del()
		..()
		processing_objects.Remove(src)

/obj/item/clothing/suit/animatronic/freddy
	name = "Freddy Suit"
	desc = "An animatronic suit of a bear mascot. Creepy."
	icon_state = "freddy"
	item_state = "freddy"

/obj/item/clothing/suit/animatronic/chica
	name = "Chica Suit"
	desc = "An animatronic suit of a chicken mascot. Oddly arousing."
	icon_state = "chica"
	item_state = "chica"

/obj/item/clothing/suit/animatronic/bonnie
	name = "Bonnie Suit"
	desc = "An animatronic suit of a bunny mascot. Creepy."
	icon_state = "bonnie"
	item_state = "bonnie"

/obj/item/clothing/suit/animatronic/foxy
	name = "Foxy Suit"
	desc = "An animatronic suit of a fox mascot. Creepy."
	icon_state = "foxy"
	item_state = "foxy"

	process()
		//Inject Hyperzine all the time
		if(!ismob(loc)) return

		var/mob/M = loc

		if(M.reagents && !M.reagents.has_reagent("hyperzine",10))
			M.reagents.add_reagent("hyperzine",1)

		return