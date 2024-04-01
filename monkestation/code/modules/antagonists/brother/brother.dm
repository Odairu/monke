/datum/antagonist/brother
	var/datum/action/brother_comms/comms_action

// Apply team-specific antag HUD.
/datum/antagonist/brother/apply_innate_effects(mob/living/mob_override)
	. = ..()
	if(QDELETED(comms_action))
		comms_action = new(src)
	var/mob/living/target = mob_override || owner.current
	comms_action.Grant(target)
	add_team_hud(target, /datum/antagonist/brother, REF(team))

/datum/antagonist/brother/remove_innate_effects(mob/living/mob_override)
	. = ..()
	if(!QDELETED(comms_action))
		comms_action.Remove(mob_override || owner.current)

/datum/antagonist/brother/create_team(datum/team/brother_team/new_team)
	. = ..()
	if(new_team)
		LAZYADD(hud_keys, REF(new_team))

/datum/antagonist/brother/antag_token(datum/mind/hosts_mind, mob/spender)
	if(isobserver(spender))
		var/mob/living/carbon/human/new_mob = spender.change_mob_type(/mob/living/carbon/human, delete_old_mob = TRUE)
		new_mob.equipOutfit(/datum/outfit/job/assistant)
		hosts_mind = new_mob.mind
	var/datum/team/brother_team/team = new
	team.add_member(hosts_mind)
	team.forge_brother_objectives()
	hosts_mind.add_antag_datum(/datum/antagonist/brother, team)

/datum/antagonist/brother/render_poll_preview()
	return image(get_base_preview_icon())

/datum/antagonist/brother/proc/communicate(message)
	if(!istext(message) || !length(message) || QDELETED(owner) || QDELETED(team))
		return
	owner.current.log_talk(message, LOG_SAY, tag = "blood brother")
	var/formatted_msg = "<span class='[team.color]'><b><i>\[Blood Bond\]</i> [span_name("[owner.name]")]</b>: [message]</span>"
	for(var/datum/mind/brother as anything in team.members)
		to_chat(brother.current, formatted_msg, type = MESSAGE_TYPE_RADIO, avoid_highlighting = (brother == owner))
	for(var/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, owner)
		to_chat(dead_mob, "[link] [formatted_msg]", type = MESSAGE_TYPE_RADIO)
