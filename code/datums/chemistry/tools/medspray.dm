/* ================================================= */
/* --------------- Spray Applicators --------------- */
/* ================================================= */

/obj/item/reagent_containers/medspray 
	name = "spray applicator"
	desc = "An electronic topical applicator, for medicinal use. It will smartly reject unsafe chemicals."
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	initial_volume = 80
	item_state = "medsprayred"
	icon_state = "medsprayred"
	flags = FPRINT | TABLEPASS | OPENCONTAINER | ONBELT | NOSPLASH
	module_research = list("science" = 3, "medicine" = 2)
	module_research_type = /obj/item/reagent_containers/hypospray
	var/list/whitelist = list()
	var/spray_amount = 5
	var/safe = 1
	mats = 6
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO

	New()
		..()
		if (src.safe && islist(chem_whitelist) && chem_whitelist.len)
			src.whitelist = chem_whitelist

	proc/check_whitelist(var/mob/user as mob)
		if (!safe || !src.whitelist || (islist(src.whitelist) && !src.whitelist.len))
			return
		var/found = 0
		for (var/reagent_id in src.reagents.reagent_list)
			if (!src.whitelist.Find(reagent_id))
				src.reagents.del_reagent(reagent_id)
				found = 1
		if (found)
			if (user)
				user.show_text("[src] identifies and removes a harmful substance.", "red") // haine: done -> //TODO: using usr in procs is evil shame on you
			else if (ismob(src.loc))
				var/mob/M = src.loc
				M.show_text("[src] identifies and removes a harmful substance.", "red")
			else
				src.visible_message("<span style=\"color:red\">[src] identifies and removes a harmful substance.</span>")

	on_reagent_change(add)
		if (src.safe && add)
			src.check_whitelist()

	attack_self(mob/user as mob)
		if (spray_amount == 5)
			spray_amount = 10
			user.show_text("You set [src]'s application mode to \"extended spray.\"", "blue")
		else
			spray_amount = 5
			user.show_text("You set [src]'s application mode to \"short burst.\"", "blue")

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (!reagents.total_volume)
			user.show_text("[src] is empty.", "red")
			return

		if (ismob(M))
			var/amt_prop = min(spray_amount, reagents.total_volume)
			user.visible_message("<span style=\"color:blue\"><B>[user] sprays [M] down with [amt_prop] units of [src.reagents.get_master_reagent_name()].</B></span>",\
			"<span style=\"color:blue\">You spray [amt_prop] units of [src.reagents.get_master_reagent_name()] on [M]. [src] now contains [max(0,(src.reagents.total_volume-amt_prop))] units.</span>")
			logTheThing("combat", user, M, "uses a medspray [log_reagents(src)] to inject %target% at [log_loc(user)].")

			src.reagents.reaction(M, TOUCH, amt_prop)
			src.reagents.trans_to(M, amt_prop/2)
			src.reagents.remove_any(amt_prop/2)
			src.reagents.update_total()

			playsound(M.loc, 'sound/items/hypo.ogg', 80, 0)
		else
			user.show_text("[src] can only be used on living organisms.", "red")

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/medspray/red

/obj/item/reagent_containers/medspray/pink
	item_state = "medspraypink"
	icon_state = "medspraypink"

/obj/item/reagent_containers/medspray/yellow
	item_state = "medsprayyellow"
	icon_state = "medsprayyellow"

/obj/item/reagent_containers/medspray/purple
	item_state = "medspraypurple"
	icon_state = "medspraypurple"

/obj/item/reagent_containers/medspray/green
	item_state = "medspraygreen"
	icon_state = "medspraygreen"

/obj/item/reagent_containers/medspray/blue
	item_state = "medsprayblue"
	icon_state = "medsprayblue"

/obj/item/reagent_containers/medspray/styptic_powder

	New()
		..()
		reagents.add_reagent("styptic_powder", 80)

/obj/item/reagent_containers/medspray/silver_sulfadiazine
	item_state = "medsprayyellow"
	icon_state = "medsprayyellow"

	New()
		..()
		reagents.add_reagent("silver_sulfadiazine", 80)

/obj/item/reagent_containers/medspray/synthflesh
	item_state = "medspraypink"
	icon_state = "medspraypink"

	New()
		..()
		reagents.add_reagent("synthflesh", 80)