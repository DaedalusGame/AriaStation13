/obj/item/device/payment
	desc = "A device for instant money transfers."
	name = "payment transfer device"
	icon_state = "payment"
	item_state = "electronic"
	w_class = 2.0
	flags = FPRINT | TABLEPASS | CONDUCT
	m_amt = 75
	w_amt = 75
	origin_tech = "powerstorage=1"
	var/payment_amt
	var/obj/item/weapon/card/id/targetaccount
	var/reset_access
	var/setpay_access
	var/id

	proc/scan(var/mob/user)
		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(H.wear_id)
				if(istype(H.wear_id, /obj/item/weapon/card/id))
					return H.wear_id
				if(istype(H.wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/P = H.wear_id
					if(istype(P.id,/obj/item/weapon/card/id))
						return P.id
		return null

	attack_ai(var/mob/user as mob)
		return src.attack_hand(user)

	attack_paw(var/mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(anchored)
			return

		//var/ucard = scan(user)

		..()

		/*if(!setpay_access || (ucard && setpay_access in ucard.access))
			var/want = input(usr,"Enter the desired amount") as num
			if(want)
				payment_amt = want
		else
			..()*/

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/weapon/screwdriver))
			var/atom/attachable = locate(/obj/structure/table) in get_turf(src)

			if(!attachable) return

			anchored = !anchored
			if(anchored)
				user << "You attach the device to \the [attachable]."

				for(var/mob/M in viewers(user))
					if(M == user) continue
					M << "[user] screws \the [src] to \the [attachable]."
			else
				user << "You detach the device from \the [attachable]."

				for(var/mob/M in viewers(user))
					if(M == user) continue
					M << "[user] unscrews \the [src] from \the [attachable]."
			return
		else if(istype(I, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/card = I

			if(targetaccount && card != targetaccount && payment_amt)
				var/pincode = input(usr,"Enter a pin-code") as num
				if(card.checkaccess(pincode,usr))
					if(card.money >= payment_amt)
						card.money -= payment_amt
						targetaccount.money += payment_amt
						payment_amt = 0
						//targetaccount = null

						src.visible_message("[src] accepts the payment!", "You hear a ping.")
						playsound(src.loc, 'ping.ogg', 50, 0)
					else
						user << "Not enough money."

			else if(!reset_access || reset_access in card.access)
				var/want = input(usr,"Enter the desired amount") as num
				if(want)
					payment_amt = want
					targetaccount = card
					user << "Set target account to your card."
			else
				user << "Access denied."

		else
			..()