var/global/obj/effect/datacore/data_core = null

var/global/list/machines = list()	//This USED to be the list of PROCESSING machines, now it contains every machine and is not used for processing.
									//SSpower.processing is now the list of machines which process power-related stuff
									//SSmachines.processing is now the list for any other processing.
var/global/list/processing_objects = list()
var/global/list/active_diseases = list()
var/global/list/events = list()
		//items that ask to be called every cycle

var/global/list/global_map = null
	//list/global_map = list(list(1,5),list(4,3))//an array of map Z levels.
	//Resulting sector map looks like
	//|_1_|_4_|
	//|_5_|_3_|
	//
	//1 - SS13
	//4 - Derelict
	//3 - AI satellite
	//5 - empty space


	//////////////

var/BLINDBLOCK = 0
var/DEAFBLOCK = 0
var/HULKBLOCK = 0
var/TELEBLOCK = 0
var/FIREBLOCK = 0
var/XRAYBLOCK = 0
var/CLUMSYBLOCK = 0
var/FAKEBLOCK = 0
var/BLOCKADD = 0
var/DIFFMUT = 0

var/skipupdate = 0
	///////////////
var/eventchance = 3 //% per 5 mins
var/event = 0
var/hadevent = 0
var/blobevent = 0
	///////////////

var/diary = null
var/diaryofmeanpeople = null
var/href_logfile = null
var/station_name = null
var/game_version = "FP Station 13"
var/changelog_hash = ""

//var/datum/air_tunnel/air_tunnel1/SS13_airtunnel = null
var/going = 1.0
var/master_mode = "traitor"//"extended"
var/secret_force_mode = "secret" // if this is anything but "secret", the secret rotation will forceably choose this mode

//var/datum/engine_eject/engine_eject_control = null
var/host = null
var/ooc_allowed = 1
var/dooc_allowed = 1
var/traitor_scaling = 1
//var/goonsay_allowed = 0
var/dna_ident = 1
var/abandon_allowed = 1
var/enter_allowed = 1
var/guests_allowed = 1
var/shuttle_frozen = 0
var/shuttle_left = 0

var/list/jobMax = list()
var/list/bombers = list(  )
var/list/admin_log = list (  )
var/list/lastsignalers = list(	)	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
var/list/lawchanges = list(  ) //Stores who uploaded laws to which silicon-based lifeform, and what the law was
var/list/shuttles = list(  )
var/list/reg_dna = list(  )
//	list/traitobj = list(  )


var/CELLRATE = 0.002  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
var/CHARGELEVEL = 0.001 // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

var/shuttle_z = 2	//default
//var/airtunnel_start = 68 // default
//var/airtunnel_stop = 68 // default
//var/airtunnel_bottom = 72 // default
var/list/monkeystart = list()
var/list/wizardstart = list()
var/list/samuraistart = list()
var/list/newplayer_start = list()
var/list/latejoin = list()
var/list/prisonwarp = list()	//prisoners go to these
var/list/holdingfacility = list()	//captured people go here
var/list/xeno_spawn = list()//Aliens spawn at these.
var/list/ERT_extras = list()
var/list/ERT_spawn = list()
var/list/ERT_addons = list()
var/list/ertcomp = list()
//	list/mazewarp = list()
var/list/tdome1 = list()
var/list/tdome2 = list()
var/list/tdomeobserve = list()
var/list/tdomeadmin = list()
var/list/prisonsecuritywarp = list()	//prison security goes to these
var/list/prisonwarped = list()	//list of players already warped
var/list/blobstart = list()
//	list/traitors = list()	//traitor list
var/list/cardinal = list( NORTH, SOUTH, EAST, WEST )
var/list/alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)

var/datum/station_state/start_state = null
var/datum/configuration/config = null
var/list/combatlog = list()
var/list/IClog = list()
var/list/OOClog = list()
var/list/adminlog = list()


//var/list/powernets = list()

var/Debug = 0	// global debug switch
var/Debug2 = 0

var/datum/debug/debugobj

var/datum/moduletypes/mods = new()

var/wavesecret = 0//Seems to be meteors
var/gravity_is_on = 1//Station gravity

var/shuttlecoming = 0

var/join_motd = null
var/forceblob = 0

	//airlockWireColorToIndex takes a number representing the wire color, e.g. the orange wire is always 1, the dark red wire is always 2, etc. It returns the index for whatever that wire does.
	//airlockIndexToWireColor does the opposite thing - it takes the index for what the wire does, for example AIRLOCK_WIRE_IDSCAN is 1, AIRLOCK_WIRE_POWER1 is 2, etc. It returns the wire color number.
	//airlockWireColorToFlag takes the wire color number and returns the flag for it (1, 2, 4, 8, 16, etc)
var/list/airlockWireColorToFlag = RandomAirlockWires()
var/list/airlockIndexToFlag
var/list/airlockIndexToWireColor
var/list/airlockWireColorToIndex
var/list/APCWireColorToFlag = RandomAPCWires()
var/list/APCIndexToFlag
var/list/APCIndexToWireColor
var/list/APCWireColorToIndex
var/list/BorgWireColorToFlag = RandomBorgWires()
var/list/BorgIndexToFlag
var/list/BorgIndexToWireColor
var/list/BorgWireColorToIndex
var/list/AAlarmWireColorToFlag = RandomAAlarmWires()
var/list/AAlarmIndexToFlag
var/list/AAlarmIndexToWireColor
var/list/AAlarmWireColorToIndex

#define SPEED_OF_LIGHT 3e8 //not exact but hey!
#define SPEED_OF_LIGHT_SQ 9e+16
#define FIRE_DAMAGE_MODIFIER 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
#define INFINITY 1e31 //closer then enough

	//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_NAME_LEN 26

#define shuttle_time_in_station 1800 // 3 minutes in the station
#define shuttle_time_to_arrive 6000 // 10 minutes to arrive

	//away missions
var/list/awaydestinations = list()	//a list of landmarks that the warpgate can take you to

	// For FTP requests. (i.e. downloading runtime logs.)
	// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0

var/outputstats = null // for stats gathering!


var/MAX_EX_FLAME_RANGE = 14

#define DECISECONDS_IN_A_DAY 864000
#define SAVEFILE_TIMEOUT 1			//using a timeout prevents savefiles triggering a runtime. Instead they will fail cleanly