/obj/item/projectile/energy
	name = "\improper Energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = "energy"


/obj/item/projectile/energy/electrode
	name = "\improper Electrode"
	icon_state = "spark"
	nodamage = 1
	stun = 15
	weaken = 15
	stutter = 10
	flag = "laser" //Give it a better chance to be blocked.

	check_fire(var/mob/living/target as mob, var/mob/living/user as mob)
		if((target.stunned + target.weakened) > 30)
			return 2
		else
			return ..()


/obj/item/projectile/energy/declone
	name = "\improper Decloner Bolt"
	icon_state = "declone"
	nodamage = 1
	damage_type = CLONE
	irradiate = 40


/obj/item/projectile/energy/dart
	name = "\improper Dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	weaken = 5


/obj/item/projectile/energy/bolt
	name = "\improper Bolt"
	icon_state = "cbbolt"
	damage = 10
	damage_type = TOX
	nodamage = 0
	weaken = 10
	stutter = 10


/obj/item/projectile/energy/bolt/large
	name = "\improper Large Bolt"
	damage = 20

/obj/item/projectile/energy/fireball
	name = "fireball"
	icon_state = "fireball"
	damage = 10
	damage_type = BRUTE
	nodamage = 0
	//flag = "magic"

/obj/item/projectile/energy/fireball/on_hit(var/target)
	var/turf/T = get_turf(target)
	explosion(T, -1, 0, 2, 3, 0, flame_range = 2)
	if(ismob(target)) //multiple flavors of pain
		var/mob/living/M = target
		M.take_overall_damage(0,10) //between this 10 burn, the 10 brute, the explosion brute, and the onfire burn, your at about 65 damage if you stop drop and roll immediately


