/datum/round_event_control/antagonist/solo/brother
	antag_flag = ROLE_BROTHER
	antag_datum = /datum/antagonist/brother
	typepath = /datum/round_event/antagonist/solo/brother
	tags = list(TAG_COMBAT, TAG_TEAM_ANTAG)
	weight = /datum/round_event_control/antagonist/solo/traitor::weight * 0.8 // slightly less than traitors
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)

/datum/round_event_control/antagonist/solo/brother/roundstart
	name = "Blood Brothers"
	roundstart = TRUE
	earliest_start = 0 SECONDS

/datum/round_event_control/antagonist/solo/brother/midround
	name = "Sleeper Agents (Blood Brothers)"
	prompted_picking = TRUE

/datum/round_event/antagonist/solo/brother/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/team/brother_team/team = new
	team.add_member(antag_mind)
	team.forge_brother_objectives()
	antag_mind.add_antag_datum(/datum/antagonist/brother, team)
