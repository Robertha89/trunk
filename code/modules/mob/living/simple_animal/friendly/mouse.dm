/mob/living/simple_animal/mouse
	name = "mouse"
	desc = "It's a nasty, ugly, evil, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks")
	emote_hear = list("squeeks")
	emote_see = list("runs in a circle", "shakes")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "splats the"
	density = 0
	var/variant //brown, gray and white, leave blank for random

/mob/living/simple_animal/mouse/New()
	..()
	if(!variant)
		variant = pick( list("brown","gray","white") )
	icon_state = "mouse_[variant]"
	icon_living = "mouse_[variant]"
	icon_dead = "mouse_[variant]_dead"


/mob/living/simple_animal/mouse/proc/splat()
	src.health = 0
	src.stat = DEAD
	src.icon_dead = "mouse_[variant]_splat"
	src.icon_state = "mouse_[variant]_splat"


/mob/living/simple_animal/mouse/HasEntered(AM as mob|obj)
	if( ishuman(AM) )
		if(!stat)
			var/mob/M = AM
			M << "\blue \icon[src] Squeek!"
			M << 'sound/effects/mousesqueek.ogg'
	..()

/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	variant = "white"
	icon_state = "mouse_white"

/mob/living/simple_animal/mouse/gray
	variant = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/brown
	variant = "brown"
	icon_state = "mouse_brown"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"