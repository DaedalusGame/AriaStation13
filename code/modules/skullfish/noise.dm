var/list/bluespace_zlevels = list()
var/list/bluespace_destinations = list()

/obj/item/device/radio
	var/permspaced = 0

proc/is_bluespaced(var/atom/A)
	var/turf/T = get_turf(A)

	if(!T)
		return 1

	if(T.z in bluespace_zlevels)
		return 1

	if(istype(A,/obj/item/device/radio))
		var/obj/item/device/radio/R = A
		if(R.permspaced)
			return 1

	return 0

proc/bluespace_radio(var/obj/item/device/radio/R,mob/M,message)
	//TODO: Add more bluespaced radio interactions.

	if(prob(10))
		R.permspaced = 1

	return

/obj/effect/mapmarker
	icon = 'screen1.dmi'
	icon_state = "x3"
	invisibility = 101
	anchored = 1.0
	unacidable = 1

/obj/effect/mapmarker/bluenoise
	name = "Bluespace Noise Node"

	New()
		spawn(2)
			bluespace_zlevels += z

/obj/effect/mapmarker/portalspawn
	name = "Portal Spawn Node"
	icon = 'singularity.dmi'
	icon_state = "singularity_s1"

	New()
		spawn(2)
			bluespace_destinations += src