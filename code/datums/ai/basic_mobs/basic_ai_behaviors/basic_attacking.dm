/datum/ai_behavior/basic_melee_attack
	action_cooldown = 0.6 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/basic_melee_attack/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	//Hiding location is priority
	var/datum/weakref/weak_target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(!target)
		return FALSE
	controller.set_movement_target(target)

/datum/ai_behavior/basic_melee_attack/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn
	//targetting datum will kill the action if not real anymore
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	if(!targetting_datum.can_attack(basic_mob, target))
		finish_action(controller, FALSE, target_key)
		return

	var/hiding_target = targetting_datum.find_hidden_mobs(basic_mob, target) //If this is valid, theyre hidden in something!

	controller.blackboard[hiding_location_key] = hiding_target

	if(hiding_target) //Slap it!
		basic_mob.melee_attack(hiding_target)
	else
		basic_mob.melee_attack(target)


/datum/ai_behavior/basic_melee_attack/finish_action(datum/ai_controller/controller, succeeded, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	if(!succeeded)
		controller.blackboard -= target_key

/datum/ai_behavior/basic_ranged_attack
	action_cooldown = 0.6 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 3

/datum/ai_behavior/basic_ranged_attack/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(!target)
		return FALSE
	controller.set_movement_target(target)

/datum/ai_behavior/basic_ranged_attack/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn
	//targetting datum will kill the action if not real anymore
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	if(!targetting_datum.can_attack(basic_mob, target))
		finish_action(controller, FALSE, target_key)
		return

	var/atom/hiding_target = targetting_datum.find_hidden_mobs(basic_mob, target) //If this is valid, theyre hidden in something!

	controller.blackboard[hiding_location_key] = WEAKREF(hiding_target)

	if(hiding_target) //Shoot it!
		basic_mob.RangedAttack(hiding_target)
	else
		basic_mob.RangedAttack(target)

/datum/ai_behavior/basic_ranged_attack/finish_action(datum/ai_controller/controller, succeeded, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	if(!succeeded)
		controller.blackboard -= target_key
