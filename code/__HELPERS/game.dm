//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/proc/dopage(src,target)
	var/href_list
	var/href
	href_list = params2list("src=\ref[src]&[target]=1")
	href = "src=\ref[src];[target]=1"
	src:temphtml = null
	src:Topic(href, href_list)
	return null

/proc/get_area(O)
	var/turf/T = get_turf(O)
	if(T)	return T.loc

/proc/get_area_name(N) //get area by its name
	for(var/area/A in world)
		if(A.name == N)
			return A
	return 0

/proc/in_range(source, user)
	if(get_dist(source, user) <= 1)
		return 1

	return 0 //not in range and not telekinetic

// Like view but bypasses luminosity check

/proc/hear(var/range, var/atom/source)

	var/lum = source.luminosity
	source.luminosity = 6

	var/list/heard = view(range, source)
	source.luminosity = lum

	return heard




//Magic constants obtained by using linear regression on right-angled triangles of sides 0<x<1, 0<y<1
//They should approximate pythagoras theorem well enough for our needs.
#define k1 0.934
#define k2 0.427
/proc/cheap_hypotenuse(Ax,Ay,Bx,By) // T is just the second atom to check distance to center with
	var/dx = abs(Ax - Bx)	//sides of right-angled triangle
	var/dy = abs(Ay - By)
	if(dx>=dy)	return (k1*dx) + (k2*dy)	//No sqrt or powers :)
	else		return (k2*dx) + (k1*dy)
#undef k1
#undef k2

/proc/circlerange(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/proc/circleview(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/atoms = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/A in view(radius, centerturf))
		var/dx = A.x - centerturf.x
		var/dy = A.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			atoms += A

	//turfs += centerturf
	return atoms

/proc/get_dist_euclidian(atom/Loc1 as turf|mob|obj,atom/Loc2 as turf|mob|obj)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y

	var/dist = sqrt(dx**2 + dy**2)

	return dist

/proc/circlerangeturfs(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

/proc/circleviewturfs(center=usr,radius=3)		//Is there even a diffrence between this proc and circlerangeturfs()?

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs



//var/debug_mob = 0

// Will recursively loop through an atom's contents and check for mobs, then it will loop through every atom in that atom's contents.
// It will keep doing this until it checks every content possible. This will fix any problems with mobs, that are inside objects,
// being unable to hear people due to being in a box within a bag.

/proc/recursive_mob_check(var/atom/O,  var/list/L = list(), var/recursion_limit = 3, var/client_check = 1, var/sight_check = 1, var/include_radio = 1)

	//debug_mob += O.contents.len
	if(!recursion_limit)
		return L
	for(var/atom/A in O.contents)

		if(ismob(A))
			var/mob/M = A
			if(client_check && !M.client)
				L = recursive_mob_check(A, L, recursion_limit - 1, client_check, sight_check, include_radio)
				continue
			if(sight_check && !isInSight(A, O))
				continue
			L |= M
			//world.log << "[recursion_limit] = [M] - [get_turf(M)] - ([M.x], [M.y], [M.z])"

		else if(include_radio && istype(A, /obj/item/device/radio))
			if(sight_check && !isInSight(A, O))
				continue
			L |= A

		if(isobj(A) || ismob(A))
			L = recursive_mob_check(A, L, recursion_limit - 1, client_check, sight_check, include_radio)
	return L

// The old system would loop through lists for a total of 5000 per function call, in an empty server.
// This new system will loop at around 1000 in an empty server.

/proc/get_mobs_in_view(var/R, var/atom/source)
	// Returns a list of mobs in range of R from source. Used in radio and say code.

	var/turf/T = get_turf(source)
	var/list/hear = list()

	if(!T)
		return hear

	var/list/range = hear(R, T)

	for(var/atom/A in range)
		if(ismob(A))
			var/mob/M = A
			if(M.client)
				hear += M
			//world.log << "Start = [M] - [get_turf(M)] - ([M.x], [M.y], [M.z])"
		else if(istype(A, /obj/item/device/radio))
			hear += A

		if(isobj(A) || ismob(A))
			hear = recursive_mob_check(A, hear, 3, 1, 0, 1)

	return hear


/proc/get_mobs_in_radio_ranges(var/list/obj/item/device/radio/radios)

	set background = 1

	. = list()
	// Returns a list of mobs who can hear any of the radios given in @radios
	var/list/speaker_coverage = list()
	for(var/i = 1; i <= radios.len; i++)
		var/obj/item/device/radio/R = radios[i]
		if(R)
			var/turf/speaker = get_turf(R)
			if(speaker)
				for(var/turf/T in hear(R.canhear_range,speaker))
					speaker_coverage[T] = T


	// Try to find all the players who can hear the message
	for(var/i = 1; i <= player_list.len; i++)
		var/mob/M = player_list[i]
		if(M)
			var/turf/ear = get_turf(M)
			if(ear)
				if(speaker_coverage[ear])
					. |= M
	return .

#define SIGN(X) ((X<0)?-1:1)

proc
	inLineOfSight(X1,Y1,X2,Y2,Z=1,PX1=16.5,PY1=16.5,PX2=16.5,PY2=16.5)
		var/turf/T
		if(X1==X2)
			if(Y1==Y2)
				return 1 //Light cannot be blocked on same tile
			else
				var/s = SIGN(Y2-Y1)
				Y1+=s
				while(Y1!=Y2)
					T=locate(X1,Y1,Z)
					if(T.opacity)
						return 0
					Y1+=s
		else
			var/m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
			var/b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
			var/signX = SIGN(X2-X1)
			var/signY = SIGN(Y2-Y1)
			if(X1<X2)
				b+=m
			while(X1!=X2 || Y1!=Y2)
				if(round(m*X1+b-Y1))
					Y1+=signY //Line exits tile vertically
				else
					X1+=signX //Line exits tile horizontally
				T=locate(X1,Y1,Z)
				if(T.opacity)
					return 0
		return 1
#undef SIGN

proc/isInSight(var/atom/A, var/atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return 0

	if(inLineOfSight(Aturf.x,Aturf.y, Bturf.x,Bturf.y,Aturf.z))
		return 1

	else
		return 0

/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)

/proc/get_mob_by_key(var/key)
	for(var/mob/M in mob_list)
		if(M.ckey == lowertext(key))
			return M
	return null

/proc/get_candidates(role=0)
	. = list()
	for(var/mob/dead/observer/G in player_list)
		if(!G.mind || !G.mind.current || G.mind.current.stat == DEAD)
			if(G.client.prefs.be_special & role)
				. += G.client

// Will return a list of active candidates. It increases the buffer 5 times until it finds a candidate which is active within the buffer.
//TODO: DOES NOT RESPECT JOBBANS ~Elly
/proc/get_active_candidates(role=0, buffer_min=1, buffer_max=5, scale=600)
	var/list/choose_from = get_candidates(role)

	var/list/candidates = list() //List of candidate KEYS ~Carn
	if(choose_from.len)
		buffer_min *= scale
		buffer_max *= scale

		for(var/buffer=buffer_min, buffer<=buffer_max, buffer+=scale)
			for(var/client/C in choose_from)
				if(C.inactivity <= buffer)
					candidates += C
			if(candidates.len)
				break

	return candidates

// Same as above but for alien candidates.

/proc/get_alien_candidates()
	return get_active_candidates(BE_ALIEN)

/proc/ScreenText(obj/O, maptext="", screen_loc="CENTER-7,CENTER-7", maptext_height=480, maptext_width=480)
	if(!isobj(O))	O = new /obj/screen/text()
	O.maptext = maptext
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/proc/Show2Group4Delay(obj/O, list/group, delay=0)
	if(!isobj(O))	return
	if(!group)	group = clients
	for(var/client/C in group)
		C.screen += O
	if(delay)
		spawn(delay)
			for(var/client/C in group)
				C.screen -= O

/proc/range_turfs(Dist, atom/Center=usr)
	if(!Center)	return list()
	var/turf/lower_left = locate(max(1,Center.x-Dist),max(1,Center.y-Dist),Center.z)
	var/turf/upper_right = locate(min(world.maxx,Center.x+Dist),min(world.maxy,Center.y+Dist),Center.z)
	return block(lower_left, upper_right)