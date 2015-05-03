datum/netpacket
	 var/desthost = "FFFFFFFF"
	 var/srchost = "00000000"
	 var/list/content = list()

datum/filepath
	var/path = ""
	var/name = ""

	New(var/p,var/n)
		path = p
		name = n

datum/filecontent
	var/path = ""
	var/name = ""
	var/content

	New(var/p,var/n,var/cont)
		path = p
		name = n
		content = cont

proc/is_valid_filepath(var/fullpath)
	var/temppath = fullpath

	if(copytext(1,2) != "/") return 0

	var/i
	var/slash = 0
	var/dot = 0
	for(i=1, i<=length(temppath), i++)
		var/tempchar = copytext(i,i+1)
		if(tempchar == ".")
			dot++
			if(dot >= 2)
				return 0
		if(tempchar == "/")
			if(dot)
				return 0
			slash++
			if(slash >= 2)
				return 0
		else
			slash=0

	return 1

proc/make_filepath(var/fullpath)
	var/temppath = copytext(fullpath,2)

	while(length(temppath) > 0 && findtext(temppath,"/"))
		temppath = copytext(temppath,-length(temppath)+findtext(temppath,"/"))

	return new /datum/filepath(copytext(fullpath,1,length(fullpath)-length(temppath)+1),temppath)

proc/make_filecontent(var/fullpath,var/content)
	var/temppath = copytext(fullpath,2)

	while(length(temppath) > 0 && findtext(temppath,"/"))
		temppath = copytext(temppath,-length(temppath)+findtext(temppath,"/"))

	return new /datum/filecontent(copytext(fullpath,1,length(fullpath)-length(temppath)+1),temppath,content)