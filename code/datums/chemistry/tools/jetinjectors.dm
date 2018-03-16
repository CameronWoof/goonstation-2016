/* ================================================= */
/* ----------------- Injector Carts ---------------- */
/* ================================================= */

/obj/item/reagent_containers/jetcart
	name = "injector cartridge"
	desc = "A disposable chemical cartridge, used with jet injectors."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "cartred"
	initial_volume = 40
	flags = FPRINT | TABLEPASS | NOSPLASH
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO

/obj/item/reagent_containers/jetcart/neuro
	name = "injector cartridge (neurological damage)"
	desc = "A disposable chemical cartridge, preloaded with medicine to treat neurological damage."

	New()
		..()
		reagents.add_reagent("mannitol", 40)

/obj/item/reagent_containers/jetcart/brute
	name = "injector cartridge (brute damage)"
	desc = "A disposable chemical cartridge, preloaded with medicine to treat brute trauma."
	icon_state = "cartpink"

	New()
		..()
		reagents.add_reagent("salicylic_acid", 40)

/obj/item/reagent_containers/jetcart/burn
	name = "injector cartridge (burn damage)"
	desc = "A disposable chemical cartridge, preloaded with medicine to treat burn damage."
	icon_state = "cartyellow"

	New()
		..()
		reagents.add_reagent("menthol", 40)

/obj/item/reagent_containers/jetcart/toxin
	name = "injector cartridge (toxin damage)"
	desc = "A disposable chemical cartridge, preloaded with medicine to counteract toxins."
	icon_state = "cartgreen"

	New()
		..()
		reagents.add_reagent("charcoal", 40)

/obj/item/reagent_containers/jetcart/genetic
	name = "injector cartridge (genetic damage)"
	desc = "A disposable chemical cartridge, preloaded with medicine to treat genetic irregularities."
	icon_state = "cartpurple"

	New()
		..()
		reagents.add_reagent("mutadone", 40)

/obj/item/reagent_containers/jetcart/oxy
	name = "injector cartridge (oxygen damage)"
	desc = "A disposable chemical cartridge, preloaded with medicine to treat oxygen deprivation."
	icon_state = "cartblue"

	New()
		..()
		reagents.add_reagent("salbutamol", 40)

/* ================================================= */
/* ----------------- Jet Injectors ----------------- */
/* ================================================= */

/obj/item/reagent_containers/jetinjector
	name = "jet injector"
	desc = "A reloadable, cartridge-based chemical injector. Accepts pre-filled, proprietary cartridges."
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	initial_volume = 40
	item_state = "syringe_0"
	icon_state = "jetinjector"
	flags = FPRINT | TABLEPASS | ONBELT | NOSPLASH
	module_research = list("science" = 3, "medicine" = 2)
	module_research_type = /obj/item/reagent_containers/hypospray
	mats = 6
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	var/cart = null
	var/cartcolor = null
	var/inj_amount = 10

	pickup(mob/user)
		..()
		update_icon()

	dropped(mob/user)
		..()
		update_icon()


	attackby(var/obj/item/reagent_containers/jetcart/C as obj, var/mob/user as mob)
		if (!istype(C, /obj/item/reagent_containers/jetcart))
			return
		if (src.cart)
			boutput(user, "The jet injector already has a cartridge loaded.")
			return
		cart = C
		cartcolor = C.icon_state
		C.reagents.trans_to(src, C.reagents.total_volume)
		user.drop_item()
		C.set_loc(src)
		boutput(user, "The cartridge clicks into place.")
		playsound(src.loc ,"sound/items/Deconstruct.ogg", 80, 0)
		update_icon()

	attack_hand(mob/user as mob)
		src.add_fingerprint(user)
		if (src.loc == user && src.cart)
			src.reagents.trans_to(src.cart, reagents.total_volume)
			user.put_in_hand_or_drop(src.cart)
			cart = null
			cartcolor = null
			boutput(user, "You eject the cartridge.")
			update_icon()
		else
			return ..()

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (!reagents.total_volume)
			user.show_text("[src.cart] is empty.", "red")
			return
		if (ismob(M))
			user.visible_message("<span style=\"color:blue\"><B>[user] injects [M] with [inj_amount] units of [src.reagents.get_master_reagent_name()].</B></span>",\
			"<span style=\"color:blue\">You inject [inj_amount] units of [src.reagents.get_master_reagent_name()]. [src] now contains [max(0,(src.reagents.total_volume-inj_amount))] units.</span>")
			logTheThing("combat", user, M, "uses a jet injector [log_reagents(src)] to inject %target% at [log_loc(user)].")

			src.reagents.trans_to(M, inj_amount)

			playsound(M.loc, 'sound/items/hypo.ogg', 80, 0)
		else
			user.show_text("[src] can only be used on living organisms.", "red")

		update_icon()

	proc/update_icon()
		var/rounded_vol = reagents ? round(reagents.total_volume,5) : 0;
		if (!src.cart)
			icon_state = "jetinjector"
			overlays = null
		if (src.cart)
			icon_state = "jetinjector_[rounded_vol]"
			overlays += "over_[src.cartcolor]"