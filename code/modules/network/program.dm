datum/file/program/mkdir

datum/file/program/ntedit
	var/datum/file/outputtext

	run(var/datum/interface/user,var/D)
		if(!D || !istype(D,/datum/file))
			user.write("\red ERROR: FILE NOT FOUND\n")
			return

		var/datum/file/F = D

		if(!user.lastuser)
			return

		var/readtext = F.read(user)

		if(!istext(readtext))
			user.write("\red ERROR: INVALID FILE\n")

		user.programs += src
		user.currprogram = src
		user.setmode(2)
		outputtext = F
		winset(user.lastuser,"consolewindow.textedit", "text=[readtext]")

	proc/terminate(var/datum/interface/user,var/force)
		user.programs -= src
		if(user.currprogram == src)
			user.currprogram = null
			user.setmode(0)

	input(var/datum/interface/user,var/D)
		if(istext(D))
			var/list/parameters = tg_extext2list(D," ")

			switch(parameters[1])
				if("term")
					terminate(user,("-f" in parameters))
				if("save")
					if(user.lastuser)
						var/text = winget(user.lastuser,"consolewindow.textedit", "text")
						outputtext.write(user,)