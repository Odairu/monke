/datum/preference/choiced/satyr_horns
	savefile_key = "feature_satyr_horns"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Satyr Horns"
	should_generate_icons = TRUE

/datum/preference/choiced/satyr_horns/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.satyr_horns_list,
		"satyr_horns",
		"FRONT",
	)

/datum/preference/choiced/satyr_horns/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["satyr_horns"] = value

/datum/preference/choiced/satyr_ears
	savefile_key = "feature_satyr_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Satyr Ears"
	should_generate_icons = TRUE

/datum/preference/choiced/satyr_ears/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.satyr_ears_list,
		"satyr_ears",
		list("ADJ", "FRONT"),
	)

/datum/preference/choiced/satyr_ears/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["satyr_ears"] = value

/datum/preference/choiced/satyr_tail
	savefile_key = "feature_satyr_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Satyr Tail"
	should_generate_icons = TRUE

/datum/preference/choiced/satyr_tail/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.satyr_tail_list,
		"satyr_tail",
		list("ADJ", "FRONT"),
	)

/datum/preference/choiced/satyr_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["satyr_tail"] = value

/datum/preference/choiced/satyr_fluff
	savefile_key = "feature_satyr_fluff"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Satyr Fluff"
	should_generate_icons = TRUE

/datum/preference/choiced/satyr_fluff/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.satyr_fluff_list,
		"satyr_fluff",
		list("ADJ", "FRONT"),
	)

/datum/preference/choiced/satyr_fluff/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["satyr_fluff"] = value
