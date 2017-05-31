/obj/structure/trash_pile
	name = "trash pile"
	desc = "A heap of garbage, but maybe there's something interesting inside?"
	icon = 'icons/obj/trash_piles.dmi'
	icon_state = "randompile"
	density = 1
	anchored = 1.0

	var/list/searchedby	= list()// Characters that have searched this trashpile, with values of searched time.
	var/mob/living/hider		// A simple animal that might be hiding in the pile

	var/chance_alpha	= 79	// Alpha list is junk items and normal random stuff.
	var/chance_beta		= 20	// Beta list is actually maybe some useful illegal items. If it's not alpha or gamma, it's beta.
	var/chance_gamma	= 1		// Gamma list is unique items only, and will only spawn one of each. This is a sub-chance of beta chance.

	//These are types that can only spawn once, and then will be removed from this list.
	//Alpha and beta lists are in their respective procs.
	var/global/list/unique_gamma = list(
		/obj/item/device/perfect_tele,
		/obj/item/weapon/bluespace_harpoon,
		/obj/item/weapon/gun/energy/netgun,
		/obj/item/weapon/card/id/syndicate,
		/obj/item/weapon/moneybag/vault,
		/obj/item/weapon/permit,
		/obj/item/weapon/gun/projectile/dartgun
		)

	var/global/list/allocated_gamma = list()

/obj/structure/trash_pile/initialize()
	..()
	icon_state = pick("pile1","pile2","pilechair","piletable","pilevending")

/obj/structure/trash_pile/attackby(obj/item/W as obj, mob/user as mob)
	var/w_type = W.type
	if(w_type in allocated_gamma)
		to_chat(user,"<span class='notice'>You feel \the [W] slip from your hand, and disappear into the trash pile.</span>")
		user.unEquip(W)
		W.forceMove(src)
		allocated_gamma -= w_type
		unique_gamma += w_type
		qdel(W)

	else
		return ..()

/obj/structure/trash_pile/attack_generic(mob/user)
	//Simple Animal
	if(isanimal(user))
		var/mob/living/L = user
		//They're in it, and want to get out.
		if(L.loc == src)
			var/choice = alert("Do you want to exit \the [src]?","Un-Hide?","Exit","Stay")
			if(choice == "Exit")
				if(L == hider)
					hider = null
				L.forceMove(get_turf(src))
		else if(!hider)
			var/choice = alert("Do you want to hide in \the [src]?","Un-Hide?","Hide","Stay")
			if(choice == "Hide" && !hider) //Check again because PROMPT
				L.forceMove(src)
				hider = L
	else
		return ..()

/obj/structure/trash_pile/attack_hand(mob/user)
	//Human mob
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.visible_message("[user] searches through \the [src].","<span class='notice'>You search through \the [src].</span>")
		if(hider)
			to_chat(hider,"<span class='warning'>[user] is searching the trash pile you're in!</span>")

		//Do the searching
		if(do_after(user,rand(4 SECONDS,6 SECONDS),src))

			//If there was a hider, chance to reveal them
			if(hider && prob(50))
				to_chat(hider,"<span class='danger'>You've been discovered!</span>")
				hider.forceMove(get_turf(src))
				hider = null
				to_chat(user,"<span class='danger'>Some sort of creature leaps out of \the [src]!</span>")

			//You already searched this one bruh
			else if(user.ckey in searchedby)
				to_chat(H,"<span class='warning'>There's nothing else for you in \the [src]!</span>")

			//You found an item!
			else
				var/luck = rand(1,100)
				var/obj/item/I
				if(luck <= chance_alpha)
					I = produce_alpha_item()
				else if(luck <= chance_alpha+chance_beta)
					I = produce_beta_item()
				else if(luck <= chance_alpha+chance_beta+chance_gamma)
					I = produce_gamma_item()

				//We either have an item to hand over or we don't, at this point!
				if(I)
					searchedby += user.ckey
					I.forceMove(get_turf(src))
					to_chat(H,"<span class='notice'>You found \a [I]!</span>")

	else
		return ..()

//Random lists
/obj/structure/trash_pile/proc/produce_alpha_item()
	var/path = pick(prob(4);/obj/item/broken_device,
				prob(2);/obj/item/weapon/contraband/poster,
				prob(2);/obj/item/device/flashlight/flare,
				prob(2);/obj/item/device/flashlight/glowstick,
				prob(2);/obj/item/device/flashlight/glowstick/blue,
				prob(1);/obj/item/device/flashlight/glowstick/orange,
				prob(1);/obj/item/device/flashlight/glowstick/red,
				prob(1);/obj/item/device/flashlight/glowstick/yellow,
				prob(1);/obj/item/device/flashlight/pen,
				prob(4);/obj/item/weapon/cell,
				prob(4);/obj/item/weapon/cell/device,
				prob(3);/obj/item/weapon/cell/high,
				prob(2);/obj/item/weapon/cell/super,
				prob(5);/obj/random/cigarettes,
				prob(3);/obj/item/clothing/mask/gas,
				prob(2);/obj/item/clothing/mask/gas/half,
				prob(4);/obj/item/clothing/mask/breath,
				prob(2);/obj/item/weapon/reagent_containers/glass/rag,
				prob(4);/obj/item/weapon/reagent_containers/food/snacks/liquidfood,
				prob(2);/obj/item/weapon/storage/secure/briefcase,
				prob(4);/obj/item/weapon/storage/briefcase,
				prob(5);/obj/item/weapon/storage/backpack,
				prob(5);/obj/item/weapon/storage/backpack/satchel/norm,
				prob(4);/obj/item/weapon/storage/backpack/satchel,
				prob(3);/obj/item/weapon/storage/backpack/dufflebag,
				prob(1);/obj/item/weapon/storage/backpack/dufflebag/syndie,
				prob(5);/obj/item/weapon/storage/box,
				prob(3);/obj/item/weapon/storage/box/donkpockets,
				prob(2);/obj/item/weapon/storage/box/sinpockets,
				prob(1);/obj/item/weapon/storage/box/cups,
				prob(3);/obj/item/weapon/storage/box/mousetraps,
				prob(3);/obj/item/weapon/storage/box/engineer,
				prob(3);/obj/item/weapon/storage/wallet,
				prob(1);/obj/item/device/paicard,
				prob(2);/obj/item/clothing/shoes/galoshes,
				prob(1);/obj/item/clothing/shoes/syndigaloshes,
				prob(4);/obj/item/clothing/shoes/black,
				prob(4);/obj/item/clothing/shoes/laceup,
				prob(4);/obj/item/clothing/shoes/black,
				prob(4);/obj/item/clothing/shoes/leather,
				prob(1);/obj/item/clothing/gloves/yellow,
				prob(3);/obj/item/clothing/gloves/botanic_leather,
				prob(2);/obj/item/clothing/gloves/sterile/latex,
				prob(5);/obj/item/clothing/gloves/white,
				prob(5);/obj/item/clothing/gloves/rainbow,
				prob(2);/obj/item/clothing/gloves/fyellow,
				prob(1);/obj/item/clothing/glasses/sunglasses,
				prob(3);/obj/item/clothing/glasses/meson,
				prob(2);/obj/item/clothing/glasses/meson/prescription,
				prob(1);/obj/item/clothing/glasses/welding,
				prob(1);/obj/item/clothing/head/bio_hood/general,
				prob(4);/obj/item/clothing/head/hardhat,
				prob(3);/obj/item/clothing/head/hardhat/red,
				prob(1);/obj/item/clothing/head/ushanka,
				prob(2);/obj/item/clothing/head/welding,
				prob(4);/obj/item/clothing/suit/storage/hazardvest,
				prob(1);/obj/item/clothing/suit/space/emergency,
				prob(3);/obj/item/clothing/suit/storage/toggle/bomber,
				prob(1);/obj/item/clothing/suit/bio_suit/general,
				prob(3);/obj/item/clothing/suit/storage/toggle/hoodie/black,
				prob(3);/obj/item/clothing/suit/storage/toggle/hoodie/blue,
				prob(3);/obj/item/clothing/suit/storage/toggle/hoodie/red,
				prob(3);/obj/item/clothing/suit/storage/toggle/hoodie/yellow,
				prob(3);/obj/item/clothing/suit/storage/toggle/brown_jacket,
				prob(3);/obj/item/clothing/suit/storage/toggle/leather_jacket,
				prob(1);/obj/item/clothing/suit/storage/vest/press,
				prob(3);/obj/item/clothing/suit/storage/apron,
				prob(4);/obj/item/clothing/under/color/grey,
				prob(2);/obj/item/clothing/under/syndicate/tacticool,
				prob(2);/obj/item/clothing/under/pants/camo,
				prob(1);/obj/item/clothing/under/harness,
				prob(1);/obj/item/clothing/under/tactical,
				prob(3);/obj/item/clothing/accessory/storage/webbing,
				prob(4);/obj/item/weapon/spacecash/c1,
				prob(3);/obj/item/weapon/spacecash/c10,
				prob(3);/obj/item/weapon/spacecash/c20,
				prob(1);/obj/item/weapon/spacecash/c50,
				prob(1);/obj/item/weapon/spacecash/c100,
				prob(3);/obj/item/weapon/camera_assembly,
				prob(4);/obj/item/weapon/caution,
				prob(3);/obj/item/weapon/caution/cone,
				prob(2);/obj/item/weapon/card/emag_broken,
				prob(1);/obj/item/weapon/card/emag,
				prob(2);/obj/item/device/camera,
				prob(3);/obj/item/device/pda,
				prob(3);/obj/item/device/radio/headset)

	var/obj/item/I = new path()
	return I

/obj/structure/trash_pile/proc/produce_beta_item()
	var/path = pick(prob(6);/obj/item/weapon/storage/pill_bottle/tramadol,
			prob(4);/obj/item/weapon/storage/pill_bottle/happy,
			prob(4);/obj/item/weapon/storage/pill_bottle/zoom,
			prob(4);/obj/item/weapon/material/butterfly,
			prob(2);/obj/item/weapon/material/butterfly/switchblade,
			prob(2);/obj/item/weapon/material/knuckledusters,
			prob(1);/obj/item/weapon/material/hatchet/tacknife,
			prob(1);/obj/item/clothing/suit/storage/vest/heavy/merc,
			prob(1);/obj/item/weapon/beartrap,
			prob(1);/obj/item/weapon/handcuffs/fuzzy,
			prob(1);/obj/item/weapon/legcuffs,
			prob(2);/obj/item/weapon/reagent_containers/syringe/drugs,
			prob(1);/obj/item/weapon/reagent_containers/syringe/steroid,
			prob(4);/obj/item/device/radio_jammer,
			prob(2);/obj/item/weapon/storage/box/syndie_kit/spy,
			prob(2);/obj/item/weapon/grenade/anti_photon,
			prob(1);/obj/item/weapon/cell/hyper/empty)

	var/obj/item/I = new path()
	return I

/obj/structure/trash_pile/proc/produce_gamma_item()
	var/path = pick_n_take(unique_gamma)
	if(!path) //Tapped out, reallocate?
		for(var/P in allocated_gamma)
			var/obj/item/I = allocated_gamma[P]
			if(!I || istype(I.loc,/obj/machinery/computer/cryopod) || I.gcDestroyed)
				allocated_gamma -= P
				path = P
				break

	if(path)
		var/obj/item/I = new path()
		allocated_gamma[path] = I
		return I
	else
		return produce_beta_item()

