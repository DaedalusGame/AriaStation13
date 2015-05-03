#define READMODE = 4
#define WRITEMODE = 2
#define EXECUTEMODE = 1

datum/file
	var/name

	proc/find(var/list/path)
		if(path.len == 1 && path[1] == name)
			return src
		return

	proc/access(var/datum/interface/user,var/mode)
		return 1

	proc/write(var/datum/interface/user,var/D) //This goes into the file
		return D

	proc/read(var/datum/interface/user) //This goes out of the file
		return ""

datum/file/text //This contains text.
	var/text = ""

datum/file/script //This is a compiled textfile. It can run commands on the interface

datum/file/program //This is a hacky type of file that executes stuff on the host interface.

datum/file/folder //This contains other files.
	var/list/content = list()

	find(var/list/path)
		if(path[1] == name)
			if(path.len == 1)
				return src
			else
				for(var/datum/file/F in content)
					F.find(list_delindex(path,1))

datum/file/null //This is basicly a datasink. It makes data disappear.

datum/file/temp //This is a container for script variables.
	var/list/variables