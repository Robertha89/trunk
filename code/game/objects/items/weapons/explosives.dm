/obj/item/weapon/plastique/attack_self(mob/user as mob)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(newtime < 10)
		newtime = 10
	timer = newtime
	user << "Timer set for [timer] seconds."

/obj/item/weapon/plastique/afterattack(atom/target as obj|turf, mob/user as mob, flag)
	if (!flag)
		return
	if (istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/item/weapon/storage/))
		return
	user << "Planting explosives..."
	if(ismob(target))
		user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] tried planting [name] on [target:real_name] ([target:ckey])</font>"
		log_attack("<font color='red'> [user.real_name] ([user.ckey]) tried planting [name] on [target:real_name] ([target:ckey])</font>")
		user.visible_message("\red [user.name] is trying to plant some kind of explosive on [target.name]!")


	if(do_after(user, 50) && in_range(user, target))
		user.drop_item()
		target = target
		loc = null
		var/location
		if (ismob(target))
			target:attack_log += "\[[time_stamp()]\]<font color='orange'> Had the [name] planted on them by [user.real_name] ([user.ckey])</font>"
			user.visible_message("\red [user.name] finished planting an explosive on [target.name]!")
		target.overlays += image('icons/obj/assemblies.dmi', "plastic-explosive2")
		user << "Bomb has been planted. Timer counting down from [timer]."
		spawn(timer*10)
			if(src && target)
				if (isturf(target)) location = target
				if (isobj(target)) location = target.loc
				explosion(location, -1, -1, 2, 3)
				if(istype(target, /turf/simulated/wall)) target:dismantle_wall(1)
				else target.ex_act(1)
				/*if (isobj(target))
					if(target)
						del(target)
				if(src)
					del(src)*/

/obj/item/weapon/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return









/obj/item/weapon/plastique/mining/afterattack(atom/target as obj|turf, mob/user as mob, flag)
	if (!flag)
		return
	if (!istype(target, /turf/simulated/mineral))
		return
	user << "Planting charge..."
/*	if(ismob(target))
		user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] tried planting [name] on [target:real_name] ([target:ckey])</font>"
		log_attack("<font color='red'> [user.real_name] ([user.ckey]) tried planting [name] on [target:real_name] ([target:ckey])</font>")
		user.visible_message("\red [user.name] is trying to plant some kind of explosive on [target.name]!")
*/

	if(do_after(user, 50) && in_range(user, target))
		user.drop_item()
		target = target
		loc = null
		var/location
		if (ismob(target))
			target:attack_log += "\[[time_stamp()]\]<font color='orange'> Had the [name] planted on them by [user.real_name] ([user.ckey])</font>"
			user.visible_message("\red [user.name] finished planting an explosive on [target.name]!")
		target.overlays += image('icons/obj/assemblies.dmi', "plastic-explosive2")
		user << "Bomb has been planted. Timer counting down from [timer]."
		spawn(timer*10)
			if(src && target)
				if (isturf(target)) location = target
				if (isobj(target)) location = target.loc
				for(var/turf/simulated/mineral/C in range(target,2))
					C.gets_drilled()
				explosion(location, -1, -1, 2, 3)
				var/datum/effect/effect/system/harmless_smoke_spread/s = new /datum/effect/effect/system/harmless_smoke_spread
				s.set_up(4, 1, target, 0)
				s.start()
				target.ex_act(1)
				/*if (isobj(target))
					if(target)
						del(target)
				if(src)
					del(src)*/

/obj/item/weapon/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return