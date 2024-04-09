/datum/antagonist/abductor
	/// A list of surgeries that abductors can't do, to prevent bullshittery.
	var/static/list/forbidden_surgeries = typecacheof(list(/datum/surgery/advanced/brainwashing, /datum/surgery/advanced/necrotic_revival))

/datum/antagonist/abductor/on_gain()
	. = ..()
	RegisterSignal(owner.current, COMSIG_SURGERY_STARTING, PROC_REF(prevent_forbidden_surgeries))

/datum/antagonist/abductor/on_removal()
	. = ..()
	UnregisterSignal(owner.current, COMSIG_SURGERY_STARTING)

/datum/antagonist/abductor/proc/prevent_forbidden_surgeries(mob/user, datum/surgery/surgery, mob/patient)
	if(is_type_in_typecache(surgery, forbidden_surgeries))
		return COMPONENT_CANCEL_SURGERY
	return NONE
