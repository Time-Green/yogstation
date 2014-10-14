
/var/list/tickets_list = list()
/var/ticket_count = 0;

/datum/admin_ticket
	var/ticket_id
	var/mob/owner
	var/title
	var/list/log = list()
	var/resolved = 0
	var/list/monitors = list()
	var/mob/handling_admin = null
	//var/log_file

/datum/admin_ticket/New(nowner, ntitle)
	owner = nowner
	if(ntitle)
		title = format_text(ntitle)
	ticket_count++
	ticket_id = ticket_count

	//var/path = "data/logs/tickets/[time2text(world.realtime,"YYYY/MM-Month/DD-Day/[owner ? owner.client.ckey : owner]-[ticket_id]")].html"
	//log_file = file(path)

	// var/ai_found = isAI(owner.ckey)
	// var/msg = "<span class='boldnotice'><font color=red>New ticket created: </font>[key_name(owner, 1)] (<a href='?_src_=holder;adminmoreinfo=\ref[owner.mob]'>?</a>) (<a href='?_src_=holder;adminplayeropts=\ref[owner.mob]'>PP</a>) (<a href='?_src_=vars;Vars=\ref[owner.mob]'>VV</a>) (<a href='?_src_=holder;subtlemessage=\ref[owner.mob]'>SM</a>) (<a href='?_src_=holder;adminplayerobservejump=\ref[owner.mob]'>JMP</a>) (<a href='?_src_=holder;secretsadmin=check_antagonist'>CA</a>) [ai_found ? " (<a href='?_src_=holder;adminchecklaws=\ref[owner.mob]'>CL</a>)" : ""]:</b> [title] <a href='?src=\ref[owner];action=view_admin_ticket;ticket=\ref[src]'>View</a> <a href='?src=\ref[owner];action=monitor_admin_ticket;ticket=\ref[src]'>(Un)Monitor</a> <a href='?src=\ref[owner];action=resolve_admin_ticket;ticket=\ref[src]'>(Un)Resolve</a></span>"
	var/msg = "<span class='boldnotice'><font color=red>New ticket created: </font>[key_name(owner, 1)]: [title] <b><a href='?src=\ref[owner];action=view_admin_ticket;ticket=\ref[src]'>View</a></b></span>"

	//send this msg to all admins
	var/admin_number_total = 0		//Total number of admins
	var/admin_number_afk = 0		//Holds the number of admins who are afk
	var/admin_number_ignored = 0	//Holds the number of admins without +BAN (so admins who are not really admins)
	var/admin_number_decrease = 0	//Holds the number of admins with are afk, ignored or both
	for(var/client/X in admins)
		admin_number_total++
		var/invalid = 0
		if(!check_rights_for(X, R_BAN))
			admin_number_ignored++
			invalid = 1
		if(X.is_afk())
			admin_number_afk++
			invalid = 1
		if(invalid)
			admin_number_decrease++
		if(X.prefs.toggles & SOUND_ADMINHELP)
			X << 'sound/effects/adminhelp.ogg'
		X << msg

	owner << "<font color='blue'><b>Ticket</b> created for <b>Admins</b>: \"[title]\" <b><a href='?src=\ref[owner];action=view_admin_ticket;ticket=\ref[src]'>View</a></b></font>"

	//var/time = time2text(world.timeofday, "hh:mm")
	log += "<b>[title]</b>"
	log += "[gameTimestamp()] - Ticket created by <b>[owner]</b>"

	var/admin_number_present = admin_number_total - admin_number_decrease	//Number of admins who are neither afk nor invalid
	log_admin("TICKET: [key_name(owner)]: [title] - heard by [admin_number_present] non-AFK admins who have +BAN.")
	if(admin_number_present <= 0)
		if(!admin_number_afk && !admin_number_ignored)
			send2irc(owner.client.ckey, "Ticket - [title] - No admins online")
		else
			send2irc(owner.client.ckey, "Ticket - [title] - All admins AFK ([admin_number_afk]/[admin_number_total]) or skipped ([admin_number_ignored]/[admin_number_total])")
