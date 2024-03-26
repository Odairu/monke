/datum/job/prisoner
	title = JOB_PRISONER
	description = "Keep yourself occupied in permabrig."
	department_head = list("The Security Team")
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the security team"
	exp_granted_type = EXP_TYPE_CREW
	paycheck = PAYCHECK_LOWER
	config_tag = "PRISONER"

	outfit = /datum/outfit/job/prisoner
	plasmaman_outfit = /datum/outfit/plasmaman/prisoner

	display_order = JOB_DISPLAY_ORDER_PRISONER
	department_for_prefs = /datum/job_department/security

	exclusive_mail_goodies = TRUE
	mail_goodies = list (
		/obj/effect/spawner/random/contraband/prison = 1
	)

	family_heirlooms = list(/obj/item/pen/blue)
	rpg_title = "Defeated Miniboss"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/job/prisoner/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(add_pref_crime))

/datum/job/prisoner/proc/add_pref_crime(datum/source, mob/living/crewmember, rank)
	SIGNAL_HANDLER
	if(rank != title)
		return //not a prisoner

	var/crime_name = crewmember.client?.prefs?.read_preference(/datum/preference/choiced/prisoner_crime)
	if(!crime_name)
		return
	if(crime_name == "Random")
		crime_name = pick(assoc_to_keys(GLOB.prisoner_crimes))

	var/datum/prisoner_crime/crime = GLOB.prisoner_crimes[crime_name]
	var/datum/record/crew/target_record = find_record(crewmember.real_name)
	var/datum/crime/past_crime = new(crime.name, crime.desc, "Central Command", "Indefinite.")
	target_record.crimes += past_crime
	to_chat(crewmember, span_warning("You are imprisoned for \"[crime_name]\"."))
	crewmember.add_mob_memory(/datum/memory/key/permabrig_crimes, crimes = crime_name)

/datum/outfit/job/prisoner
	name = "Prisoner"
	jobtype = /datum/job/prisoner

	id = /obj/item/card/id/advanced/prisoner
	id_trim = /datum/id_trim/job/prisoner
	uniform = /obj/item/clothing/under/rank/prisoner
	belt = null
	ears = null
	shoes = /obj/item/clothing/shoes/sneakers/orange

/datum/outfit/job/prisoner/pre_equip(mob/living/carbon/human/H)
	..()
	if(prob(1)) // D BOYYYYSSSSS
		head = /obj/item/clothing/head/beanie/black/dboy

/datum/outfit/job/prisoner/post_equip(mob/living/carbon/human/new_prisoner, visualsOnly)
	. = ..()

	var/crime_name = new_prisoner.client?.prefs?.read_preference(/datum/preference/choiced/prisoner_crime)
	if(!crime_name)
		return
	var/datum/prisoner_crime/crime = GLOB.prisoner_crimes[crime_name]
	var/list/limbs_to_tat = new_prisoner.bodyparts.Copy()
	for(var/i in 1 to crime.tattoos)
		if(!length(SSpersistence.prison_tattoos_to_use) || visualsOnly)
			return
		var/obj/item/bodypart/tatted_limb = pick_n_take(limbs_to_tat)
		var/list/tattoo = pick_n_take(SSpersistence.prison_tattoos_to_use)
		tatted_limb.AddComponent(/datum/component/tattoo, tattoo["story"])


//monkestation prisoner stuff

/datum/job/prisoner/get_latejoin_spawn_point()
	var/turf/open/picked_turf = get_random_open_turf_in_area()
	return picked_turf

/datum/job/prisoner/after_latejoin_spawn(mob/living/spawning)
	. = ..()
	var/obj/structure/closet/supplypod/washer_pod/washer_pod = new(null)
	washer_pod.explosionSize = list(0,0,0,0)
	washer_pod.bluespace = TRUE

	var/turf/granter_turf = get_turf(spawning)
	spawning.forceMove(washer_pod)
	new /obj/effect/pod_landingzone(granter_turf, washer_pod)


/// Iterates over all turfs in the target area and returns the first non-dense one
/datum/job/prisoner/proc/get_random_open_turf_in_area()
	var/list/turfs = get_area_turfs(/area/station/security/prison)
	var/turf/open/target_turf = null
	var/sanity = 0
	while(!target_turf && sanity < 100)
		sanity++
		var/turf/turf = pick(turfs)
		if(!turf.density)
			target_turf = turf
	return target_turf
