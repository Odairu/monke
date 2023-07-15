#define EGGSPLODE_DELAY 100 SECONDS
/************************************
Dermagraphic Ovulogenesis

	Extremely Noticeable
	Increases resistance slightly.
	Not Fast, Not Slow
	Transmittable.
	High Level

BONUS
	Provides Brute Healing when Egg Sacs/Eggs are eaten, simultaneously infecting anyone who eats them

***********************************/

/datum/symptom/skineggs //Thought Exolocomotive Xenomitosis was a weird symptom? Well, this is about 10x weirder.
	name = "Dermagraphic Ovulogenesis"
	desc = "The virus causes the host to grow egg-like nodules on their skin, which periodically fall off and contain the disease and some healing chemicals."
	stealth = -3 //You are basically growing these weird Egg shits on your skin, this is not stealthy in the slightest
	resistance = 1
	stage_speed = 0
	transmittable = 2 //The symptom is in it of itself meant to spread
	level = 8
	severity = -1
	base_message_chance = 50
	symptom_delay_min = 80
	symptom_delay_max = 145
	threshold_descs = list(
		"Transmission 6" = "Eggs and Egg Sacs contain all diseases on the host, instead of just the disease containing the symptom.",
		"Transmission 10" = "Egg Sacs will 'explode' into eggs after a period of time, covering a larger area with infectious matter.",
		"Resistance 8" = "Eggs and Egg Sacs contain more healing chems.",
		"Stealth 5" = "Eggs and Egg Sacs become nearly transparent, making them more difficult to see.",
		"Stage Speed 8" = "Egg Sacs fall off the host more frequently."
	)
	///this determines if healing reagents are included or not.
	var/big_heal = FALSE
	///responsible for adding in other diseases on spread if checks are positive
	var/all_disease = FALSE
	///if true, egg sac seperate after some time and goes flying in all directions
	var/eggsplosion = FALSE
	///changes icon state to a more hard to see variant if true
	var/sneaky = FALSE


/datum/symptom/skineggs/Start(datum/disease/advance/advanced_disease)
	if(!..())
		return
	if(advanced_disease.totalResistance() >= 8)
		big_heal = TRUE
	if(advanced_disease.totalTransmittable() >= 6)
		all_disease = TRUE
		if(advanced_disease.totalTransmittable() >= 10)
			eggsplosion = TRUE //Haha get it?
	if(advanced_disease.totalStealth() >= 5)
		sneaky = TRUE
	if(advanced_disease.totalStageSpeed() >= 8)
		symptom_delay_min -= 10
		symptom_delay_max -= 20


/datum/symptom/skineggs/Activate(datum/disease/advance/advanced_disease)
	if(!..())
		return
	var/mob/living/carbon/victim = advanced_disease.affected_mob
	var/list/diseases = list(advanced_disease)
	if(advanced_disease.stage == 5)
		if(all_disease)
			for(var/datum/disease/variable55 in victim.diseases)
				if((variable55.spread_flags & DISEASE_SPREAD_SPECIAL) || (variable55.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS) || (variable55.spread_flags & DISEASE_SPREAD_FALTERED))
					continue
				if(variable55 == advanced_disease)
					continue
				diseases += variable55
			new /obj/item/food/eggsac(victim.loc, diseases, eggsplosion, sneaky, big_heal)

/obj/item/food/eggsac
	name = "Fleshy egg sac"
	desc = "A small Egg Sac which appears to be made out of someone's flesh!"
	icon = 'monkestation/icons/obj/food/food.dmi'
	icon_state = "eggsac"
	bite_consumption = 4
	var/list/diseases = list()
	var/sneaky_egg = FALSE
	var/big_heal = FALSE

//Constructor
/obj/item/food/eggsac/Initialize(loc, disease, eggsplodes, sneaky, large_heal)
///obj/item/food/eggsac/New(loc, disease, eggsplodes, sneaky, large_heal)
	..()
	for(var/datum/disease/variable55 in disease)
		diseases += variable55
	if(large_heal)
		reagents.add_reagent_list(list(/datum/reagent/medicine/c2/probital = 20, /datum/reagent/medicine/granibitaluri = 10))
		reagents.add_reagent(/datum/reagent/blood, 10, diseases)
		big_heal = TRUE
	else
		reagents.add_reagent_list(list(/datum/reagent/medicine/c2/probital = 10, /datum/reagent/medicine/granibitaluri = 10))
		reagents.add_reagent(/datum/reagent/blood, 15, diseases)
	if(sneaky)
		icon_state = "eggsac-sneaky"
		sneaky_egg = sneaky
	if(eggsplodes)
		addtimer(CALLBACK(src, PROC_REF(eggsplode)), EGGSPLODE_DELAY)
	if(LAZYLEN(diseases))
		AddComponent(/datum/component/infective, diseases)


///time to make eggs everywere yey
/obj/item/food/eggsac/proc/eggsplode()
	for(var/random_direction in 1 to rand(4, 8))
	//for(var/random_direction = 1, random_direction <= rand(4,8), random_direction++)
		var/list/directions = GLOB.alldirs
		var/obj/item/eggs = new /obj/item/food/eggsac/fleshegg(src.loc, diseases, sneaky_egg, big_heal)
		var/turf/thrown_at = get_ranged_target_turf(eggs, pick(directions), rand(2, 4))
		eggs.throw_at(thrown_at, rand(2,4), 4)

/obj/item/food/eggsac/fleshegg
	name = "Fleshy eggs"
	desc = "An Egg which appears to be made out of someone's flesh!"
	icon_state = "fleshegg"
	bite_consumption = 1

/obj/item/food/eggsac/fleshegg/Initialize(loc, disease, sneaky, large_heal)
	..()
	for(var/datum/disease/variable55 in disease)
		diseases += variable55
	if(large_heal)
		reagents.add_reagent_list(list(/datum/reagent/medicine/c2/probital = 20, /datum/reagent/medicine/granibitaluri = 10))
		reagents.add_reagent(/datum/reagent/blood, 10, diseases)
	else
		reagents.add_reagent_list(list(/datum/reagent/medicine/c2/probital = 10, /datum/reagent/medicine/granibitaluri = 10))
		reagents.add_reagent(/datum/reagent/blood, 15, diseases)
	if(sneaky)
		icon_state = "fleshegg-sneaky"
	if(LAZYLEN(diseases))
		AddComponent(/datum/component/infective, diseases)
#undef EGGSPLODE_DELAY
