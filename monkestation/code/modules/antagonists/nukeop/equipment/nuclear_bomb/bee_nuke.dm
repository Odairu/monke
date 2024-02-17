/// A fake nuke that actually contains bee.
/obj/machinery/nuclearbomb/bee
	name = "\improper Rayne Corp brand nuclear fission explosive"
	desc = "One of the more successful achievements of the Rayne Corporation Biological Warfare Division, their nuclear fission explosives are renowned for being affordable to produce and devastatingly effective. Signs explain that though this particular device has been (hopefully) decommissioned, you should probably be careful around it considering it's a bomb. - at least, the sign says that's what it is. There seems to be a picture of a bee on the back."
	proper_bomb = FALSE
	/// The keg located within the beer nuke.
	var/obj/structure/reagent_dispensers/beerkeg/keg
	/// Reagent that is produced once the nuke detonates.
	/// Round event control we might as well keep track of instead of locating every time

/obj/machinery/nuclearbomb/bee/Initialize(mapload)
	. = ..()
	keg = new(src)
	QDEL_NULL(core)
	clog_control = locate(/datum/round_event_control/scrubber_clog/flood) in SSevents.control

/obj/machinery/nuclearbomb/bee/Destroy()
	clog_control = null
	QDEL_NULL(keg)
	UnregisterSignal(clog_control, COMSIG_CREATED_ROUND_EVENT)
	return ..()

/obj/machinery/nuclearbomb/bee/examine(mob/user)
	. = ..()
	if(keg.reagents.total_volume)
		. += span_notice("It has [keg.reagents.total_volume] unit\s left.")
	else
		. += span_danger("It's empty.")

/obj/machinery/nuclearbomb/bee/attackby(obj/item/weapon, mob/user, params)
	if(weapon.is_refillable())
		weapon.afterattack(keg, user, TRUE) // redirect refillable containers to the keg, allowing them to be filled
		return TRUE // pretend we handled the attack, too.

	if(istype(weapon, /obj/item/nuke_core_container))
		to_chat(user, span_notice("[src] has had its plutonium core removed as a part of being decommissioned."))
		return TRUE

	return ..()

/obj/machinery/nuclearbomb/bee/actually_explode()
	//Unblock roundend, we're not actually exploding.
	SSticker.roundend_check_paused = FALSE
	var/turf/bomb_location = get_turf(src)
	if(!bomb_location)
		disarm_nuke()
		return
	if(is_station_level(bomb_location.z))
		addtimer(CALLBACK(src, PROC_REF(really_actually_explode)), 11 SECONDS)
	else
		visible_message(span_notice("[src] fizzes ominously."))


/obj/machinery/nuclearbomb/bee/disarm_nuke(mob/disarmer)
	exploding = FALSE
	exploded = TRUE
	return ..()

/obj/machinery/nuclearbomb/bee/really_actually_explode(detonation_status)
	//if it's always hooked in it'll override admin choices
	disarm_nuke()
	clog_control.run_event(event_cause = "a bee nuke")

/// signal sent from overflow control when it fires an event

