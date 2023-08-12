#define ORE_TURF "ore_turf"
#define ORE_PLASMA "plasma"
#define ORE_IRON "iron"
#define ORE_URANIUM "uranium"
#define ORE_TITANIUM "titanium"
#define ORE_BLUESPACE "bluespace"
#define ORE_GOLD "gold"
#define ORE_SILVER "silver"
#define ORE_DIAMOND "diamond"
#define ORE_EMPTY "empty"

GLOBAL_LIST_INIT(jungle_ores, list( \
		ORE_IRON = new /datum/ore_patch/iron(),
		ORE_GOLD = new /datum/ore_patch/gold(),
		ORE_SILVER = new /datum/ore_patch/silver(),
		ORE_PLASMA = new /datum/ore_patch/plasma(),
		ORE_DIAMOND = new /datum/ore_patch/diamond(),
		ORE_TITANIUM = new /datum/ore_patch/titanium(),
		ORE_URANIUM = new /datum/ore_patch/uranium(),
		ORE_BLUESAPCE = new /datum/ore_patch/bluespace(),
		ORE_DILITHIUM = new /datum/ore_patch/dilithium()
))

GLOBAL_LIST_INIT(quarry_ores, list( \
		ORE_IRON = new /datum/ore_patch/iron(),
		ORE_GOLD = new /datum/ore_patch/gold(),
		ORE_SILVER = new /datum/ore_patch/silver(),
		ORE_PLASMA = new /datum/ore_patch/plasma(),
		ORE_DIAMOND = new /datum/ore_patch/diamond(),
		ORE_TITANIUM = new /datum/ore_patch/titanium(),
		ORE_URANIUM = new /datum/ore_patch/uranium(),
))

GLOBAL_LIST_EMPTY(tar_pits)

#define WEATHER_ACID "acid"

#define JUNGLELAND_TRAIT "jungleland" //trait that got aquired from some jungleland thing
#define TRAIT_ENEMY_OF_THE_FOREST "enemy_of_the_forest"

#define COMSIG_JUNGLELAND_TAR_CURSE_PROC "jungleland_tar_curse_proc"
#define COMSIG_REGEN_CORE_HEALED "regen_core_healed"


#define COMSIG_MOB_CHECK_SHIELDS "check_shields"
