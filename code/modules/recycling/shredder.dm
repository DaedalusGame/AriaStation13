/obj/machinery/shredder
	anchored = 1
	icon = 'recycling.dmi'
	icon_state = "shredder"
	name = "shredder"
	desc = "A shredder. Better not go near this."
	density = 1

	Bumped(atom/movable/O)
		var/mob/M = O
		if(ismob(O))
			M.gib()
		if(O)
			O.loc = loc
		if(istype(O,/obj/item))
			shred(O,null)

	proc/shred(var/obj/item/I,var/obj/item/scrap/P)
		var/waste = I.w_amt
		if(!waste && !I.m_amt && !I.g_amt)
			waste = I.w_class * 250

		var/obj/item/scrap/S = new(src.loc)
		S.set_components(I.m_amt, I.g_amt, waste)

		if(P)
			P.add_scrap(S)

		for(var/obj/item/CI in I)
			shred(CI,P)

		for(var/mob/M in I)
			M.Move(src.loc)
			M.gib()

		del(I)

