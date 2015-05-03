// This code allows for airlocks to be controlled externally by setting an id_tag and comm frequency (disables ID access)
obj/machinery/door/poddoor
	var/id_tag
	var/frequency

	var/locked

	var/datum/radio_frequency/radio_connection

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption) return

		if(id_tag != signal.data["tag"] || !signal.data["command"]) return

		switch(signal.data["command"])
			if("open")
				spawn open(1)

			if("close")
				spawn close(1)

			if("unlock")
				locked = 0
				update_icon()

			if("lock")
				locked = 1
				update_icon()

			if("secure_open")
				spawn
					locked = 0
					update_icon()

					sleep(2)
					open(1)

					locked = 1
					update_icon()

			if("secure_close")
				spawn
					locked = 0
					close(1)

					locked = 1
					sleep(2)
					update_icon()

		send_status()

	proc/send_status()
		if(radio_connection)
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = id_tag
			signal.data["timestamp"] = world.time

			signal.data["door_status"] = density?("closed"):("open")
			signal.data["lock_status"] = locked?("locked"):("unlocked")

			radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

	open(surpress_send)
		. = ..()
		if(!surpress_send) send_status()

	close(surpress_send)
		. = ..()
		if(!surpress_send) send_status()

	proc/set_frequency(new_frequency)
		radio_controller.remove_object(src, frequency)
		if(new_frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)

	initialize()
		..()

		if(frequency)
			set_frequency(frequency)

		update_icon()

	New()
		..()

		if(radio_controller)
			set_frequency(frequency)