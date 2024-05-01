/obj/item/melee/blood_magic/stun/afterattack(mob/living/target, mob/living/carbon/user, proximity)
	if(!isliving(target) || !proximity || IS_CULTIST(target))
		return
	var/datum/antagonist/cult/cult = IS_CULTIST(user)
	if(QDELETED(cult))
		return
	user.visible_message(span_warning("[user] holds up [user.p_their()] hand, which explodes in a flash of red light!"), \
						span_cultitalic("You attempt to stun [target] with the spell!"))
	user.mob_light(range = 3, color = LIGHT_COLOR_BLOOD_MAGIC, duration = 0.2 SECONDS)
	if(IS_HERETIC(target))
		to_chat(user, span_warning("Some force greater than you intervenes! [target] is protected by the Forgotten Gods!"), type = MESSAGE_TYPE_COMBAT)
		to_chat(target, span_warning("You are protected by your faith to the Forgotten Gods!"), type = MESSAGE_TYPE_COMBAT)
		var/old_color = target.color
		target.color = rgb(0, 128, 0)
		animate(target, color = old_color, time = 1 SECONDS, easing = EASE_IN)
	else if(IS_CLOCK(target))
		to_chat(user, span_warning("Some force greater than you intervenes! [target] is protected by the heretic Ratvar!"), type = MESSAGE_TYPE_COMBAT)
		to_chat(target, span_warning("You are protected by your faith to Ratvar!"), type = MESSAGE_TYPE_COMBAT)
		var/old_color = target.color
		target.color = rgb(190, 135, 0)
		animate(target, color = old_color, time = 1 SECONDS, easing = EASE_IN)
	else if(target.can_block_magic(MAGIC_RESISTANCE | MAGIC_RESISTANCE_HOLY))
		to_chat(user, span_warning("The spell had no effect!"), type = MESSAGE_TYPE_COMBAT)
	else if(target.get_drunk_amount() >= OLD_MAN_HENDERSON_DRUNKENNESS)
		to_chat(user, span_cultitalic("[target] is barely phased by your spell, rambling with drunken annoyance instead!"), type = MESSAGE_TYPE_COMBAT)
		to_chat(target, span_cultboldtalic("Eldritch horrors try to flood your thoughts, before being drowned out by an intense alcoholic haze!"), type = MESSAGE_TYPE_COMBAT) // yeah nobody's gonna be able to understand you through the slurring but it's funny anyways
		target.say("MUCKLE DAMRED CULT! 'AIR EH NAMBLIES BE KEEPIN' ME WEE MEN!?!!", forced = "drunk cult stun")
		target.adjust_silence(15 SECONDS)
		target.adjust_confusion(15 SECONDS)
		target.set_jitter_if_lower(15 SECONDS)
	// we reuse TRAIT_BLOODSUCKER_HUNTER here because it's pretty much given to anyone with knowledge of and the ability to combat the occult.
	else if(HAS_TRAIT(target, TRAIT_MINDSHIELD) || HAS_MIND_TRAIT(target, TRAIT_BLOODSUCKER_HUNTER) || cult.cult_team.cult_ascendent || cult.cult_team.is_sacrifice_target(target.mind))
		to_chat(user, span_cultitalic("In a brilliant flash of red, [target] falls to the ground, [target.p_their()] strength drained, albeit managing to somewhat resist the effects!"), type = MESSAGE_TYPE_COMBAT)
		to_chat(target, span_userdanger("You barely manage to resist [user]'s spell, falling to the ground in agony, but still able to gather enough strength to act!"), type = MESSAGE_TYPE_COMBAT)
		target.emote("scream")
		target.AdjustKnockdown(5 SECONDS)
		target.stamina.adjust(-80)
		target.adjust_timed_status_effect(12 SECONDS, /datum/status_effect/speech/slurring/cult)
		target.adjust_silence(8 SECONDS)
		target.adjust_stutter(20 SECONDS)
		target.set_jitter_if_lower(20 SECONDS)
	else
		to_chat(user, span_cultitalic("In a brilliant flash of red, [target] crumples to the ground!"), type = MESSAGE_TYPE_COMBAT)
		target.Paralyze(16 SECONDS)
		target.flash_act(1, TRUE)
		if(issilicon(target))
			var/mob/living/silicon/silicon_target = target
			silicon_target.emp_act(EMP_HEAVY)
		else if(iscarbon(target))
			var/mob/living/carbon/carbon_target = target
			carbon_target.adjust_silence(12 SECONDS)
			carbon_target.adjust_stutter(30 SECONDS)
			carbon_target.adjust_timed_status_effect(30 SECONDS, /datum/status_effect/speech/slurring/cult)
			carbon_target.set_jitter_if_lower(30 SECONDS)
	uses--
	return ..()
