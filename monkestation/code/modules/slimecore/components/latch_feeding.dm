/datum/component/latch_feeding
	var/damage_type
	var/damage_amount

	///this is the target we are sucking
	var/atom/movable/target
	///this is the amount of hunger we are sending per feed process
	var/hunger_restore
	///do we stop at crit?
	var/stops_at_crit
	///did we just unlatch?
	var/unlatching = FALSE


/datum/component/latch_feeding/Initialize(atom/movable/target, damage_type, damage_amount, hunger_restore, stops_at_crit)
	. = ..()
	src.target = target
	if(!target)
		return COMPONENT_INCOMPATIBLE

	src.damage_type = damage_type
	src.damage_amount = damage_amount
	src.hunger_restore = hunger_restore
	src.stops_at_crit = stops_at_crit

	if(!latch_target())
		return COMPONENT_INCOMPATIBLE

	ADD_TRAIT(parent, TRAIT_FEEDING, LATCH_TRAIT)

	START_PROCESSING(SSobj, src)

/datum/component/latch_feeding/Destroy(force, silent)
	REMOVE_TRAIT(parent, TRAIT_FEEDING, LATCH_TRAIT)
	. = ..()
	target = null

/datum/component/latch_feeding/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_SET_BUCKLED, PROC_REF(check_buckled))
	RegisterSignal(parent, COMSIG_MOB_OVERATE, PROC_REF(stop_feeding))

/datum/component/latch_feeding/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_SET_BUCKLED)
	UnregisterSignal(parent, COMSIG_MOB_OVERATE)

/datum/component/latch_feeding/proc/latch_target(init = FALSE)
	var/mob/basic_mob = parent
	target.unbuckle_all_mobs(force = TRUE)
	if(target.buckle_mob(basic_mob, force=TRUE))
		basic_mob.layer = target.layer + 0.1
		target.visible_message(span_danger("[basic_mob] latches onto [target]!"), \
						span_userdanger("[basic_mob] latches onto [target]!"))
		return TRUE
	else
		to_chat(basic_mob, span_notice("You failed to latch onto [target]."))
		if(init)
			return FALSE
		else
			qdel(src)

/datum/component/latch_feeding/proc/unlatch_target(living = TRUE, silent = FALSE)
	var/mob/basic_mob = parent
	if(basic_mob.buckled)
		if(!living)
			to_chat(basic_mob, "<span class='warning'>[pick("This subject is incompatible", \
			"This subject does not have life energy", "This subject is empty", \
			"I am not satisified", "I can not feed from this subject", \
			"I do not feel nourished", "This subject is not food")]!</span>")
		if(!silent)
			basic_mob.visible_message(span_warning("[basic_mob] lets go of [basic_mob.buckled]!"), \
							span_notice("<i>I stopped feeding.</i>"))

	basic_mob.layer = initial(basic_mob.layer)
	basic_mob.buckled.unbuckle_mob(basic_mob, force=TRUE)


/datum/component/latch_feeding/proc/check_buckled(mob/living/source, atom/movable/new_buckled)
	if(!new_buckled && !unlatching)
		unlatching = TRUE
		unlatch_target()
		qdel(src)
		return

/datum/component/latch_feeding/proc/stop_feeding()
	unlatch_target()
	qdel(src)

/datum/component/latch_feeding/process(seconds_per_tick)
	if(!target)
		qdel(src)
		return

	var/mob/living/living_target = target
	if((living_target.stat >= SOFT_CRIT) && stops_at_crit)
		stop_feeding()
		return

	living_target.apply_damage(damage_amount, damage_type, spread_damage = TRUE)
	SEND_SIGNAL(parent, COMSIG_MOB_FEED, target, hunger_restore)