GLOBAL_DATUM(battle_royale_controller, /datum/battle_royale_controller)

///List of all /datum/battle_royale_data/custom that have been created, indexed by their active_time
GLOBAL_LIST_EMPTY(custom_battle_royale_data) //might be able to convert this to a static var on the controller

#define COIN_PRIZE "Coins"
#define PLAYER_HEALTH_VALUE 150
//Battle royale controller, IF THERE ARE MULTIPLE OF THESE SOMETHING HAS GONE VERY WRONG
/datum/battle_royale_controller
	///Is this controller active and processing
	var/active = FALSE
	///How long has this datum been active for
	var/active_for = 0
	///list of our /datum/battle_royale_data datums
	var/list/data_datums
	///list of all our players assigned "antag" datums
	var/list/players = list()
	///Tracker var for what data in data_datums we should use next
	var/next_data_datum_value = 1
	///Ref to the /datum/battle_royale_data we are currently using
	var/datum/battle_royale_data/current_data
	///Ref to our barrier controller
	var/datum/royale_storm_controller/storm_controller = new
	///Assoc list of prizes for the winner
	var/list/prizes = list(COIN_PRIZE = 0,
						HIGH_THREAT = 0,
						MEDIUM_THREAT = 0,
						LOW_THREAT = 0)
	///What is the expected time for the entire station to be covered in storms
	var/max_duration = 0
	///Assoc list of loot tables to use
	var/static/list/loot_tables = list(COMMON_LOOT_TABLE = GLOB.royale_common_loot,
									UTILITY_LOOT_TABLE = GLOB.royale_utility_loot,
									RARE_LOOT_TABLE = GLOB.royale_rare_loot,
									SUPER_RARE_LOOT_TABLE = GLOB.royale_super_rare_loot,
									MISC_LOOT_TABLE = GLOB.royale_misc_loot)

/datum/battle_royale_controller/New()
	. = ..()
	if(GLOB.battle_royale_controller)
		message_admins("Battle royale controller datum created with already existing controller, force ending the current royale of the old controller and qdeling it.")
		QDEL_NULL(GLOB.battle_royale_controller)

	GLOB.battle_royale_controller = src
	storm_controller.royale_controller = src

/datum/battle_royale_controller/Destroy(force, ...)
	message_admins("Battle royale controller datum destroyed, force ending it's current royale.")
	GLOB.battle_royale_controller = null
	current_data = null
	QDEL_LIST(data_datums)
	QDEL_NULL(storm_controller)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/battle_royale_controller/process(seconds_per_tick)
	if(!active)
		message_admins("Battle royale controller attempting to process while inactive, stopping proccessing.")
		STOP_PROCESSING(SSprocessing, src)
		return

	if(!current_data)
		message_admins("Battle royale controller attempting to process without set current_data, stopping processing.")
		deactivate()
		return

	active_for += seconds_per_tick SECONDS
	if(check_data())
		current_data = data_datums["[next_data_datum_value]"]
		next_data_datum_value++

	spawn_loot_pods(calculate_spawned_loot_pods(seconds_per_tick))

	if(SPT_PROB(current_data.rare_drop_prob, 1))
		spawn_rare_drop()

	if(SPT_PROB(current_data.super_drop_prob, 1))
		spawn_super_drop()

///Setup and start a royale
/datum/battle_royale_controller/proc/setup(fast = FALSE, custom = FALSE, mob/user)
	if(active)
		if(user)
			to_chat(user, span_warning("A game has already started!"))
		return

	active = TRUE //some external things check for this so we want this even while we are not actually active
	build_data_datums(fast, custom)
	if(storm_controller.start_consuming_delay == -1) //have to use an exact value check as admins can set the delay to 0
		storm_controller.start_consuming_delay = (fast ? 2 MINUTES : 5 MINUTES)

	send_to_playing_players(span_ratvar("Battle Royale will begin soon..."))
	GLOB.enter_allowed = FALSE
	GLOB.ghost_role_flags = NONE
	world.update_status()
	if(SSticker.current_state < GAME_STATE_PREGAME)
		send_to_playing_players(span_boldannounce("Battle Royale: Waiting for server to be ready..."))
		SSticker.start_immediately = FALSE
		UNTIL(SSticker.current_state >= GAME_STATE_PREGAME)
		send_to_playing_players(span_boldannounce("Battle Royale: Done!"))

	if(SSticker.current_state == GAME_STATE_PREGAME)
		for(var/mob/dead/new_player/player in GLOB.player_list)
			to_chat(player, span_greenannounce("You have been forced as an observer. When the prompt to join battle royale comes up, press yes. \
											This is normal and you are still in queue to play."))
			player.ready = FALSE
			player.make_me_an_observer()
		send_to_playing_players(span_boldannounce("Battle Royale: Force-starting game."))
		SSticker.start_immediately = TRUE

	send_to_playing_players(span_boldannounce("Battle Royale: Clearing world mobs."))
	for(var/mob/living/mob as() in GLOB.mob_living_list)
		mob.dust(TRUE, FALSE, TRUE)
		CHECK_TICK

	send_setup_messages()

/datum/battle_royale_controller/proc/send_setup_messages()
	sound_to_playing_players('sound/misc/server-ready.ogg', 50, FALSE)
	send_to_playing_players(span_greenannounce("Battle Royale: STARTING IN 30 SECONDS."))
	send_to_playing_players(span_greenannounce("If you are on the main menu, observe immediately to sign up. (You will be prompted in 30 seconds.)"))
	sleep(30 SECONDS)
	power_restore()
	send_to_playing_players(span_boldannounce("Battle Royale: STARTING IN 5 SECONDS."))
	send_to_playing_players(span_greenannounce("Make sure to hit yes to the sign up message given to all observing players."))
	sleep(5 SECONDS)
	send_to_playing_players(span_boldannounce("Battle Royale: Starting game."))
	start_royale()

///Start the royale
/datum/battle_royale_controller/proc/start_royale()
	if(!do_ghost_drop("Would you like to partake in BATTLE ROYALE?"))
		message_admins("No participants for battle royale, stopping royale.")
		end_royale()
		return

	storm_controller.setup()
	sound_to_playing_players('sound/misc/airraid.ogg', 100, FALSE)
	send_to_playing_players(span_boldannounce("A 1 minute grace period has been established. Good luck."))
	send_to_playing_players(span_boldannounce("WARNING: YOU WILL BE GIBBED IF YOU LEAVE THE STATION Z-LEVEL!"))
	send_to_playing_players(span_boldannounce("[length(players)] people remain..."))

	activate()
	if(length(data_datums))
		current_data = data_datums["[next_data_datum_value]"]
		next_data_datum_value++

	if(current_data)
		spawn_loot_pods(150)

/datum/battle_royale_controller/proc/do_ghost_drop(message, turf/turf_override, given_poll_time = 60 SECONDS, grace = TRUE)
	var/list/participants = list() //poll_ghost_candidates() requires station sentience to be enabled, so we have to manually do it
	for(var/mob/dead/observer/ghost_player in GLOB.player_list)
		participants += ghost_player

	participants = poll_candidates("[message]", poll_time = given_poll_time, group = participants)
	if(!length(participants))
		return FALSE

	players = list()
	for(var/mob/participant in participants)
		var/key = participant.key
		var/turf/spawn_turf = turf_override ? turf_override : get_safe_random_station_turf() //could also make this pick from assistant spawns
		var/obj/structure/closet/supplypod/centcompod/pod = new
		var/mob/living/carbon/human/spawned_human = new(pod)
		spawned_human.key = key
		if(grace)
			ADD_TRAIT(spawned_human, TRAIT_PACIFISM, BATTLE_ROYALE_TRAIT)
			spawned_human.status_flags |= GODMODE
			var/datum/action/cooldown/spell/aoe/knock/knock_spell = new
			knock_spell.Grant(spawned_human)
			to_chat(spawned_human, span_notice("You have been given knock and pacifism for 1 minute."))
			addtimer(CALLBACK(src, PROC_REF(remove_grace), spawned_human), 1 MINUTES)

		spawned_human.equipOutfit(/datum/outfit/job/assistant)
		spawned_human.setMaxHealth(PLAYER_HEALTH_VALUE)
		spawned_human.set_health(PLAYER_HEALTH_VALUE)
		var/obj/item/implant/weapons_auth/auth = new
		auth.implant(spawned_human)
		players += spawned_human.mind?.add_antag_datum(/datum/antagonist/battle_royale)
		new /obj/effect/pod_landingzone(spawn_turf, pod)
		CHECK_TICK
	return TRUE

///Remove grace period buffs and effects
/datum/battle_royale_controller/proc/remove_grace(mob/player)
	player.status_flags &= ~GODMODE
	REMOVE_TRAIT(player, TRAIT_PACIFISM, BATTLE_ROYALE_TRAIT)
	var/datum/action/cooldown/spell/aoe/knock/knock_spell = locate() in player.actions
	if(knock_spell)
		qdel(knock_spell)
	to_chat(player, span_greenannounce("You are no longer a pacifist. Be the last spessmens standing."))

///End a battle royale
/datum/battle_royale_controller/proc/end_royale(mob/living/winner)
	deactivate()
	storm_controller?.end_storm()
	storm_controller?.stop_storm()
	SSticker.force_ending = TRUE
	if(winner && !QDELETED(winner))
		winner.revive(ADMIN_HEAL_ALL)
		send_to_playing_players(span_ratvar("VICTORY ROYALE!"))
		send_to_playing_players(span_ratvar("[key_name(winner)] is the winner!"))
		for(var/prize in prizes)
			if(!prizes[prize])
				continue
			if(prize == COIN_PRIZE)
				winner.client.prefs.adjust_metacoins(winner.ckey, prizes[prize], "Won battle royale.")
			else
				winner.client.client_token_holder.adjust_antag_tokens(prize, prizes[prize])
				to_chat(winner, span_boldnotice("You have gained [prizes[prize]] [prize] token(s) for winning battle royale."))

		var/turf/winner_turf = get_turf(winner)
		if(winner_turf)
			new /obj/item/melee/supermatter_sword(winner_turf)
			do_ghost_drop("You you like to be part of a horde of assistants?", winner_turf, 10 SECONDS, FALSE)
			send_to_playing_players(span_userdanger("THE HORDE COMITH."))

///Check if we should end a battle royale
/datum/battle_royale_controller/proc/check_ending()
	var/list/living_players = list()
	for(var/datum/antagonist/battle_royale/antag_datum in players)
		if(!antag_datum.died && antag_datum.owner?.current)
			living_players += antag_datum.owner.current

	if(length(living_players) <= 1)
		end_royale(length(living_players) == 1 ? living_players[1] : null)

///Return how many loot pods to spawn
/datum/battle_royale_controller/proc/calculate_spawned_loot_pods(seconds)
	var/static/persistent_count //so we can spawn less then one pod per second(process)
	if(!current_data.pods_per_second || !seconds)
		return FALSE

	var/count = current_data.pods_per_second * seconds
	if(!count)
		return FALSE

	count = 10 * count //this allows us to avoid floating points
	count = truncate(count)
	if(!persistent_count)
		persistent_count = count
	else
		persistent_count += count

	var/spawn_count = FLOOR(persistent_count, 10)
	persistent_count = max(persistent_count - spawn_count, 0)
	if(spawn_count)
		return spawn_count / 10
	else
		return FALSE

///Spawns loot pods based on passed count
/datum/battle_royale_controller/proc/spawn_loot_pods(count)
	if(!current_data)
		message_admins("Battle royale controller attempting to call spawn_loot_pods() without set current_data, aborting.")
		return

	for(var/pods_to_spawn in 1 to count)
		do_loot_drop()
		CHECK_TICK

///Return TRUE if we should move to our next data_datums entry. Otherwise, return FALSE
/datum/battle_royale_controller/proc/check_data()
	if(!current_data)
		message_admins("Battle royale controller attempting to call check_data() without set current_data, stopping processing.")
		deactivate()
		return FALSE

	if(!data_datums["[next_data_datum_value]"])
		return FALSE

	var/datum/battle_royale_data/next_data = data_datums["[next_data_datum_value]"]
	if(active_for >= next_data?.active_time)
		return TRUE
	return FALSE

///Build our data_datums list, if fast is TRUE then we will use the faster pre-made battle_royale_data set, if custom is TRUE then we will use custom data if possible
/datum/battle_royale_controller/proc/build_data_datums(fast = FALSE, custom = FALSE)
	QDEL_LIST(data_datums)
	var/list/new_data_datums = list()
	var/highest_active_time = 0
	if(custom && length(GLOB.custom_battle_royale_data))
		for(var/data_value in GLOB.custom_battle_royale_data)
			var/datum/battle_royale_data/custom/data_datum = GLOB.custom_battle_royale_data[data_value]
			new_data_datums["[data_datum.active_time]"] = data_datum
			if(data_datum.active_time > highest_active_time)
				highest_active_time = data_datum.active_time
	else
		for(var/datum/battle_royale_data/data_datum as anything in subtypesof(/datum/battle_royale_data)) //need to get this to work
			data_datum = new data_datum()
			if(!data_datum.active_time||istype(data_datum, /datum/battle_royale_data/custom)||istype(data_datum, fast?/datum/battle_royale_data/normal : /datum/battle_royale_data/fast))
				qdel(data_datum)
				continue

			if(new_data_datums["[data_datum.active_time]"])
				message_admins("[data_datum] created with duplicate active_time to [new_data_datums["[data_datum.active_time]"]] in new_data_datums.")
				qdel(data_datum)
				continue

			new_data_datums["[data_datum.active_time]"] = data_datum
			if(data_datum.active_time > highest_active_time)
				highest_active_time = data_datum.active_time

	max_duration = 0
	var/data_datums_iterator = 0
	for(var/i in 1 to highest_active_time)
		if(new_data_datums["[i]"])
			var/datum/battle_royale_data/data_datum = new_data_datums["[i]"]
			new_data_datums -= "[i]"
			new_data_datums["[data_datums_iterator++]"] = data_datum
			if(data_datum.final_time)
				max_duration = data_datum.final_time

	if(!max_duration)
		message_admins("No max length set for battle royale.")
	data_datums = new_data_datums

/datum/battle_royale_controller/proc/activate()
	active = TRUE
	START_PROCESSING(SSprocessing, src)

/datum/battle_royale_controller/proc/deactivate()
	active = FALSE
	STOP_PROCESSING(SSprocessing, src)
	storm_controller?.stop_storm()

/datum/battle_royale_controller/proc/spawn_rare_drop()
	do_loot_drop(RARE_LOOT_TABLE, 15 SECONDS, "Incoming extended supply materials.")

/datum/battle_royale_controller/proc/spawn_super_drop()
	do_loot_drop(SUPER_RARE_LOOT_TABLE, 5 MINUTES, "We found a weird looking package in the back of our warehouse. \
				We have no idea what is in it, but it is marked as incredibily dangerous and could be a superweapon.")

#define MINIMUM_USEFUL_DROP_TIME 1 MINUTES
///Reduce the extra landing time of rare and super drops to make sure they wont land after royale end
/datum/battle_royale_controller/proc/calculate_drop_time(input_delay = 0)
	return max(0.4 SECONDS, min(max_duration - MINIMUM_USEFUL_DROP_TIME, active_for + input_delay) - active_for)

///Actually spawn the loot and pod for it
/datum/battle_royale_controller/proc/do_loot_drop(table, delay, announcement)
	if(!current_data)
		return

	var/list/turf_list = GLOB.station_turfs.Copy() - storm_controller.storms
	if(!length(turf_list))
		return

	if(!table)
		table = pick_weight(list(COMMON_LOOT_TABLE = current_data.common_weight,
								UTILITY_LOOT_TABLE = current_data.utility_weight,
								RARE_LOOT_TABLE = current_data.rare_weight,
								SUPER_RARE_LOOT_TABLE = current_data.super_rare_weight,
								MISC_LOOT_TABLE = current_data.misc_weight))

	var/list/picked_loot = add_loot_items(pick_weight(loot_tables[table]))

	if(prob(current_data?.extra_loot_prob))
		picked_loot = add_loot_items(pick_weight(GLOB.royale_extra_loot), picked_loot)

	var/drop_time = calculate_drop_time(delay)
	var/turf/targeted_turf
	shuffle_inplace(turf_list)
	for(var/turf/possible_turf in turf_list)
		if(isclosedturf(possible_turf))
			continue
		targeted_turf = possible_turf
		break

	podspawn(list("target" = targeted_turf,
				"style" = ((table == MISC_LOOT_TABLE) ? STYLE_HONK : STYLE_BOX),
				"path" = /obj/structure/closet/supplypod/battle_royale,
				"spawn" = picked_loot,
				"delays" = list(POD_TRANSIT = 1, POD_FALLING = drop_time, POD_OPENING = 1 SECONDS, POD_LEAVING = 3 SECONDS)))

	if(announcement)
		priority_announce("[announcement] \nExpected Drop Location: [get_area(targeted_turf)]\n ETA: [drop_time/10] Seconds.", "High Command Supply Control",
						SSstation.announcer.get_rand_alert_sound())

/datum/battle_royale_controller/proc/add_loot_items(input_loot, list/input_list = list())
	if(!islist(input_list))
		input_list = list(input_list)

	if(islist(input_loot))
		for(var/entry as anything in input_loot)
			for(var/count in 1 to input_loot[entry])
				input_list += entry
	else
		input_list += input_loot
	return input_list

/datum/battle_royale_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BattleRoyalePanel")
		ui.open()

/datum/battle_royale_controller/ui_state(mob/user)
	return GLOB.fun_state

/datum/battle_royale_controller/ui_static_data(mob/user)

/datum/battle_royale_controller/ui_data(mob/user)
	var/list/data = list()
	var/list/current_data_values = list()
	var/list/prize_list = list()
	var/list/custom_dataset_list = list()
	if(current_data)
		UNTYPED_LIST_ADD(current_data_values, list(
			"active_time" = current_data.active_time,
			"common_weight" = current_data.common_weight,
			"utility_weight" = current_data.utility_weight,
			"rare_weight" = current_data.rare_weight,
			"super_rare_weight" = current_data.super_rare_weight,
			"misc_weight" = current_data.misc_weight,
			"extra_loot_prob" = current_data.extra_loot_prob,
			"rare_drop_prob" = current_data.rare_drop_prob,
			"super_drop_prob" = current_data.super_drop_prob,
			"pods_per_second" = current_data.pods_per_second,
		))

	for(var/data_value as anything in GLOB.custom_battle_royale_data)
		var/datum/battle_royale_data/custom_data = GLOB.custom_battle_royale_data[data_value]
		UNTYPED_LIST_ADD(custom_dataset_list, list(
			"active_time" = custom_data.active_time,
			"common_weight" = custom_data.common_weight,
			"utility_weight" = custom_data.utility_weight,
			"rare_weight" = custom_data.rare_weight,
			"super_rare_weight" = custom_data.super_rare_weight,
			"misc_weight" = custom_data.misc_weight,
			"extra_loot_prob" = custom_data.extra_loot_prob,
			"rare_drop_prob" = custom_data.rare_drop_prob,
			"super_drop_prob" = custom_data.super_drop_prob,
			"pods_per_second" = custom_data.pods_per_second,
			"final_time" = custom_data.final_time,
			"converted_time" = "[DisplayTimeText(custom_data.active_time)]"
		))

	UNTYPED_LIST_ADD(prize_list, list(
		"coins" = prizes[COIN_PRIZE],
		"high_tokens" = prizes[HIGH_THREAT],
		"medium_tokens" = prizes[MEDIUM_THREAT],
		"low_tokens" = prizes[LOW_THREAT]
	))
	data["active_dataset"] = current_data_values
	data["prizes"] = prize_list
	data["max_duration"] = max_duration ? DisplayTimeText(max_duration) : 0
	data["custom_datasets"] = custom_dataset_list
	data["storm_delay"] = (storm_controller.start_consuming_delay == -1 ? null : DisplayTimeText(storm_controller.start_consuming_delay))
	return data

/datum/battle_royale_controller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(!check_rights(R_FUN) || ..())
		return

	switch(action)
		if("start")
			if(active)
				to_chat(usr, span_warning("A game has already started!"))
				return

			var/input = tgui_alert(usr, "Would you like to start a battle royale?", "Battle Royale", list("Yes", "No"))
			if(input != "Yes")
				return

			var/second_input = tgui_alert(usr, "Would you like to use custom datasets?", "Battle Royale", list("Yes", "No"))
			if(second_input != "Yes")
				second_input = tgui_alert(usr, "What preset would you like to use?", "Battle Royale", list("Normal(20 min max duration)", "Fast(10 min max duration)"))

			input = tgui_alert(usr, "Are you sure want to start a battle royale?", "Battle Royale", list("Im sure", "No"))
			if(input != "Im sure")
				return

			if(second_input == "Yes")
				setup(custom = TRUE)
			else
				setup((second_input == "Fast(10 min max duration)") ? TRUE : FALSE)

		if("adjust_prizes")
			var/input_prize = tgui_input_list(usr, "What prize would you like to set?", "Adjust prizes", prizes)
			if(!input_prize)
				return

			var/input_amount = tgui_input_number(usr, "What would you like to set this prize to?", "[input_prize][(input_prize == COIN_PRIZE) ? "" : "Tokens"]", round_value = TRUE)
			if(!isnum(input_amount))
				return

			prizes[input_prize] = input_amount
			log_admin("[key_name(usr)] has set the battle royale [input_prize] prize to [input_amount].")

		if("add_custom_dataset")
			var/input_time = tgui_input_number(usr, "What would you like to set the dataset's active_time to?(in deciseconds)", "Add dataset", round_value = TRUE)
			if(!input_time || GLOB.custom_battle_royale_data["[input_time]"])
				return

			var/datum/battle_royale_data/custom/new_datum = new
			new_datum.active_time = input_time
			GLOB.custom_battle_royale_data["[new_datum.active_time]"] = new_datum

		if("remove_custom_dataset")
			var/input_removal = tgui_input_list(usr, "What dataset do you want to remove?(sorted by active_time)", "Remove dataset", GLOB.custom_battle_royale_data)
			if(!input_removal)
				return

			qdel(GLOB.custom_battle_royale_data["[input_removal]"])

		if("adjust_custom_dataset")
			var/input_dataset = tgui_input_list(usr, "What dataset do you want to remove?(sorted by active_time)", "Adjust dataset", GLOB.custom_battle_royale_data)
			if(!input_dataset)
				return

			var/datum/battle_royale_data/adjusted_dataset = GLOB.custom_battle_royale_data[input_dataset]
			var/list/data_var_list = list(
				"active_time",
				"common_weight",
				"utility_weight",
				"rare_weight",
				"super_rare_weight",
				"misc_weight",
				"extra_loot_prob",
				"rare_drop_prob",
				"super_drop_prob",
				"pods_per_second",
				"final_time",
			)

			var/input_var = tgui_input_list(usr, "What var do you want to adjust?", "Adjust var", data_var_list)
			var/input_value = tgui_input_number(usr, "What would you like to set it to?", "Adjust var", round_value = TRUE)
			if(!input_var || !isnum(input_value))
				return

			if(input_var == "active_time")
				GLOB.custom_battle_royale_data -= "[adjusted_dataset.active_time]"

			adjusted_dataset.vv_edit_var(input_var, input_value)
			if(input_var == "active_time")
				GLOB.custom_battle_royale_data["[adjusted_dataset.active_time]"] = adjusted_dataset

		if("adjust_storm_delay")
			var/input_value = tgui_input_number(usr, "What would you like to set the storm delay to?", "Set delay", min_value = 0, round_value = TRUE)
			if(!isnum(input_value))
				return

			storm_controller.start_consuming_delay = input_value

#undef COIN_PRIZE
#undef MINIMUM_USEFUL_DROP_TIME
#undef PLAYER_HEALTH_VALUE
