var/datum/tabularasa/tabulacore

proc/initTabulaRasa()
	tabulacore = new()

datum/tabularasa
	var/list/cableicons = list()

	proc/getcableimage(wirecolor,iscut)
		var/wireref = "cable[wirecolor][iscut]"

		if(cableicons[wireref])
			return cableicons[wireref]
		else
			var/icon/cablecolor = icon('cables.dmi',"cable[iscut]",2,1)
			cablecolor.Blend(wirecolor)
			cablecolor.Blend(icon('cables.dmi',"cable[iscut]o",2,1),ICON_OVERLAY)
			cableicons[wireref] = cablecolor
			return cablecolor

	proc/getcable()

	proc/getprogressbar(var/percentage)
		if(percentage < 0) percentage = 0
		if(percentage > 100) percentage = 100

		return "<div class='displayBar'><div class='displayBarFill' style='width:[percentage]%'></div></div>"
