// the SMES
// stores power

#define SMESMAXCHARGELEVEL 200000
#define SMESMAXOUTPUT 200000

/obj/machinery/power/transformer
	name = "transformer unit"
	desc = "A high-voltage transformer. Makes constant output from fluctuating input."
	icon = 'fuse.dmi'
	icon_state = "trans2"
	density = 1
	anchored = 1
	var/online = 0
	var/output = 200000
	var/lastout = 0
	var/loaddemand = 0
	var/capacity = 2e6
	var/charge = 0
	var/n_tag = null
	var/obj/machinery/power/terminal/terminal = null


	New()
		..()
		spawn(5)
			dir_loop:
				for(var/d in cardinal)
					var/turf/T = get_step(src, d)
					for(var/obj/machinery/power/terminal/term in T)
						if(term && term.dir == turn(d, 180))
							terminal = term
							break dir_loop
			if(!terminal)
				stat |= BROKEN
				return
			terminal.master = src
			updateicon()
		return


	proc/updateicon()
		return

#define SMESRATE 0.05			// rate of internal charge to external power


	process()

		if(stat & BROKEN)	return

		if(terminal)
			var/excess = terminal.surplus()

			if(excess >= 0)		// if there's power available, try to charge

				var/load = min(capacity-charge, excess)		// charge at set rate, limited to spare capacity

				charge += load	// increase the charge

				add_load(load)		// add the load to the terminal side network

			if(charge > 0.99*capacity)
				online = 1


		if(online)
			lastout = min(charge, output)		//limit output to that stored

			charge -= lastout		// reduce the storage (may be recovered in /restore() if excessive)

			add_avail(lastout)				// add output to powernet (smes side)

			if(charge < 0.01*capacity)
				online = 0

		return


// called after all power processes are finished
// restores charge level to smes if there was excess this ptick

	add_load(var/amount)
		if(terminal && terminal.powernet)
			terminal.powernet.newload += amount


	attack_ai(mob/user)
		add_fingerprint(user)
		if(stat & BROKEN) return
		interact(user)


	attack_hand(mob/user)
		add_fingerprint(user)
		interact(user)


	proc/interact(mob/user)
		return


	proc/ion_act()
		if(z == 1)
			if(prob(1)) //explosion
				//world << "\red SMES explosion in \the [get_turf(src)]"
				for(var/mob/M in viewers(src))
					M.show_message("\red The [src.name] is making strange noises!", 3, "\red You hear sizzling electronics.", 2)
				sleep(10*pick(4,5,6,7,10,14))
				var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
				smoke.set_up(3, 0, src.loc)
				smoke.attach(src)
				smoke.start()
				explosion(get_turf(src), -1, 0, 1, 3, 0)
				del(src)
				return
			if(prob(15)) //Power drain
				//world << "\red SMES power drain in \the [get_turf(src)]"
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(3, 1, src)
				s.start()
				if(prob(50))
					emp_act(1)
				else
					emp_act(2)
			if(prob(5)) //smoke only
				//world << "\red SMES smoke in \the [get_turf(src)]"
				var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
				smoke.set_up(3, 0, src.loc)
				smoke.attach(src)
				smoke.start()


	emp_act(severity)
		charge -= 1e6/severity
		if (charge < 0)
			charge = 0
		..()


