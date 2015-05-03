var/datum/upgradecontrol/upgrade_controller = null
var/upgrades = list()

var/upgrade_delay = 100

/datum/upgradecontrol
	var/processing = 0
	var/process_cost = 0
	var/iteration = 0

	New()
		if(upgrade_controller != src)
			upgrade_controller = src

	proc/process()
		processing = 1
		spawn(0)
			set background = 1
			while(1)
				if(processing)
					iteration++

				sleep(upgrade_delay)

/datum/upgrade
	var/upgradetype = ""
	var/addition = 0
	var/multiplier = 1

	New(var/t, var/add = 0, var/multi = 1)
		upgradetype = t
		addition = add
		multiplier = multi

proc/getupgrade(var/type)
	var/rvalue = 1

	for(var/datum/upgrade/u in upgrades)
		if(u.upgradetype == type)
			rvalue *= u.multiplier
			rvalue += u.addition

	return rvalue