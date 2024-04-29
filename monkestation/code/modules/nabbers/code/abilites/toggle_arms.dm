/obj/item/melee/nabber_blade
	name = "Hunting arm"
	desc = "A grotesque, sharpened blade-limb. You feel as if you had to get this from a living creature to hold it. You monster."
	icon = 'monkestation/code/modules/nabbers/icons/items.dmi'
	icon_state = "mantis_arm_r"
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 14 //Temporary nerf. Original value; 17. Should no longer be able to damage reinforced windows.
	armour_penetration = 7 //Hydraulic muscle-driven arms.
	throwforce = 0 //Buggy.
	throw_range = 0
	throw_speed = 0
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED
	wound_bonus = 10 //dropped from 25
	bare_wound_bonus = 10 //Dropped from 25. Now lowered due to the ability to sharpen them.

/obj/item/melee/nabber_blade/alt
	icon_state = "mantis_arm_l"

/obj/item/melee/nabber_blade/Initialize(mapload,silent,synthetic)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT) //They're designed for this
	AddComponent(/datum/component/butchering, \
	speed = 3 SECONDS, \
	effectiveness = 85, \
	)

/obj/item/melee/nabber_blade/Destroy()
	return ..()

/datum/action/cooldown/toggle_arms/proc/sharpen_limbs(mob/user)
	for(var/obj/item/held in user.held_items) //Actually sharpen them here
		if(istype(held, /obj/item/melee/nabber_blade))
			held.force = 18 //+4 damage to simulate whetstone usage.
			held.wound_bonus = 15 // Decent buff.
			held.bare_wound_bonus = 35 //Significant buff.
			held.name = "lethally sharpened hunting-arm"
			var/datum/component/butchering/held_component = held.GetComponent(/datum/component/butchering)
			held_component.effectiveness = 95
			held_component.speed = 1.5 SECONDS

/obj/item/melee/nabber_blade/pre_attack(atom/W, mob/living/user, params) //Handles whetstoning your limbs. TODO: Maybe add nabber-specific traitor item for this?
	if (istype(W, /obj/item/sharpener))
		var/obj/item/sharpener/poorstone = W
		if(poorstone.uses >= 1)
			user.visible_message(span_notice("[user] begins to sharpen their massive blade-arms."),
									span_notice("You begin to sharpen your natural weaponry."))
			if(do_after(user, 7 SECONDS, target = src))
				user.visible_message(span_notice("[user] sharpens the large, sharp underside of their bladearms..."),
										span_notice("You sharpen the large underside of your bladearm, ready to kill..."))
				playsound(src, 'sound/items/unsheath.ogg', 100, TRUE)
				poorstone.uses-- //Make sure you cant sharpen both for a single whetstone!
				poorstone.name = "thoroughly ruined whetstone"
				poorstone.desc = "A whetstone, ruined seemingly by sharpening both sides of a massive, bladed limb - ground utterly smooth." //Give a forensic hint as to what ruined it.
				for(var/datum/action/cooldown/toggle_arms/arms in user.actions) //Should only ever be one instance. Make sure to handle it, though
					arms.has_sharpened = TRUE
					arms.sharpen_limbs(user)
			return
		else
			user.visible_message(span_notice("[user] attempts to sharpen their arms, only to find the whetstone too smooth to do so!"),
									span_notice("You fail to even grind the burr away from your chitinous limbs. Use a better stone."))
	return ..()

/obj/item/melee/nabber_blade/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	else if(istype(target, /obj/structure/chair))
		var/obj/structure/chair/C = target
		C.deconstruct()
	else if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/C = target
		C.attack_alien(user)

/datum/action/cooldown/toggle_arms
	name = "Toggle mantis arms"
	desc = "Pump your Haemolyph from the rest of your body into your hunting arms, allowing you to stab at foes. This will take time to do, and can be interrupted."
	cooldown_time = 5 SECONDS

	button_icon = 'monkestation/code/modules/nabbers/icons/actions.dmi'
	var/has_sharpened = FALSE //Simplest way to avoid bugs.

/datum/action/cooldown/toggle_arms/Destroy()
	has_sharpened = null
	return ..()

/datum/action/cooldown/toggle_arms/New(Target, original)
	. = ..()
	button_icon_state = "arms_off"

/datum/action/cooldown/toggle_arms/Activate(atom/target)
	var/mob/living/carbon/human/nabber = owner

	if(!nabber)
		return FALSE

	if(isdead(nabber) || nabber.incapacitated())
		nabber.balloon_alert(nabber, "Incapacitated!")
		return FALSE

	if(nabber.num_hands < 2)
		nabber.balloon_alert(nabber, "Need both hands!")
		return	FALSE

	var/obj/item/held = nabber.get_active_held_item()
	var/obj/item/inactive = nabber.get_inactive_held_item()

	if(((held || inactive) && !nabber.drop_all_held_items()) && !(istype((inactive || held), /obj/item/melee/nabber_blade)))
		nabber.balloon_alert(nabber, "Hands occupied!")
		return	FALSE

	else if(istype((inactive || held), /obj/item/melee/nabber_blade))
		StartCooldown()
		down_arms()
		return TRUE

	rise_arms()
	StartCooldown()
	return TRUE

/datum/action/cooldown/toggle_arms/proc/rise_arms()
	var/mob/living/carbon/human/nabber = owner

	nabber.balloon_alert(nabber, "Begin pumping blood in!")
	nabber.visible_message(span_danger("[nabber] starts to pump blood into their hunting arms!"), span_warning("You let out a aggressive screech, raising your blade-arms!"), span_hear("You hear a sharp screech of an agitated creature!"))
	playsound(nabber, 'monkestation/code/modules/nabbers/sounds/nabberscream.ogg', 70)

	if(!do_after(nabber, 3 SECONDS, nabber))
		StartCooldown()
		nabber.balloon_alert(nabber, "Stand still!")
		return FALSE

	nabber.balloon_alert(nabber, "Arms raised!")
	nabber.visible_message(span_warning("[nabber] raised their mantid-like hunting arms in a frenzy, ready for a fight!"), span_warning("You raise your mantis arms, ready for combat."), span_hear("You hear a terrible hunting screech!"))
	playsound(nabber, 'monkestation/code/modules/nabbers/sounds/nabberscream.ogg', 70)

	var/c = nabber.dna.features["mcolor"]
	var/obj/item/melee/nabber_blade/active_hand = new
	var/obj/item/melee/nabber_blade/alt/inactive_hand = new

	active_hand.color = c
	inactive_hand.color = c

	nabber.put_in_active_hand(active_hand)
	nabber.put_in_inactive_hand(inactive_hand)
	if(has_sharpened) //Rather than just having these be items that can cause huge problems, ensure we delete them and just recreate with the force neccessary.
		RegisterSignal(nabber, COMSIG_ATOM_EXAMINE, PROC_REF(examined))
		sharpen_limbs(nabber)
	RegisterSignal(owner, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(on_lose_hand))
	button_icon_state = "arms_on"
	nabber.update_action_buttons()

/datum/action/cooldown/toggle_arms/proc/down_arms(force = FALSE)
	var/mob/living/carbon/human/nabber = owner

	nabber.visible_message(span_notice("[nabber] starts to relax, pumping blood away from their hunting-arms!"), span_notice("You start pumping blood out your mantis arms. Stay still!"), span_hear("You hear [src] let out a quiet hissing sigh."))

	if(force)
		nabber.Stun(5 SECONDS)
		for(var/obj/item/held in nabber.held_items)
			if(istype(held, /obj/item/melee/nabber_blade))
				qdel(held)
		button_icon_state = "arms_on"
		nabber.update_action_buttons()
		return	FALSE

	nabber.balloon_alert(nabber, "Removing blood from hunting-arms!")

	if(!do_after(nabber, 2.5 SECONDS, nabber))
		nabber.balloon_alert(nabber, "Stand still!")
		return	FALSE

	playsound(nabber, 'monkestation/code/modules/nabbers/sounds/nabberscream.ogg', 70)
	if(has_sharpened)
		UnregisterSignal(nabber, COMSIG_ATOM_EXAMINE, PROC_REF(examined))
	for(var/obj/item/held in nabber.held_items)
		if(istype(held, /obj/item/melee/nabber_blade))
			qdel(held)

	UnregisterSignal(owner, COMSIG_CARBON_REMOVE_LIMB)
	nabber.balloon_alert(nabber, "Arms down!")
	button_icon_state = "arms_off"
	nabber.update_action_buttons()

/datum/action/cooldown/toggle_arms/proc/on_lose_hand()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/nabber = owner

	if(!(nabber.num_hands < 2))
		return	FALSE

	nabber.visible_message(span_notice("[nabber] has their arm violently removed, spurting high-pressure haemolyph, the other going limp!"), span_notice("HOLY SHIT MY ARM!"), span_hear("You hear [nabber] let out a sharp hiss as they lose a limb!"))
	playsound(nabber, 'monkestation/code/modules/nabbers/sounds/nabberscream.ogg', 70)
	nabber.balloon_alert(nabber, "Lost hands!")
	nabber.Stun(5 SECONDS)
	if(has_sharpened)
		UnregisterSignal(nabber, COMSIG_ATOM_EXAMINE, PROC_REF(examined))
	for(var/obj/item/held in nabber.held_items)
		if(istype(held, /obj/item/melee/nabber_blade))
			qdel(held)

	button_icon_state = "arms_off"
	nabber.update_action_buttons()

/datum/action/cooldown/toggle_arms/proc/examined(mob/living/carbon/examined, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/examine_text = span_danger("[examined] has sharpened their hunting-arms, with the large blades radiating a bloodthirsty aura...")
	examine_list += examine_text