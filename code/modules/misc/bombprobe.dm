#define PROBE_NONE "none"
#define PROBE_EXPLOSION "explosion"
#define PROBE_TEMPERATURE "temperature"
#define PROBE_GAS "gas"
#define PROBE_TOXICITY "toxicity"
#define PROBE_RADIATION "radiation"
#define PROBE_AIRFLOW "airflow"
#define PROBE_EMP "emp"

/obj/machinery/probe
	name = "bomb probe"
	desc = "Measures explosion impacts."
	icon = 'probe.dmi'
	icon_state = "off"
	layer = 2.96
	anchored = 1.0
	use_power = 0

	var/id
	var/mode = PROBE_EXPLOSION

	var/id_tag
	var/frequency = 1244
	var/lastdata = 0
	var/lastdatatime = 0

	var/datum/radio_frequency/radio_connection
	var/sendtimeout = 0

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption) return

		if(id_tag != signal.data["tag"] || !signal.data["setprobemode"]) return

		mode = signal.data["setprobemode"]

		send_status()

	proc/send_status()
		sendtimeout = 10
		icon_state = "on"

		if(radio_connection)
			var/datum/signal/signal = new
			signal.source = src //radio signal
			signal.data["tag"] = id_tag
			signal.data["timestamp"] = world.time

			signal.data["probemode"] = mode
			signal.data["lastmeasuretime"] = lastdatatime
			signal.data["lastmeasuredata"] = lastdata

			radio_connection.post_signal(src, signal, filter = RADIO_PROBE)

	ex_act(severity)
		switch(severity)
			if(3.0)
				measure(PROBE_EXPLOSION,rand(1,1000))
			if(2.0)
				if (prob(1))
					del(src)
				measure(PROBE_EXPLOSION,rand(1000,10000))
			if(1.0)
				if (prob(10))
					del(src)
				measure(PROBE_EXPLOSION,rand(10000,1000000))
		return

	proc/measure(var/measuremode,var/data)
		if(mode == measuremode)
			lastdata = data
			lastdatatime = world.time

	process()
		sendtimeout -= 1

		if(sendtimeout < 0)
			icon_state = "off"
			send_status()

	proc/set_frequency(new_frequency)
		radio_controller.remove_object(src, frequency)
		if(new_frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, RADIO_PROBE)

	initialize()
		..()

		if(frequency)
			set_frequency(frequency)

		update_icon()

	New()
		..()

		if(radio_controller)
			set_frequency(frequency)

/datum/probedata
	var/probeid = null
	var/probemode = PROBE_NONE
	var/lastdata = 0
	var/lasttime = 0
	var/lastheartbeat = 0

/obj/machinery/probereceiver
	name = "Probe Data Receiver"
	icon = 'probe.dmi'
	icon_state = "receiver1"
	desc = "This machine has a dish-like shape and red lights. It is designed to detect and process probe data."
	density = 1
	anchored = 1
	use_power = 0

	var/id_tag
	var/frequency = 1244
	var/lastdata = 0
	var/lastdatatime = 0

	var/list/probes = list()

	var/datum/radio_frequency/radio_connection
	var/timeout = 2000

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption) return

		var/datum/probedata/newdata = probes[signal.data["tag"]]

		if(!newdata)
			newdata = new()
			probes[signal.data["tag"]] = newdata

		newdata.probeid = signal.data["tag"]
		newdata.probemode = signal.data["probemode"]
		newdata.lastdata = signal.data["lastmeasuredata"]
		newdata.lasttime = signal.data["lastmeasuretime"]
		newdata.lastheartbeat = world.time

	proc/set_frequency(new_frequency)
		radio_controller.remove_object(src, frequency)
		if(new_frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, RADIO_PROBE)

	initialize()
		..()

		if(frequency)
			set_frequency(frequency)

		update_icon()

	New()
		..()

		if(radio_controller)
			set_frequency(frequency)

	process()
		if(stat & (BROKEN))
			return
		if(!nterm)
			for (var/obj/machinery/power/netterm/term in loc)
				netconnect(term)
				break
		else
			if(nterm.netid == "00000000")
				nterm.requestid()

		heartbeat()

	proc/heartbeat()
		for(var/datum/probedata/d in probes)
			if(d.lastheartbeat < world.time - timeout)
				probes -= d

	netreceive(datum/netpacket/p)
		if(p.content["protocol"] != "SCIPROBE")
			return

		switch(p.content["command"])
			if("getdata")
				var/datum/netpacket/newpacket = new()

				newpacket.desthost = p.srchost
				newpacket.content["protocol"] = "SCIPROBE"
				newpacket.content["command"] = "getdata"
				newpacket.content["data"] = probes

				netsend(newpacket)