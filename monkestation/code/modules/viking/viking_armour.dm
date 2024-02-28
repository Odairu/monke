//vikings can't go naked now should they
// I mean they coould but funny armour

/obj/item/clothing/head/viking
	icon = 'monkestation/icons/viking/viking_items.dmi'
	worn_icon = 'monkestation/icons/viking/viking_armor.dmi'
	desc = "oi admins wrong one"

/obj/item/clothing/under/viking
	icon = 'monkestation/icons/viking/viking_items.dmi'
	worn_icon = 'monkestation/icons/viking/viking_armor.dmi'
	desc = "oi admins wrong one"

//warning this item will include the godslayer armor heal (as soon as i get the code in)
/obj/item/clothing/head/viking/godly_helmet
	name = " Horned Helm"
	desc = "A helmet blessed by the gods its wearer will not go down without a fight."
	worn_icon_state = "horned_helm_worn"
	icon_state = "horned_helm_item"
	armor_type = /datum/armor/godly_viking
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE

/obj/item/clothing/under/viking/godly_tunic
	name = " Cloak of Fenrir"
	desc = "A cloak made from hide torn from Fenrir."
	worn_icon_state = "pelts"
	icon_state = "pelts_item"
	armor_type = /datum/armor/godly_viking
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_NORMAL
	clothing_flags = STOPSPRESSUREDAMAGE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/datum/armor/godly_viking
	melee = 80
	bullet = 75
	laser = 75
	energy = 70
	bomb = 75
	bio = 100
	fire = 100
	acid = 100
	wound = 75

/obj/item/clothing/head/viking/helmet
	name = "viking helmet"
	desc = "The helmet of someone insane enough to bring an axe to a gun fight."
	worn_icon_state = "honeless_helm_worn"
	icon_state = "hornless_helm_item"
	armor_type = /datum/armor/viking
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE

/obj/item/clothing/under/viking/tunic
	name = "viking tunic"
	desc = "A tunic made from wolf pelts."
	worn_icon_state = "pelts"
	icon_state = "pelts_item"
	armor_type = /datum/armor/viking
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/datum/armor/viking
	melee = 45
	bullet = 30
	laser = 30
	energy = 25
	bomb = 20
	bio = 75
	fire = 75
	acid = 100
	wound = 35