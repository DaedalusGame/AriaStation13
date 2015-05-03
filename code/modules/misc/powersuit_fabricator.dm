/obj/item/stack/suit_module
	name = "suit module"
	singular_name = "suit module"
	icon = 'items.dmi'
	amount = 1 //To compensate for wounds
	max_amount = 5
	w_class = 1
	throw_speed = 4
	throw_range = 20

/obj/item/stack/suit_module/repair
	icon_state = "suit_repair"

	proc/upgrade_suit(var/obj/item/clothing/suit/space/rig/PSuit)
		if(!PSuit) return

/obj/machinery/suitlathe
	name = "\improper Suitlathe"
	desc = "It repairs and upgrades powersuits."
	icon_state = "suitlathe0"
	density = 1
	var/opened = 0.0
	anchored = 1.0

	var/hacked = 0
	var/disabled = 0
	var/shocked = 0

	var/list/wires = list()
	var/hack_wire
	var/disable_wire
	var/shock_wire

	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100