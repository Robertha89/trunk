/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "s-ninja"
	item_state = "s-ninja"
	siemens_coefficient = 0
	var/draining = 0
	var/candrain = 0
	var/mindrain = 200
	var/maxdrain = 400

/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	vchange = 1

/obj/item/clothing/shoes/space_ninja
	name = "ninja shoes"
	desc = "A pair of running shoes. Excellent for running and even better for smashing skulls."
	icon_state = "s-ninja"
	flags = NOSLIP

/obj/item/clothing/head/helmet/space/space_ninja
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	name = "ninja hood"
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	armor = list(melee = 0.6, bullet = 0.6, laser = 0.6, energy = 0.8, bomb = 0.8, bio = 0, rad = 0)


/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vaccum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/cell)
	slowdown = 0
	armor = list(melee = 0.6, bullet = 0.6, laser = 0.6, energy = 0.8, bomb = 0.8, bio = 0, rad = 0)

		//Important parts of the suit.
	var/mob/living/carbon/affecting = null//The wearer.
	var/obj/item/weapon/cell/cell//Starts out with a high-capacity cell using New().
	var/datum/effect/effect/system/spark_spread/spark_system//To create sparks.
	var/reagent_list[] = list("tricordrazine","dexalinp","spaceacillin","anti_toxin","nutriment","radium","hyronalin")//The reagents ids which are added to the suit at New().
	var/stored_research[]//For stealing station research.
	var/obj/item/weapon/disk/tech_disk/t_disk//To copy design onto disk.

		//Other articles of ninja gear worn together, used to easily reference them after initializing.
	var/obj/item/clothing/head/helmet/space/space_ninja/n_hood
	var/obj/item/clothing/shoes/space_ninja/n_shoes
	var/obj/item/clothing/gloves/space_ninja/n_gloves

		//Main function variables.
	var/s_initialized = 0//Suit starts off.
	var/s_coold = 0//If the suit is on cooldown. Can be used to attach different cooldowns to abilities. Ticks down every second based on suit ntick().
	var/s_cost = 5.0//Base energy cost each ntick.
	var/s_acost = 25.0//Additional cost for additional powers active.
	var/k_cost = 200.0//Kamikaze energy cost each ntick.
	var/k_damage = 1.0//Brute damage potentially done by Kamikaze each ntick.
	var/s_delay = 40.0//How fast the suit does certain things, lower is faster. Can be overridden in specific procs. Also determines adverse probability.
	var/a_transfer = 20.0//How much reagent is transferred when injecting.
	var/r_maxamount = 80.0//How much reagent in total there is.

		//Support function variables.
	var/spideros = 0//Mode of SpiderOS. This can change so I won't bother listing the modes here (0 is hub). Check ninja_equipment.dm for how it all works.
	var/s_active = 0//Stealth off.
	var/s_busy = 0//Is the suit busy with a process? Like AI hacking. Used for safety functions.
	var/kamikaze = 0//Kamikaze on or off.
	var/k_unlock = 0//To unlock Kamikaze.

		//Ability function variables.
	var/s_bombs = 10.0//Number of starting ninja smoke bombs.
	var/a_boost = 3.0//Number of adrenaline boosters.

		//Onboard AI related variables.
	var/mob/living/silicon/ai/AI//If there is an AI inside the suit.
	var/obj/item/device/paicard/pai//A slot for a pAI device
	var/obj/effect/overlay/hologram//Is the AI hologram on or off? Visible only to the wearer of the suit. This works by attaching an image to a blank overlay.
	var/flush = 0//If an AI purge is in progress.
	var/s_control = 1//If user in control of the suit.


/obj/structure/closet/suit/ninja
	name = "Ninja Suit"
	desc = "Contains a full space ninja suit"
	icon_state = "black"
	icon_closed = "black"

	New()
		..()
		sleep(2)
		new/obj/item/clothing/shoes/space_ninja(src)
		new/obj/item/clothing/gloves/space_ninja(src)
		new/obj/item/clothing/under/color/black(src)
		new/obj/item/clothing/suit/space/space_ninja(src)
		new/obj/item/clothing/head/helmet/space/space_ninja(src)
		new/obj/item/clothing/mask/gas/voice/space_ninja(src)


/obj/item/clothing/suit/space/teno
	name = "10o suit"
	desc = "Prototype Teleport Armor from 10Operations Inc."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	slowdown = 0
	can_remove = 0

	var/last_teleport = 0//Timer
	var/teleport_delay = 30
	armor = list(impact = 0.4, slash = 0.4, pierce = 0.4, bomb = 0.4, bio = 1.0, rad = 1.0)


	suit_function(var/atom/target)//Called when the user ctrl+shift+clicks on something, might get renamed
		if(!ishuman(src.loc))
			return 0
		var/mob/living/carbon/human/H = src.loc
		if(world.time <= last_teleport)
			H << "\blue The suit is recharging."
			return
		var/turf/T = get_turf(target)
		if(T.density)
			return
		for(var/obj/O in T)
			if(O.density)
				return
		playsound(H.loc, 'sound/effects/EMPulse.ogg', 75, 0)
		H.visible_message("\red [H] teleports!")
		H.loc = T
		last_teleport = world.time + teleport_delay
		return 1