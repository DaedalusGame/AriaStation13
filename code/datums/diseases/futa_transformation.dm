//Nanomachines!

/datum/disease/futa_transformation
	name = "Futa Transformation"
	max_stages = 5
	spread = "Sexual Contact"
	spread_type = CONTACT_GENERAL
	cure = "A hard jab in the nuts."
	cure_id = list()
	cure_chance = 0
	agent = "FUTA complex"
	affected_species = list("Human")
	desc = "This disease converts the victim into a poor female creature... almost..."
	severity = "Major"
	var/female = 0
	var/penis = 0

/datum/disease/futa_transformation/stage_act()
	..()
	switch(stage)
		if(2)
			if (prob(8))
				affected_mob << "\red Your crotch feels itchy."
			if (prob(7))
				affected_mob << "\red Your nipples harden."
		if(3)
			if (prob(10))
				affected_mob << "\red Your crotch feels very itchy."
			if (prob(7))
				affected_mob << "\red Your nipples harden."
		if(4)
			if (prob(10) && affected_mob:w_uniform && affected_mob.gender == FEMALE)
				affected_mob << "\red You feel a buldge in your pants."
			if (prob(8) && affected_mob.gender == MALE)
				affected_mob << "Your genitals shrivel."
			if (prob(7) && affected_mob.gender == MALE)
				affected_mob << "Your chest feels hollow."

		if(5)
			if (prob(10))
				affected_mob.flash_pain()
				affected_mob << "\red <b><font size=3>OH GOD! Your crotch is on fire!</font></b>"
				return
			if (prob(40))
				affected_mob.flash_pain()
				if (affected_mob.gender == MALE)
					affected_mob << "<b>You feel a terrible emptyness in your crotch!</b>"
				affected_mob << "\red <b><font size=3>OH GOD! Your crotch is on fire!</font></b>"
				affected_mob.mutations += FUTA
				affected_mob.rebuild_appearance()
				return
			if (prob(40))
				affected_mob.flash_pain()
				affected_mob << "\red <b><font size=3>OH GOD! Your chest is on fire!</font></b>"
				if (affected_mob.gender == MALE)
					affected_mob << "<b>You feel a terrible emptyness in your crotch!</b>"
				affected_mob.gender = FEMALE
				if(istype(affected_mob,/mob/living/carbon/human))
					var/mob/living/carbon/human/H = affected_mob
					H.update_body()
				return

			if (affected_mob.gender == FEMALE)
				src.female = 1

			if (FUTA in affected_mob.mutations)
				src.penis = 1

			if(female && penis)
				affected_mob << "You feel relieved... but at what price?"
				src.cure(0)

