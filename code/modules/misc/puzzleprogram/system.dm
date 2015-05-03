datum/programpuzzle
	var/list/pieces

datum/programwidget
	var/name = "Invalid Widget"
	var/desc = "If this shows up on your bot, contact an admin."

	proc/process(var/obj/machinery/bot/fetchbot/B)
		return 1