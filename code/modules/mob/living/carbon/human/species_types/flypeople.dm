/datum/species/fly
	name = "Flyperson"
	plural_form = "Flypeople"
	id = SPECIES_FLYPERSON
	inherent_traits = list(
		TRAIT_CAN_USE_FLIGHT_POTION,
		TRAIT_TACKLING_FRAIL_ATTACKER,
		TRAIT_ANTENNAE,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	meat = /obj/item/food/meat/slab/human/mutant/fly
	mutanteyes = /obj/item/organ/internal/eyes/fly
	liked_food = GROSS | GORE
	disliked_food = NONE
	toxic_food = NONE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/fly
	wing_types = list(/obj/item/organ/external/wings/functional/fly)
	payday_modifier = 0.75

	mutanttongue = /obj/item/organ/internal/tongue/fly
	mutantheart = /obj/item/organ/internal/heart/fly
	mutantlungs = /obj/item/organ/internal/lungs/fly
	mutantliver = /obj/item/organ/internal/liver/fly
	mutantstomach = /obj/item/organ/internal/stomach/fly
	mutantappendix = /obj/item/organ/internal/appendix/fly
	mutant_organs = list(/obj/item/organ/internal/fly, /obj/item/organ/internal/fly/groin)

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/fly,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/fly,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/fly,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/fly,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/fly,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/fly,
	)

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)
		return TRUE
	..()

/datum/species/fly/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 30 //Flyswatters deal 30x damage to flypeople.
	return 1

/datum/species/fly/get_species_description()
	return "With no official documentation or knowledge of the origin of \
		this species, they remain a mystery to most. Any and all rumours among \
		Nanotrasen staff regarding flypeople are often quickly silenced by high \
		ranking staff or officials."

/datum/species/fly/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "grin-tongue",
			SPECIES_PERK_NAME = "Uncanny Digestive System",
			SPECIES_PERK_DESC = "Flypeople regurgitate their stomach contents and drink it \
				off the floor to eat and drink with little care for taste, favoring gross foods.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Insectoid Biology",
			SPECIES_PERK_DESC = "Fly swatters will deal significantly higher amounts of damage to a Flyperson.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Radial Eyesight",
			SPECIES_PERK_DESC = "Flypeople can be flashed from all angles.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "briefcase-medical",
			SPECIES_PERK_NAME = "Weird Organs",
			SPECIES_PERK_DESC = "Flypeople take specialized medical knowledge to be \
				treated. Their organs are disfigured and organ manipulation can be interesting...",
		),
	)

	return to_add
