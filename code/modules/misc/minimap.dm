/obj/smallmap
	name = "location map"

	MouseMove(location,control,params)
		//if(!object || object != src) return
		if(!loc || !istype(loc,/obj/item/weapon/minimap)) return

		var/list/parameters = params2list(params)

		var/iconx = text2num(parameters["icon-x"])
		var/icony = text2num(parameters["icon-y"])

		var/obj/item/weapon/minimap/MM = loc

		MM.set_tooltip(iconx,icony)

/obj/tooltip
	var/xcursor = 0
	var/ycursor = 0
	var/tooltext = ""
	var/list/outline = list()

	proc/settext(var/text = "",var/col = "#FFFFFF")
		underlays.Cut()

		maptext = text
		maptext_width = 1000

		if(!outline.len)
			var/obj/top = new(src)
			top.pixel_y = 1

			var/obj/left = new(src)
			left.pixel_x = -1

			var/obj/bottom = new(src)
			bottom.pixel_y = -1

			var/obj/right = new(src)
			right.pixel_x = 1

			outline += right
			outline += left
			outline += top
			outline += bottom

		for(var/obj/O in outline)
			O.maptext = "<FONT COLOR='#333333'>[maptext]</FONT>"
			O.maptext_width = maptext_width

		maptext = "<FONT COLOR='#FFFFFF'>[maptext]</FONT>"
		color = col

		underlays += outline

/obj/item/weapon/minimap
	name = "minimap device"
	icon = 'device.dmi'
	icon_state = "pinoff"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/active = 0
	var/currx = 1
	var/curry = 1
	var/currz = 1
	var/scanspeed = 100
	//var/list/tiles = list()
	var/icon/mapicon
	var/list/tilecolors = list("space" = "#000000","floor" = "#333333","wall" = "#999999","window" = "#00FFFF","mineral" = "#472F1D","damage" = "#FF0000")
	var/obj/smallmap/mapobject
	var/obj/tooltip/ttip
	var/tilesize = 1 //Actually redundant because it scales with the mapwindow anyway.

	New()
		mapobject = new(src)
		ttip = new(src)
		ttip.layer = mapobject.layer+1

	attack_self()
		if(!active)
			active = 1
			workmap()
			winshow(usr,"stationmap")
			usr << "\blue You activate the minimap device"
		else
			active = 0
			icon_state = "pinoff"
			usr << "\blue You deactivate the minimap device"

	proc/set_tooltip(var/xx,var/yy)
		//world << "setting tooltip to [xx],[yy],[currz]"

		var/turf/T = locate(xx,yy,src.currz)

		//if(!T) return

		var/area/A = T.loc
		var/isspace = A && (A.always_unpowered || !A.requires_power)

		var/texttip = ""
		var/textcolor = "#FFFFFF"

		ttip.xcursor = xx
		ttip.ycursor = yy

		if(!istype(T,/turf/simulated) && !isspace)
			textcolor = "#FF0000"

		if(A && !isspace)
			texttip = A.name

		ttip.settext(texttip,textcolor)
		//world << "setting tooltip text to [texttip]"

		var/mob/M = locate(/mob) in get_turf(src)
		if(!M) return

		var/client/C = M.client

		if(C)
			C.screen -= ttip
			ttip.screen_loc = "mapMinimap:0:[ttip.xcursor],0:[ttip.ycursor]"
			C.screen += ttip

	proc/newmap()
		mapicon = icon('smallmap.dmi',"")
		mapicon.Scale(world.maxx * tilesize,world.maxy * tilesize)

	proc/addtile(var/mob/user,xx,yy,zz)
		if(!mapicon)
			newmap()

		var/turf/T = locate(xx,yy,zz)
		if(!T) return

		var/area/A = T.loc

		var/tileicon = "space"
		var/blendfactor = 0.5

		if(istype(T,/turf/simulated/floor))
			tileicon = "floor"
		if(istype(T,/turf/simulated/wall))
			tileicon = "wall"
		if(istype(T,/turf/simulated/mineral))
			tileicon = "mineral"
			blendfactor = 0.0
		if(locate(/obj/structure/window) in T)
			tileicon = "window"
			blendfactor = 0.0
		if(tileicon == "space" && A && !A.always_unpowered && A.requires_power)
			tileicon = "damage"
			blendfactor = 0.0

		var/areacolor = "#000000"
		if(A && !A.always_unpowered && A.requires_power)
			var/icon/AI = icon('areas.dmi')

			if(AI)
				areacolor = AI.GetPixel(1,1,A.icon_state)

		if(lentext(areacolor) > 7)
			areacolor = copytext(areacolor,1,8)

		var/finalcolor = BlendRGB(tilecolors[tileicon], areacolor, blendfactor)

		//var/icon/newicon = icon('smallmap.dmi',tileicon)

		//mapicon.Blend(newicon,ICON_OVERLAY,(xx-1) * 3 + 1,(yy-1) * 3 + 1)
		var/iconx = (xx-1) * tilesize + 1
		var/icony = (yy-1) * tilesize + 1

		mapicon.DrawBox(finalcolor,iconx,icony,iconx + tilesize,icony + tilesize)
		//icon = mapicon

		//var/image/I = image('smallmap.dmi',tileicon)
		//var/turf/I = T

		//var/client/C = user.client

		//C.screen -= tiles["[xx],[yy]"]
		//C.screen += I
		//tiles["[xx],[yy]"] = I

		//I.screen_loc = "minimap:[S.pre_screen_loc]"

	proc/removetiles(var/mob/user)
		newmap()

	proc/workmap()
		var/turf/T = get_turf(src)
		if(!T) return

		var/mob/M = locate(/mob) in T
		if(!M) return

		if(!active)
			removetiles(M)
			return
		for(var/i=0, i<scanspeed, i++)
			currx++

			if(currx > world.maxx)
				currx = 1
				curry++

			if(curry > world.maxy)
				curry = 1

			addtile(M,currx,curry,currz)

		var/client/C = M.client

		if(C)
			C.screen -= mapobject
			mapobject.screen_loc = "mapMinimap:0,0"
			mapobject.icon = mapicon
			C.screen += mapobject

			C.screen -= ttip
			ttip.screen_loc = "mapMinimap:0:[ttip.xcursor],0:[ttip.ycursor]"
			C.screen += ttip
		spawn(5) .()