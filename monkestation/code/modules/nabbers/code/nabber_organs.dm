#define NABBER_COLD_THRESHOLD_1 180
#define NABBER_COLD_THRESHOLD_2 140
#define NABBER_COLD_THRESHOLD_3 100

#define NABBER_HEAT_THRESHOLD_1 300
#define NABBER_HEAT_THRESHOLD_2 440
#define NABBER_HEAT_THRESHOLD_3 600

#define ORGAN_ICON_NABBER 'monkestation/code/modules/nabbers/icons/organs/nabber_organs.dmi'

/obj/item/organ/internal/tongue/nabber
	name = "nabber tongue"

		//DO NOT ENABLE UNTIL THE SPECIES -> TONGUE TASTE REFACTOR IS IN.
	//liked_foodtypes = RAW | GORE | GRAIN
	//disliked_foodtypes = CLOTH | FRIED | TOXIC
	//toxic_foodtypes = DAIRY

/obj/item/organ/internal/ears/nabber
	name = "nabber ears"
	icon = ORGAN_ICON_NABBER
	icon_state = "ears"

/obj/item/organ/internal/heart/nabber
	name = "haemolyph pump"
	icon = ORGAN_ICON_NABBER
	icon_state = "heart"

/obj/item/organ/internal/brain/nabber
	name = "nabber brain"
	icon = ORGAN_ICON_NABBER
	icon_state = "brain"

/obj/item/organ/internal/eyes/nabber
	name = "nictating eyes"
	desc = "Small orange orbs."
	icon = ORGAN_ICON_NABBER
	icon_state = "eyes"
	flash_protect = FLASH_PROTECTION_SENSITIVE

/obj/item/organ/internal/eyes/robotic/nabber
	name = "nictating eyes"
	desc = "Small orange orbs. With pair welding shield linses."
	icon = ORGAN_ICON_NABBER
	icon_state = "eyes"
	flash_protect = FLASH_PROTECTION_SENSITIVE
	var/datum/action/cooldown/toggle_welding/shield
	var/active = FALSE

/obj/item/organ/internal/eyes/robotic/nabber/on_insert(mob/living/carbon/eye_recipient)
	. = ..()
	shield = new(eye_recipient)
	shield.button_icon = ORGAN_ICON_NABBER
	shield.button_icon_state = "eyes"
	shield.Grant(eye_recipient)
	shield.eyes = src

/obj/item/organ/internal/eyes/robotic/nabber/proc/toggle_shielding()
	if(!owner)
		return

	active = !active
	playsound(owner, 'sound/machines/click.ogg', 50, TRUE)

	if(active)
		flash_protect = FLASH_PROTECTION_WELDER
		tint = 2
		owner.update_tint()
		owner.balloon_alert(owner, "Welder eyelids shut!")
		return

	flash_protect = FLASH_PROTECTION_SENSITIVE
	tint = 0
	owner.update_tint()
	owner.balloon_alert(owner, "Welder eyelids open!")

/obj/item/organ/internal/eyes/robotic/nabber/Remove(mob/living/carbon/eye_owner, special)
	. = ..()
	qdel(shield)
	active = FALSE
	toggle_shielding()

/obj/item/organ/internal/lungs/nabber
	name = "spiracle lungs" //Insects breathe differently
	icon = ORGAN_ICON_NABBER
	icon_state = "lungs"

	cold_message = "You can't stand the freezing cold with every breath you take!"
	cold_level_1_threshold = NABBER_COLD_THRESHOLD_1
	cold_level_2_threshold = NABBER_COLD_THRESHOLD_2
	cold_level_3_threshold = NABBER_COLD_THRESHOLD_3
	cold_level_1_damage = COLD_GAS_DAMAGE_LEVEL_1 //Keep in mind with gas damage levels, you can set these to be negative, if you want someone to heal, instead.
	cold_level_2_damage = COLD_GAS_DAMAGE_LEVEL_1
	cold_level_3_damage = COLD_GAS_DAMAGE_LEVEL_2
	cold_damage_type = BRUTE


	hot_message = "You can't stand the searing heat with every breath you take!"
	heat_level_1_threshold = NABBER_HEAT_THRESHOLD_1
	heat_level_2_threshold = NABBER_HEAT_THRESHOLD_2
	heat_level_3_threshold = NABBER_HEAT_THRESHOLD_3
	heat_level_1_damage = HEAT_GAS_DAMAGE_LEVEL_2
	heat_level_2_damage = HEAT_GAS_DAMAGE_LEVEL_3
	heat_level_3_damage = HEAT_GAS_DAMAGE_LEVEL_3
	heat_damage_type = BURN

/obj/item/organ/internal/liver/nabber
	name = "catalytic processor" //Nabbers convert oxygen -> plasma lorewise in their blood
	icon_state = "liver"
	icon = ORGAN_ICON_NABBER
	liver_resistance = 0.8 //Weaker livers

#undef ORGAN_ICON_NABBER
