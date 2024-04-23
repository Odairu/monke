/obj/item/assembly/flash/examine(mob/user)
	. = ..()
	var/datum/antagonist/brother/blood_bond = user?.mind?.has_antag_datum(/datum/antagonist/brother)
	if(!QDELETED(blood_bond))
		var/datum/component/can_flash_from_behind/flash_handler = user.GetComponent(/datum/component/can_flash_from_behind)
		if(REF(blood_bond) in flash_handler?.sources)
			. += span_boldnotice("In order to convert someone into your blood brother, you must <i>directly flash them</i>, not AoE flash!")
			. += span_warning("Conversion will fail if the target is either dead, unconscious, SSD, mindshielded, a member of security, someone else's brother, or if they are targeted by your objectives.")