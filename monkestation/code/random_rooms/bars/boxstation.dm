//should most likely make these all be a subtype of /random_bar/icebox/ or something, would need use subtypesof() though
/datum/map_template/random_room/random_bar/box_base
	name = "Box Default Bar"
	room_id = "box_default_bar"
	mappath = "monkestation/_maps/RandomBars/Box/default_bar.dmm"
	centerspawner = FALSE
	template_height = 13
	template_width = 15
	weight = 6
	station_name = "Box Station"

/datum/map_template/random_room/random_bar/box_base/clockwork
	name = "Clockwork Bar"
	room_id = "box_clockwork"
	mappath = "monkestation/_maps/RandomBars/Box/clockwork_icebox.dmm"
	weight = 1

/datum/map_template/random_room/random_bar/box_base/cult
	name = "Cult Bar"
	room_id = "box_cult"
	mappath = "monkestation/_maps/RandomBars/Box/bloody_bar.dmm"
	weight = 1

/datum/map_template/random_room/random_bar/box_base/vietmoth
	name = "Jungle Bar"
	room_id = "box_vietmoth"
	mappath = "monkestation/_maps/RandomBars/Box/vietmoth_bar.dmm"
	weight = 12
