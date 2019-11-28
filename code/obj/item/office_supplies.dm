/obj/item/slide_rule
	name = "slide rule"
	icon = 'icons/obj/slide_rule.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_sliderule.dmi'
	icon_state = "sliderule"
	var/icon_base = "sliderule"
	var/image/slide_image

	var/mathx = 0
	var/mathy = 0
	var/ans = 0
	var/emagged = 0
	var/brokenRuler = 0
	var/iconNum = 1
	var/desc_1 = "Can be used to quickly solve a suprisingly large number of mathmatical calculations.<BR>"
	var/desc_2 = "The slide rule has not been used yet."
	var/save_1 = ""
	var/save_2 = ""
	var/save_3 = ""
	var/save_4 = ""
	var/save_5 = ""

	New()
		..()
		src.overlays = null
		slide_image = image(src.icon, "[src.icon_base][iconNum]")
		src.overlays += src.slide_image
		desc_2 = "[src] has not been used yet."

	get_desc()
		. += desc_1

	attack_self(mob/user as mob)
		src.browserMenu(user)
		return

	proc/browserMenu(mob/user as mob)
		if(brokenRuler > 0.5)
			user << browse("<TITLE>Slide Rule</TITLE>The slide rule has an existential crisis<BR>", "window=slide_rule")
			onclose(user, "slide_rule")
		else
			var/dat = ""
			dat += "<A href='?src=\ref[src];add=1'>Addition</A> | "
			dat += "<A href='?src=\ref[src];subtract=1'>Subtraction</A> | "
			dat += "<A href='?src=\ref[src];multiply=1'>Multipilcation</A> | "
			dat += "<A href='?src=\ref[src];divide=1'>Division</A><BR>"

			dat += "<A href='?src=\ref[src];exponent=1'>Exponent</A> | "
			dat += "<A href='?src=\ref[src];squareroot=1'>Square Root</A> | "
			dat += "<A href='?src=\ref[src];xroot=1'>Nth Root</A><BR>"

			dat += "<A href='?src=\ref[src];log=1'>Logarithm</A> | "
			dat += "<A href='?src=\ref[src];logbasex=1'>Log BaseX</A> | "
			dat += "<A href='?src=\ref[src];ln=1'>Natural Log</A><BR><BR>"

			dat += "<A href='?src=\ref[src];sin=1'>Sine</A> | "
			dat += "<A href='?src=\ref[src];cos=1'>Cosine</A> | "
			dat += "<A href='?src=\ref[src];tan=1'>Tangent</A><BR>"

			dat += "<A href='?src=\ref[src];arcsin=1'>Arcsine</A> | "
			dat += "<A href='?src=\ref[src];arccos=1'>Arccosine</A> | "
			dat += "<A href='?src=\ref[src];arctan=1'>Arctangent</A><BR>"

			if(src.emagged == 1)
				dat += "<BR><A href='?src=\ref[src];randomInt=1'>Random Integer</A> | "
				dat += "<A href='?src=\ref[src];randomDec=1'>Random Number</A><BR>"

			dat += "<BR>Previous Calculations:<BR>"
			dat += "[(save_5 == "") ? "" : "[save_5]<BR>"]"
			dat += "[(save_4 == "") ? "" : "[save_4]<BR>"]"
			dat += "[(save_3 == "") ? "" : "[save_3]<BR>"]"
			dat += "[(save_2 == "") ? "" : "[save_2]<BR>"]"
			dat += "[(save_1 == "") ? "" : "[save_1]<BR>"]"

			user << browse("<TITLE>Slide Rule</TITLE>Choose an operation:<BR><BR>[dat]", "window=slide_rule")
			onclose(user, "slide_rule")

	proc/set_x(var/header)
		var/temp = copytext(html_encode(input(usr, header, "Slide Rule", "") as null|text), 1, 32)
		if(temp == "pi" || temp == "Pi" || temp == "PI")
			mathx = 3.14159
		else if(temp == "ans" || temp == "Ans" || temp == "ANS" || temp == "answer" || temp == "Answer" || temp == "ANSWER")
			mathx = ans
		else if(temp == "e" || temp == "E")
			mathx = 2.71828
		else
			mathx = text2num(temp)
		if(mathx == null)
			mathx = 0

	proc/set_y(var/header)
		var/temp = copytext(html_encode(input(usr, header, "Slide Rule", "") as null|text), 1, 32)

		if(temp == "pi" || temp == "Pi" || temp == "PI")
			mathy = 3.14159
		else if(temp == "ans" || temp == "Ans" || temp == "ANS" || temp == "answer" || temp == "Answer" || temp == "ANSWER")
			mathy = ans
		else
			mathy = text2num(temp)
		if(mathy == null)
			mathy = 0

	proc/saveEquation(var/equ, mob/user as mob)
		usr.machine = src
		save_5 = save_4
		save_4 = save_3
		save_3 = save_2
		save_2 = save_1
		save_1 = equ

		iconNum = iconNum + 1
		if(iconNum > 5)
			iconNum = 1
		src.overlays = null
		slide_image = image(src.icon, "[src.icon_base][iconNum]")
		src.overlays += src.slide_image

		boutput(user, "[desc_2]")
		src.browserMenu(user)

	proc/selfDestruct()
		usr.machine = src
		brokenRuler = 1
		src.browserMenu(usr)

		var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
		s.set_up(7, 2, src)
		s.start()
		playsound(src.loc, "sound/effects/Explosion1.ogg", 35, 1)
		src.visible_message("<span style=\"color:red\">The [src] explodes!</span>")
		usr.drop_item()
		qdel(src)

	/obj/item/slide_rule/emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			src.emagged = 1
			src.browserMenu(user)
			if(user)
				boutput(user, "You slide the card along [src].")
			return 1
		return 0

	/obj/item/slide_rule/demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			boutput(user, "You slide the card along [src]. It returns to normal.")
		src.emagged = 0
		src.browserMenu(user)
		return 1

	Topic(href, href_list)
		usr.machine = src
		if(brokenRuler == 1 || !isturf(usr.loc)) return
		if (!in_range(src, usr)) return

		// Algebra
		if (href_list["add"])
			set_x("Number to add?")
			set_y("Add [mathx] by?")
			ans = mathx+mathy
			desc_2 = "[mathx]+[mathy] = [ans]"
			saveEquation("[desc_2]", usr)
			return
		if (href_list["subtract"])
			set_x("Number to add?")
			set_y("Subtract [mathx] by?")
			ans = mathx-mathy
			desc_2 = "[mathx]-[mathy] = [ans]"
			saveEquation("[desc_2]", usr)
			return
		if (href_list["multiply"])
			set_x("Number to multiply?")
			set_y("Multiply [mathx] by?")
			ans = mathx*mathy
			desc_2 = "[mathx]*[mathy] = [ans]"
			saveEquation("[desc_2]", usr)
			return
		if (href_list["divide"])
			set_x("Number to divide?")
			set_y("Divide [mathx] by?")
			if(mathy == 0)
				selfDestruct()
			else
				ans = mathx/mathy
				desc_2 = "[mathx]/[mathy] = [ans]"
				saveEquation("[desc_2]", usr)
			return
		if (href_list["exponent"])
			set_x("Value to find exponent of?")
			set_y("Exponent of [mathx]?")
			ans = mathx**mathy
			desc_2 = "[mathx]^[mathy] = [ans]"
			saveEquation("[desc_2]", usr)
			return
		if (href_list["squareroot"])
			set_x("Value to find square root of?")
			mathy = 0.5
			if(mathx < 0)
				mathx = abs(mathx)
				ans = mathx**mathy
				desc_2 = "sqrt(-[mathx]) = [ans]i"
				saveEquation("[desc_2]", usr)
			else
				ans = mathx**mathy
				desc_2 = "sqrt([mathx]) = [ans]"
				saveEquation("[desc_2]", usr)
			return
		if (href_list["xroot"])
			set_x("Root value?")
			set_y("Find the [mathx]-root of?")
			if(mathx == 0)
				boutput(usr, "Error")
			else
				if(mathy < 0)
					mathy = abs(mathy)
					ans = mathy**(1/mathx)
					desc_2 = "-[mathy]^(1/[mathx]) = [ans]i"
					saveEquation("[desc_2]", usr)
				else
					ans = mathy**(1/mathx)
					desc_2 = "[mathy]^(1/[mathx]) = [ans]"
					saveEquation("[desc_2]", usr)
			return

		//Triginometry
		if (href_list["sin"])
			set_x("Sin(x) of?")
			mathy = 0
			ans = sin(mathx)
			desc_2 = "sin([mathx]) = [ans]"
			saveEquation("[desc_2]", usr)
			return
		if (href_list["cos"])
			set_x("Cos(x) of?")
			mathy = 0
			ans = cos(mathx)
			desc_2 = "cos([mathx]) = [ans]"
			saveEquation("[desc_2]", usr)
			return
		if (href_list["tan"])
			set_x("Tan(x) of?")
			mathy = 0
			ans = sin(mathx)/cos(mathx)
			desc_2 = "tan([mathx]) = [ans]"
			saveEquation("[desc_2]", usr)
			return
		if (href_list["arcsin"])
			set_x("Arcsin(x) of?")
			mathy = 0
			if(mathx > 1)
				mathx = 1
			if(mathx < -1)
				mathx = -1
			ans = arcsin(mathx)
			desc_2 = "arcsin([mathx]) = [ans]"
			saveEquation("[desc_2]", usr)
			return
		if (href_list["arccos"])
			set_x("Arccos(x) of?")
			mathy = 0
			if(mathx > 1)
				mathx = 1
			if(mathx < -1)
				mathx = -1
			ans = arccos(mathx)
			desc_2 = "arccos([mathx]) = [ans]"
			saveEquation("[desc_2]", usr)
			return
		if (href_list["arctan"])
			set_x("Arctan(x) of?")
			mathy = 0
			if(mathx > 1)
				mathx = 1
			if(mathx < -1)
				mathx = -1
			ans = arcsin(mathx/sqrt(1+mathx*mathx))
			desc_2 = "arctan([mathx]) = [ans]"
			saveEquation("[desc_2]", usr)
			return

		// Logarithms
		if (href_list["log"])
			set_x("Log(x) of?")
			mathy = 0
			if(mathx <= 0)
				boutput(usr, "Error")
			else
				ans = log(mathx)
				desc_2 = "log([mathx]) = [ans]"
				saveEquation("[desc_2]", usr)
			return
		if (href_list["logbasex"])
			set_x("Base of log?")
			set_y("Base[mathx] log(x)?")
			if(mathx<=0 || mathy<=0)
				boutput(usr, "Error")
			else
				ans = log(mathx, mathy)
				desc_2 = "Log[mathx]([mathy]) = [ans]"
				saveEquation("[desc_2]", usr)
			return
		if (href_list["ln"])
			set_y("Base of log?")
			mathx = 2.71828
			if(mathy <= 0)
				boutput(usr, "Error")
			else
				ans = log(mathx, mathy)
				desc_2 = "ln([mathy]) = [ans]"
				saveEquation("[desc_2]", usr)
			return

		// Emag
		if (href_list["randomInt"])
			set_x("Upper bound of random integer?")
			set_y("Lower bound of random integer?")
			if(mathy>mathx)
				var/temp = mathx
				mathx = mathy
				mathy = temp
			ans = rand(mathy, mathx)
			desc_2 = "randomInt([mathx], [mathy]) = [ans]"
			saveEquation("[desc_2]", usr)
			return
		if (href_list["randomDec"])
			set_x("Upper bound of random number?")
			set_y("Lower bound of random number?")
			if(mathy>mathx)
				var/temp = mathx
				mathx = mathy
				mathy = temp
			ans = (rand()*(mathx-mathy)) + mathy
			desc_2 = "randomNum([mathx], [mathy]) = [ans]"
			saveEquation("[desc_2]", usr)
			return
		return