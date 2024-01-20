/datum/action/cooldown/borer/stealth_mode
	name = "Stealth Mode"
	cooldown_time = 2 MINUTES
	button_icon_state = "hiding"
	chemical_cost = 100
	sugar_restricted = TRUE

/datum/action/cooldown/borer/stealth_mode/Trigger(trigger_flags, atom/target)
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	var/in_stealth = (cortical_owner.upgrade_flags & BORER_STEALTH_MODE)
	if(in_stealth)
		chemical_cost = 0
	else
		chemical_cost = initial(chemical_cost)
	. = ..()
	if(!.)
		return FALSE
	owner.balloon_alert(owner, "stealth mode [in_stealth ? "disabled" : "enabled"]")
	cortical_owner.chemical_storage -= chemical_cost
	if(in_stealth)
		cortical_owner.upgrade_flags &= ~BORER_STEALTH_MODE
	else
		cortical_owner.upgrade_flags |= BORER_STEALTH_MODE


	StartCooldown()
