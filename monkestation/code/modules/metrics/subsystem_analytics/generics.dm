/datum/controller/subsystem/air/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["active_turfs"] = length(active_turfs)
	cust["hotspots"] = length(hotspots)
	.["custom"] = cust

/datum/controller/subsystem/garbage/get_metrics()
	. = ..()
	var/list/cust = list()
	if((delslasttick + gcedlasttick) == 0) // Account for DIV0
		cust["gcr"] = 0
	else
		cust["gcr"] = (gcedlasttick / (delslasttick + gcedlasttick))
	cust["total_harddels"] = totaldels
	cust["total_softdels"] = totalgcs
	var/i = 0
	for(var/list/L in queues)
		i++
		cust["queue_[i]"] = length(L)

	.["custom"] = cust

/datum/controller/subsystem/lighting/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["sources_queue"] = length(sources_queue)
	.["custom"] = cust

/datum/controller/subsystem/machines/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing_machines"] = length(processing)
	.["custom"] = cust

/datum/controller/subsystem/mobs/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing_mobs"] = length(GLOB.mob_living_list)
	.["custom"] = cust


/datum/controller/subsystem/processing/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing"] = length(processing)
	.["custom"] = cust

/datum/controller/subsystem/tgui/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["open_uis"] = length(open_uis)
	cust["current_run"] = length(current_run)
	.["custom"] = cust


/datum/controller/subsystem/timer/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["bucket_count"] = bucket_count
	.["custom"] = cust

/datum/controller/subsystem/weather/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing_weather"] = length(processing)
	.["custom"] = cust
