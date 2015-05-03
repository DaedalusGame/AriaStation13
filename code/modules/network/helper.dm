proc/list_delindex(var/list/input,var/i)
	var/list/output = list()

	for(var/e = 1, e <= input.len, e++)
		if(e != i)
			output += input[e]

	return output