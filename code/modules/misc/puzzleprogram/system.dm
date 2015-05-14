datum/programmable
	var/atom/my_atom
	var/datum/programpuzzle/currentprogram
	var/programcounter = 1
	var/list/memory = list("0",0)

datum/programpuzzle
	var/list/datum/programwidget/pieces = list()

datum/programwidget
	var/name = "Invalid Widget"
	var/desc = "If this shows up on your bot, contact an admin."
	var/delay = 0.1

	proc/runwidget(var/atom/A, var/param1, var/param2, var/param3, var/param4)
		return 0