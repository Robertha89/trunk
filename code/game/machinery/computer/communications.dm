//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

// The communications computer
/obj/machinery/computer/communications
	name = "Communications Console"
	desc = "This can be used for various important functions."
	icon_state = "comm"
	#ifdef NEWMAP
	req_access = list(access_bridge_area)
	#else
	req_access = list(access_heads)
	#endif
	circuit = "/obj/item/weapon/circuitboard/communications"
	var/prints_intercept = 1		//Round start report
	var/authenticated = 0			//Logged in 1 = normal 2 = captain or hos access
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg = 0
	var/aicurrmsg = 0
	var/state = STATE_DEFAULT
	var/aistate = STATE_DEFAULT
	var/message_cooldown = 0		//Delay for announcements
	var/centcomm_message_cooldown = 0
	var/tmp_alertlevel = 0
	var/const/STATE_DEFAULT = 1
	var/const/STATE_CALLSHUTTLE = 2
	var/const/STATE_CANCELSHUTTLE = 3
	var/const/STATE_MESSAGELIST = 4
	var/const/STATE_VIEWMESSAGE = 5
	var/const/STATE_DELMESSAGE = 6
	var/const/STATE_STATUSDISPLAY = 7
	var/const/STATE_ALERT_LEVEL = 8
	var/const/STATE_CONFIRM_LEVEL = 9

	var/status_display_freq = "1435"
	var/stat_msg1
	var/stat_msg2


	process()
		if(!..())
			return
		if(state != STATE_STATUSDISPLAY)
			src.updateDialog()
		return


	Topic(href, href_list)
		if(..())
			return
		if(src.z > 1)
			usr << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
			return
		usr.set_machine(src)

		if(!href_list["operation"])
			return
		switch(href_list["operation"])
			// main interface
			if("main")
				src.state = STATE_DEFAULT
			if("login")
				var/mob/M = usr
				if(istype(M,/mob/living/silicon))
					authenticated = 1
					updateUsrDialog()
					return

				var/obj/item/weapon/card/id/I = M.get_active_hand()
				if(istype(I, /obj/item/device/pda))
					var/obj/item/device/pda/pda = I
					I = pda.id
				if(istype(I))
					if(src.check_access(I))
						authenticated = 1
					#ifdef NEWMAP
					if(access_captain_area in I.access)
						authenticated = 2
					else if(access_hos_area in I.access)
						authenticated = 2
					else if(access_hop_area in I.access)
						authenticated = 2
					#else
					if(20 in I.access)
						authenticated = 2
					if(57 in I.access)
						authenticated = 2
					if(58 in I.access)
						authenticated = 2
					#endif
			if("logout")
				authenticated = 0

			if("announce")
				if(src.authenticated==2)
					if(message_cooldown)	return
					var/input = stripped_input(usr, "Please choose a message to announce to the station crew.", "What?")
					if(!input || !(usr in view(1,src)))
						return
					captain_announce(input)//This should really tell who is, IE HoP, CE, HoS, RD, Captain
					log_say("[key_name(usr)] has made a captain announcement: [input]")
					message_admins("[key_name_admin(usr)] has made a captain announcement.", 1)
					message_cooldown = 1
					spawn(600)//One minute cooldown
						message_cooldown = 0

			if("callshuttle")
				src.state = STATE_DEFAULT
				if(src.authenticated)
					src.state = STATE_CALLSHUTTLE
			if("callshuttle2")
				if(src.authenticated)
					call_shuttle_proc(usr)
					if(emergency_shuttle.online)
						post_status("shuttle")
				src.state = STATE_DEFAULT

			if("changeseclevel")
				src.state = STATE_ALERT_LEVEL
			if("cancelshuttle")
				src.state = STATE_DEFAULT
				if(src.authenticated)
					src.state = STATE_CANCELSHUTTLE
			if("cancelshuttle2")
				if(src.authenticated)
					cancel_call_proc(usr)
				src.state = STATE_DEFAULT
			if("messagelist")
				src.currmsg = 0
				src.state = STATE_MESSAGELIST
			if("viewmessage")
				src.state = STATE_VIEWMESSAGE
				if (!src.currmsg)
					if(href_list["message-num"])
						src.currmsg = text2num(href_list["message-num"])
					else
						src.state = STATE_MESSAGELIST
			if("delmessage")
				src.state = (src.currmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
			if("delmessage2")
				if(src.authenticated)
					if(src.currmsg)
						var/title = src.messagetitle[src.currmsg]
						var/text  = src.messagetext[src.currmsg]
						src.messagetitle.Remove(title)
						src.messagetext.Remove(text)
						if(src.currmsg == src.aicurrmsg)
							src.aicurrmsg = 0
						src.currmsg = 0
					src.state = STATE_MESSAGELIST
				else
					src.state = STATE_VIEWMESSAGE
			if("status")
				src.state = STATE_STATUSDISPLAY

			// Status display stuff
			if("setstat")
				switch(href_list["statdisp"])
					if("message")
						post_status("message", stat_msg1, stat_msg2)
					if("alert")
						post_status("alert", href_list["alert"])
					else
						post_status(href_list["statdisp"])

			if("setmsg1")
				stat_msg1 = reject_bad_text(input("Line 1", "Enter Message Text", stat_msg1) as text|null, 40)
				src.updateDialog()
			if("setmsg2")
				stat_msg2 = reject_bad_text(input("Line 2", "Enter Message Text", stat_msg2) as text|null, 40)
				src.updateDialog()
			if("securitylevel")
				src.tmp_alertlevel =  text2num(href_list["newalertlevel"])
				if(!tmp_alertlevel) tmp_alertlevel = 0
				state = STATE_CONFIRM_LEVEL


			if("swipeidseclevel")
				var/mob/M = usr
				var/obj/item/weapon/card/id/I = M.get_active_hand()
				if(istype(I, /obj/item/device/pda))
					var/obj/item/device/pda/pda = I
					I = pda.id
				if(I && istype(I))
					#ifdef NEWMAP
					if((access_captain_area in I.access || access_hos_area in I.access) && M.client.goodcurity)
						var/old_level = security_level
						if(!tmp_alertlevel) tmp_alertlevel = SEC_LEVEL_GREEN
						if(tmp_alertlevel < SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN
				//		if(tmp_alertlevel > SEC_LEVEL_BLUE) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
						set_security_level(tmp_alertlevel)
						if(security_level != old_level)
						//Only notify the admins if an actual change happened
							log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
							message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
					/*	switch(security_level)
							if(SEC_LEVEL_GREEN)
								feedback_inc("alert_comms_green",1)
							if(SEC_LEVEL_BLUE)
								feedback_inc("alert_comms_blue",1)*/
						tmp_alertlevel = 0
					#else
					if((access_captain in I.access || access_hos in I.access) && M.client.goodcurity)
						var/old_level = security_level
						if(!tmp_alertlevel) tmp_alertlevel = SEC_LEVEL_GREEN
						if(tmp_alertlevel < SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN
				//		if(tmp_alertlevel > SEC_LEVEL_BLUE) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
						set_security_level(tmp_alertlevel)
						if(security_level != old_level)
						//Only notify the admins if an actual change happened
							log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
							message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
						tmp_alertlevel = 0
					#endif
					else
						usr << "You are not authorized to do this."
						tmp_alertlevel = 0
					state = STATE_DEFAULT
				else
					usr << "You need to swipe your ID."
			// OMG CENTCOMM LETTERHEAD
			if("MessageCentcomm")
				if(src.authenticated==2)
					if(centcomm_message_cooldown)
						usr << "Arrays recycling.  Please stand by."
						return
					var/input = stripped_input(usr, "Please choose a message to transmit to Centcomm via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response.", "To abort, send an empty message.", "")
					if(!input || !(usr in view(1,src)))
						return
					Centcomm_announce(input, usr)
					usr << "Message transmitted."
					log_say("[key_name(usr)] has made a Centcomm announcement: [input]")
					centcomm_message_cooldown = 1
					spawn(6000)//10 minute cooldown
						centcomm_message_cooldown = 0

			if("MessageCentcommERT")
				if(src.authenticated==2)
					if(centcomm_message_cooldown)
						usr << "Arrays recycling.  Please stand by."
						return
					var/input = stripped_input(usr, "Please choose the reason you want an ERT team shipped to your station. This counts as a message sent to CentComm.  Please be aware abuse will lead to... termination.  Transmission does not guarantee a response.", "To abort, send an empty message.", "")
					if(!input || !(usr in view(1,src)))
						return
					ert_request(input, usr)
					usr << "Message transmitted."
					log_say("[key_name(usr)] has requested an ERT: [input]")
					centcomm_message_cooldown = 1
					spawn(12000)//10 minute cooldown
						centcomm_message_cooldown = 0


			// OMG SYNDICATE ...LETTERHEAD
			if("MessageSyndicate")
				if((src.authenticated==2) && (src.emagged))
					if(centcomm_message_cooldown)
						usr << "Arrays recycling.  Please stand by."
						return
					var/input = stripped_input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING CORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "To abort, send an empty message.", "")
					if(!input || !(usr in view(1,src)))
						return
					Syndicate_announce(input, usr)
					usr << "Message transmitted."
					log_say("[key_name(usr)] has made a Syndicate announcement: [input]")
					centcomm_message_cooldown = 1
					spawn(6000)//10 minute cooldown
						centcomm_message_cooldown = 0

			if("RestoreBackup")
				usr << "Backup routing data restored!"
				src.emagged = 0
				src.updateDialog()


		src.updateUsrDialog()
		return


	attackby(var/obj/I as obj, var/mob/user as mob)
		if(istype(I,/obj/item/weapon/card/emag/))
			src.emagged = 1
			user << "You scramble the communication routing circuits!"
		..()

	attack_ai(var/mob/user as mob)
		return src.attack_hand(user)


	attack_paw(var/mob/user as mob)
		return src.attack_hand(user)


	attack_hand(var/mob/living/user as mob)
		if(..())
			return
		if(src.z > 6)
			user << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
			return

		user.set_machine(src)
		var/dat = "<head><title>Communications Console</title></head><body>"
		if(emergency_shuttle.online && emergency_shuttle.location==0)
			var/timeleft = emergency_shuttle.timeleft()
			dat += "<B>Emergency shuttle</B>\n<BR>\nETA: [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]<BR>"

		/*if(istype(user, /mob/living/silicon))
			var/dat2 = src.interact_ai(user) // give the AI a different interact proc to limit its access
			if(dat2)
				dat +=  dat2
				user << browse(dat, "window=communications;size=400x500")
				onclose(user, "communications")
			return*/

		switch(src.state)
			if(STATE_DEFAULT)
				if(src.authenticated)
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=logout'>Log Out</A> \]"
					if(emergency_shuttle.location==0 && !emergency_shuttle.online)
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=callshuttle'>Call Emergency Shuttle</A> \]"
					if(src.authenticated==2 && !istype(user,/mob/living/silicon))//Silicons are not allowed to access higher level functions
						if(emergency_shuttle.location==0 && emergency_shuttle.online)
							dat += "<BR>\[ <A HREF='?src=\ref[src];operation=cancelshuttle'>Cancel Shuttle Call</A> \]"
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=announce'>Make An Announcement</A> \]"
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=MessageCentcommERT'>Request an ERT from Centcomm</A> \]"
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=changeseclevel'>Change alert level</A> \]"
						if(src.emagged == 0)
							dat += "<BR>\[ <A HREF='?src=\ref[src];operation=MessageCentcomm'>Send an emergency message to Centcomm</A> \]"
						else
							dat += "<BR>\[ <A HREF='?src=\ref[src];operation=MessageSyndicate'>Send an emergency message to \[UNKNOWN\]</A> \]"
							dat += "<BR>\[ <A HREF='?src=\ref[src];operation=RestoreBackup'>Restore Backup Routing Data</A> \]"

					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=status'>Set Status Display</A> \]"
				else
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=login'>Log In</A> \]"

				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=messagelist'>Message List</A> \]"
			if(STATE_CALLSHUTTLE)
				dat += "Are you sure you want to call the shuttle? \[ <A HREF='?src=\ref[src];operation=callshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=main'>Cancel</A> \]"
			if(STATE_CANCELSHUTTLE)
				dat += "Are you sure you want to cancel the shuttle? \[ <A HREF='?src=\ref[src];operation=cancelshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=main'>Cancel</A> \]"
			if(STATE_MESSAGELIST)
				dat += "Messages:"
				for(var/i = 1; i<=src.messagetitle.len; i++)
					dat += "<BR><A HREF='?src=\ref[src];operation=viewmessage;message-num=[i]'>[src.messagetitle[i]]</A>"
			if(STATE_VIEWMESSAGE)
				if (src.currmsg)
					dat += "<B>[src.messagetitle[src.currmsg]]</B><BR><BR>[src.messagetext[src.currmsg]]"
					if (src.authenticated)
						dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=delmessage'>Delete \]"
				else
					src.state = STATE_MESSAGELIST
					src.attack_hand(user)
					return
			if(STATE_DELMESSAGE)
				if (src.currmsg)
					dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
				else
					src.state = STATE_MESSAGELIST
					src.attack_hand(user)
					return
			if(STATE_STATUSDISPLAY)
				dat += "Set Status Displays<BR>"
				dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
				dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
				dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=message'>Message</A> \]"
				dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
				dat += "<li> Line 2: <A HREF='?src=\ref[src];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
				dat += "\[ Alert: <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=default'>None</A> |"
				dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
				dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
				dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"
			if(STATE_ALERT_LEVEL)
				dat += "Current alert level: [get_security_level()]<BR>"
				if(security_level == SEC_LEVEL_DELTA)
					dat += "<font color='red'><b>You are unable to lower the level from Delta.</b></font>"
				else
					dat += "<A HREF='?src=\ref[src];operation=securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A><BR>"
					dat += "<A HREF='?src=\ref[src];operation=securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
					if((user.mind.assigned_role == "Captain" || user.mind.assigned_role == "Head of Personnel" || user.mind.assigned_role == "Head of Security" || user.mind.assigned_role == "Warden") && user.client.goodcurity)
						dat += "<A HREF='?src=\ref[src];operation=securitylevel;newalertlevel=[SEC_LEVEL_RED]'>Red (Make sure this is needed)</A><BR>"
						dat += "<A HREF='?src=\ref[src];operation=securitylevel;newalertlevel=[SEC_LEVEL_DELTA]'>Delta (Make sure this is needed, this cannot be reverted)</A><BR>"
			if(STATE_CONFIRM_LEVEL)
				dat += "Current alert level: [get_security_level()]<BR>"
				dat += "Confirm the change to: [num2seclevel(tmp_alertlevel)]<BR>"
				dat += "<A HREF='?src=\ref[src];operation=swipeidseclevel'>Swipe ID</A> to confirm change.<BR>"

		dat += "<BR>\[ [(src.state != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
		user << browse(dat, "window=communications;size=400x500")
		onclose(user, "communications")
		return


	proc/post_status(var/command, var/data1, var/data2)
		var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)
		if(!frequency) return

		var/datum/signal/status_signal = new
		status_signal.source = src
		status_signal.transmission_method = 1
		status_signal.data["command"] = command

		switch(command)
			if("message")
				status_signal.data["msg1"] = data1
				status_signal.data["msg2"] = data2
			if("alert")
				status_signal.data["picture_state"] = data1

		frequency.post_signal(src, status_signal)
		return




/proc/enable_prison_shuttle(var/mob/user)
	for(var/obj/machinery/computer/prison_shuttle/PS in world)
		PS.allowedtocall = !(PS.allowedtocall)


/proc/call_shuttle_proc(var/mob/user)
	if ((!( ticker ) || emergency_shuttle.location))
		return

	if(sent_strike_team == 1)
		user << "Centcom will not allow the shuttle to be called."
		return

	if(world.time < 6000) // Ten minute grace period to let the game get going without lolmetagaming. -- TLE
		user << "The emergency shuttle is refueling. Please wait another [round((6000-world.time)/600)] minutes before trying again."
		return

	if(emergency_shuttle.direction == -1)
		user << "The emergency shuttle may not be called while returning to CentCom."
		return

	if(emergency_shuttle.online)
		user << "The emergency shuttle is already on its way."
		return

	if(ticker.mode.name == "blob")
		user << "Under directive 7-10, [station_name()] is quarantined until further notice."
		return

	emergency_shuttle.incall()
	log_game("[key_name(user)] has called the shuttle.")
	message_admins("[key_name_admin(user)] has called the shuttle.", 1)
	captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
	world << sound('sound/AI/shuttlecalled.ogg')

	return


/proc/cancel_call_proc(var/mob/user)
	if(istype(user, /mob/living/silicon))
		user << "\red Access Denied"
		return
	if ((!( ticker ) || emergency_shuttle.location || emergency_shuttle.direction == 0 || emergency_shuttle.timeleft() < 300))
		return
	if((ticker.mode.name == "blob")||(ticker.mode.name == "meteor"))
		return

	if(emergency_shuttle.direction != -1 && emergency_shuttle.online) //check that shuttle isn't already heading to centcomm
		emergency_shuttle.recall()
		log_game("[key_name(user)] has recalled the shuttle.")
		message_admins("[key_name_admin(user)] has recalled the shuttle.", 1)
	return


/obj/machinery/computer/communications/Del()
	for(var/obj/machinery/computer/communications/commconsole in world)
		if(istype(commconsole.loc,/turf) && commconsole != src && commconsole.z == 1)
			return ..()

	for(var/obj/item/weapon/circuitboard/communications/commboard in world)
		if(istype(commboard.loc,/turf) || istype(commboard.loc,/obj/item/weapon/storage))
			return ..()

	for(var/mob/living/silicon/ai/shuttlecaller in player_list)
		if(!shuttlecaller.stat && shuttlecaller.client && istype(shuttlecaller.loc,/turf) && shuttlecaller.z == 1)
			return ..()

	if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction" || sent_strike_team)
		return ..()

	emergency_shuttle.incall(2)
	log_game("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
	message_admins("All the AIs, comm consoles and boards are destroyed. Shuttle called.", 1)
	captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
	world << sound('sound/AI/shuttlecalled.ogg')
	..()
	return

/obj/item/weapon/circuitboard/communications/Del()

	for(var/obj/machinery/computer/communications/commconsole in world)
		if(istype(commconsole.loc,/turf))
			return ..()

	for(var/obj/item/weapon/circuitboard/communications/commboard in world)
		if((istype(commboard.loc,/turf) || istype(commboard.loc,/obj/item/weapon/storage)) && commboard != src)
			return ..()

	for(var/mob/living/silicon/ai/shuttlecaller in player_list)
		if(!shuttlecaller.stat && shuttlecaller.client && istype(shuttlecaller.loc,/turf))
			return ..()

	if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction" || sent_strike_team)
		return ..()

	emergency_shuttle.incall(2)
	log_game("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
	message_admins("All the AIs, comm consoles and boards are destroyed. Shuttle called.", 1)
	captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
	world << sound('sound/AI/shuttlecalled.ogg')
	..()
	return



/*
/obj/machinery/computer/communications/proc/interact_ai(var/mob/living/silicon/ai/user as mob)
	var/dat = ""
	switch(src.aistate)
		if(STATE_DEFAULT)
			if(emergency_shuttle.location==0 && !emergency_shuttle.online)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-callshuttle'>Call Emergency Shuttle</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-messagelist'>Message List</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-status'>Set Status Display</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += "Are you sure you want to call the shuttle? \[ <A HREF='?src=\ref[src];operation=ai-callshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=ai-main'>Cancel</A> \]"
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=src.messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=ai-viewmessage;message-num=[i]'>[src.messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (src.aicurrmsg)
				dat += "<B>[src.messagetitle[src.aicurrmsg]]</B><BR><BR>[src.messagetext[src.aicurrmsg]]"
				dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=ai-delmessage'>Delete</A> \]"
			else
				src.aistate = STATE_MESSAGELIST
				src.attack_hand(user)
				return null
		if(STATE_DELMESSAGE)
			if(src.aicurrmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=ai-delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"
			else
				src.aistate = STATE_MESSAGELIST
				src.attack_hand(user)
				return

		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=\ref[src];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"


	dat += "<BR>\[ [(src.aistate != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=ai-main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	return dat*/


/*

			// AI interface
			if("ai-main")
				src.aicurrmsg = 0
				src.aistate = STATE_DEFAULT
			if("ai-callshuttle")
				src.aistate = STATE_CALLSHUTTLE
			if("ai-callshuttle2")
				call_shuttle_proc(usr)
				src.aistate = STATE_DEFAULT
			if("ai-messagelist")
				src.aicurrmsg = 0
				src.aistate = STATE_MESSAGELIST
			if("ai-viewmessage")
				src.aistate = STATE_VIEWMESSAGE
				if (!src.aicurrmsg)
					if(href_list["message-num"])
						src.aicurrmsg = text2num(href_list["message-num"])
					else
						src.aistate = STATE_MESSAGELIST
			if("ai-delmessage")
				src.aistate = (src.aicurrmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
			if("ai-delmessage2")
				if(src.aicurrmsg)
					var/title = src.messagetitle[src.aicurrmsg]
					var/text  = src.messagetext[src.aicurrmsg]
					src.messagetitle.Remove(title)
					src.messagetext.Remove(text)
					if(src.currmsg == src.aicurrmsg)
						src.currmsg = 0
					src.aicurrmsg = 0
				src.aistate = STATE_MESSAGELIST
			if("ai-status")
				src.aistate = STATE_STATUSDISPLAY

			if("securitylevel")
				src.tmp_alertlevel = text2num( href_list["newalertlevel"] )
				if(!tmp_alertlevel) tmp_alertlevel = 0
				state = STATE_CONFIRM_LEVEL

			if("changeseclevel")
				state = STATE_ALERT_LEVEL*/