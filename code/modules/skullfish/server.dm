/obj/machinery/generic_server
	icon = 'stationobjs.dmi'
	icon_state = "server"
	name = "Server"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100

	var/list/filesystem
	var/datum/computer/file/bootsector
	var/drivenumber
	var/size = 100

