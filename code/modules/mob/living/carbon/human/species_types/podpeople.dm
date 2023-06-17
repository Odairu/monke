/datum/species/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "\improper Podperson"
	plural_form = "Podpeople"
	id = SPECIES_PODPERSON
	species_traits = list(
		MUTCOLORS,
		EYECOLOR,
	)
	inherent_traits = list(
		TRAIT_PLANT_SAFE,
	)
	external_organs = list(
		/obj/item/organ/external/pod_hair = "None",
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_PLANT
	inherent_factions = list(FACTION_PLANTS, FACTION_VINES)

	heatmod = 1.5
	payday_modifier = 0.75
	meat = /obj/item/food/meat/slab/human/mutant/plant
	exotic_blood = /datum/reagent/water
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/plant
	mutanttongue = /obj/item/organ/internal/tongue/pod
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/pod,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/pod,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/pod,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/pod,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/pod,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/pod,
	)

	ass_image = 'icons/ass/asspodperson.png'

/datum/species/pod/on_species_gain(mob/living/carbon/new_podperson, datum/species/old_species, pref_load)
	. = ..()
	if(ishuman(new_podperson))
		update_mail_goodies(new_podperson)

/datum/species/pod/update_quirk_mail_goodies(mob/living/carbon/human/recipient, datum/quirk/quirk, list/mail_goodies = list())
	if(istype(quirk, /datum/quirk/blooddeficiency))
		mail_goodies += list(
			/obj/item/reagent_containers/blood/podperson
		)
	return ..()

/datum/species/pod/spec_life(mob/living/carbon/human/podperson, seconds_per_tick, times_fired)
	. = ..()
	if(podperson.stat == DEAD)
		return

	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(podperson.loc)) //else, there's considered to be no light
		var/turf/turf_loc = podperson.loc
		light_amount = min(1, turf_loc.get_lumcount()) - 0.5
		podperson.adjust_nutrition(5 * light_amount * seconds_per_tick)
		if(light_amount > 0.2) //if there's enough light, heal
			var/need_mob_update = FALSE
			need_mob_update += podperson.heal_overall_damage(brute = 0.5 * seconds_per_tick, burn = 0.5 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			need_mob_update += podperson.adjustToxLoss(-0.5 * seconds_per_tick, updating_health = FALSE)
			need_mob_update += podperson.adjustOxyLoss(-0.5 * seconds_per_tick, updating_health = FALSE)
			if(need_mob_update)
				podperson.updatehealth()

	if(podperson.nutrition > NUTRITION_LEVEL_ALMOST_FULL) //don't make podpeople fat because they stood in the sun for too long
		podperson.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)

	if(podperson.nutrition < NUTRITION_LEVEL_STARVING + 50)
		podperson.take_overall_damage(brute = 1 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)

/datum/species/pod/handle_chemical(datum/reagent/chem, mob/living/carbon/human/affected, seconds_per_tick, times_fired)
	. = ..()
	if(. & COMSIG_MOB_STOP_REAGENT_CHECK)
		return
	if(chem.type == /datum/reagent/toxin/plantbgone)
		affected.adjustToxLoss(3 * REM * seconds_per_tick)

/datum/species/pod/randomize_features(mob/living/carbon/human_mob)
	randomize_external_organs(human_mob)
