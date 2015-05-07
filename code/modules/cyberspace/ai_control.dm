datum/cyberuser/ai
	var/delay = 20
	var/processing = 0

	New()
		..()
		spawn() ai_update()

	proc/ai_update()
		processing = 1

		for(var/obj/effect/cyberspace/program/prg in allprograms)
			var/curraction = rand(4)

			select(prg)

			for(var/i=0,i<5,i++)
				var/datum/cyberaction/act = get_action(prg,curraction)

				if(act && act.can_use())
					var/list/actiontargets = act.get_targets()

					//act.show_targets(world,1)
					//sleep(0.5)
					//act.show_targets(world,0)
					//sleep(0.5)

					var/list/potentialtargets = list()

					for(var/obj/effect/cyberspace/sector/S in actiontargets)
						if(act.actiontype < 0 && S.has_enemy(prg))
							potentialtargets += S
						else if(act.actiontype > 0 && S.get_program())
							potentialtargets += S
						else if(act.actiontype == 0)
							potentialtargets += S

					if(potentialtargets.len)
						var/obj/effect/cyberspace/sector/target = pick(potentialtargets)
						//world << "targetting [target]"
						act.use(target)
						act.after_use()

				curraction++

			//sleep(1)



		spawn(delay) .()

	//ugly as hell
	proc/get_action(var/obj/effect/cyberspace/program/prg,var/i)
		i = i % 5

		switch(i)
			if(0) return prg.action1
			if(1) return prg.action2
			if(2) return prg.action3
			if(3) return prg.action4
			if(4) return prg.action5