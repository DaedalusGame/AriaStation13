atom/proc/ul_SetLuminosity(var/r,var/g,var/b)
	set_light(max(r,g,b), 1, rgb(r * 255,g * 255,b * 255))

atom/proc/ul_SetOpacity(var/i)
	set_opacity(i)