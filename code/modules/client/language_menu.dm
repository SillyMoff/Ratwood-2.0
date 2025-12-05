/datum/preferences/proc/open_language_menu(mob/user)
	if(!user || !user.client)
		return
	
	user << browse(generate_language_html(user), "window=language_menu;size=800x600")

/datum/preferences/proc/generate_language_html(mob/user)
	var/total_triumphs = 0
	if(user && user.client)
		total_triumphs = user.get_triumphs() || 0
	var/spent_triumphs = 0
	
	// Calculate spent triumphs from languages (2 each)
	var/purchased_count = 0
	if(extra_language_1 && extra_language_1 != "None")
		purchased_count++
	if(extra_language_2 && extra_language_2 != "None")
		purchased_count++
	
	spent_triumphs = purchased_count * 2
	var/remaining_triumphs = total_triumphs - spent_triumphs
	
	var/html = {"
		<!DOCTYPE html>
		<html lang="en">
		<meta charset='UTF-8'>
		<meta http-equiv='X-UA-Compatible' content='IE=edge,chrome=1'/>
		<style>
			body {
				font-family: Verdana, Arial, sans-serif;
				background: #1C0000;
				color: #e3c06f;
				margin: 0;
				padding: 20px;
			}
			.header {
				text-align: center;
				padding: 15px;
				background: rgba(0, 0, 0, 0.4);
				border: 1px solid #e3c06f;
				margin-bottom: 20px;
			}
			.header h1 {
				margin: 0;
				color: #e3c06f;
				font-size: 1.5em;
			}
			.triumph-counter {
				font-size: 1em;
				margin-top: 10px;
			}
			.triumph-available {
				color: #4CAF50;
			}
			.triumph-spent {
				color: #ff9800;
			}
			.info-box {
				background: rgba(76, 175, 80, 0.1);
				border: 1px solid #4CAF50;
				padding: 15px;
				margin-bottom: 20px;
				font-size: 0.9em;
			}
			.language-grid {
				display: grid;
				grid-template-columns: 1fr 1fr;
				gap: 15px;
				padding: 20px;
			}
			.language-slot {
				background: rgba(0, 0, 0, 0.4);
				border: 1px solid #444;
				padding: 15px;
			}
			.language-slot:hover {
				border-color: #e3c06f;
			}
			.slot-header {
				display: flex;
				justify-content: space-between;
				align-items: center;
				margin-bottom: 10px;
				padding-bottom: 10px;
				border-bottom: 1px solid #444;
			}
			.slot-number {
				font-weight: bold;
				color: #e3c06f;
			}
			.slot-cost {
				background: #e3c06f;
				color: #1C0000;
				padding: 2px 8px;
				font-size: 0.9em;
				font-weight: bold;
			}
			.language-display {
				margin-bottom: 10px;
			}
			.language-name {
				font-weight: bold;
				color: #e3c06f;
				margin-bottom: 5px;
				font-size: 1.1em;
			}
			.language-desc {
				font-size: 0.85em;
				color: #999;
				line-height: 1.4;
			}
			.btn {
				padding: 6px 12px;
				border: 1px solid #444;
				background: rgba(0, 0, 0, 0.4);
				color: #e3c06f;
				cursor: pointer;
				font-family: Verdana, Arial, sans-serif;
				font-size: 0.85em;
				text-decoration: none;
				display: inline-block;
				margin: 2px;
			}
			.btn:hover {
				background: rgba(227, 192, 111, 0.2);
				border-color: #e3c06f;
			}
			.btn-select {
				background: rgba(76, 175, 80, 0.3);
				border-color: #4CAF50;
				color: #4CAF50;
			}
			.btn-select:hover {
				background: rgba(76, 175, 80, 0.5);
			}
			.btn-clear {
				background: rgba(244, 67, 54, 0.3);
				border-color: #f44336;
				color: #f44336;
			}
			.btn-clear:hover {
				background: rgba(244, 67, 54, 0.5);
			}
			.empty-slot {
				text-align: center;
				padding: 20px;
				color: #666;
				font-style: italic;
			}
			.actions {
				margin-top: 10px;
				display: flex;
				flex-wrap: wrap;
				gap: 5px;
			}
		</style>
		<body>
			<div class="header">
				<h1>📜 Additional Language Selection 📜</h1>
				<div class="triumph-counter">
					<span class="triumph-available">Available Triumphs: [remaining_triumphs]</span> | 
					<span class="triumph-spent">Spent: [spent_triumphs]</span> / 
					<span>Total: [total_triumphs]</span>
				</div>
			</div>
			
			<div class="info-box">
				ℹ You get <b>one free language</b> based on your character background, plus up to 2 additional triumph languages (2 triumphs each). Your race already grants you certain languages by default.
			</div>
			
			<div class="language-grid">
	"}
	
	// FREE LANGUAGE SLOT
	var/datum/language/free_lang
	if(ispath(extra_language, /datum/language))
		free_lang = new extra_language()
	
	html += "<div class='language-slot' style='border-color: #4CAF50;'>"
	html += "<div class='slot-header'>"
	html += "<span class='slot-number'>Free Language</span>"
	html += "<span class='slot-cost' style='background: #4CAF50; color: #000;'>FREE</span>"
	html += "</div>"
	
	if(free_lang)
		html += "<div class='language-display'>"
		html += "<div class='language-name'>[free_lang.name]</div>"
		html += "<div class='language-desc'>[free_lang.desc]</div>"
		html += "</div>"
		html += "<div class='actions'>"
		html += "<a class='btn btn-select' href='byond://?src=\ref[src];language_action=free_change'>Change Language</a>"
		html += "</div>"
		qdel(free_lang)
	else
		html += "<div class='empty-slot'>"
		html += "No Language Selected<br><br>"
		html += "<a class='btn btn-select' href='byond://?src=\ref[src];language_action=free_select'>Select Language</a>"
		html += "</div>"
	
	html += "</div>"
	
	// Generate 2 TRIUMPH language slots
	for(var/i = 1 to 2)
		var/slot_var = i == 1 ? "extra_language_1" : "extra_language_2"
		var/current_lang_path = vars[slot_var]
		
		html += "<div class='language-slot'>"
		html += "<div class='slot-header'>"
		html += "<span class='slot-number'>Language Slot [i]</span>"
		
		if(current_lang_path && current_lang_path != "None")
			html += "<span class='slot-cost'>2 Triumphs</span>"
		
		html += "</div>"
		
		if(current_lang_path && current_lang_path != "None")
			// Language is selected
			var/datum/language/lang = new current_lang_path()
			
			html += "<div class='language-display'>"
			html += "<div class='language-name'>[lang.name]</div>"
			html += "<div class='language-desc'>[lang.desc]</div>"
			html += "</div>"
			
			html += "<div class='actions'>"
			html += "<a class='btn btn-select' href='byond://?src=\ref[src];language_action=change;slot=[i]'>Change Language</a>"
			html += "<a class='btn btn-clear' href='byond://?src=\ref[src];language_action=clear;slot=[i]'>Clear</a>"
			html += "</div>"
			
			qdel(lang)
		else
			// Empty slot
			html += "<div class='empty-slot'>"
			html += "No Language Selected<br><br>"
			html += "<a class='btn btn-select' href='byond://?src=\ref[src];language_action=select;slot=[i]'>Select Language</a>"
			html += "</div>"
		
		html += "</div>"
	
	html += {"
			</div>
		</body>
		</html>
	"}
	
	return html

/datum/preferences/Topic(href, href_list)
	. = ..()
	
	if(href_list["language_action"])
		var/action = href_list["language_action"]
		
		// Handle free language
		if(action == "free_select" || action == "free_change")
			var/static/list/selectable_languages = list(
				/datum/language/elvish,
				/datum/language/dwarvish,
				/datum/language/orcish,
				/datum/language/hellspeak,
				/datum/language/draconic,
				/datum/language/celestial,
				/datum/language/canilunzt,
				/datum/language/grenzelhoftian,
				/datum/language/kazengunese,
				/datum/language/etruscan,
				/datum/language/gronnic,
				/datum/language/otavan,
				/datum/language/aavnic,
				/datum/language/merar,
				/datum/language/thievescant/signlanguage
			)
			var/list/choices = list("None")
			for(var/language in selectable_languages)
				if(language in pref_species.languages)
					continue
				var/datum/language/a_language = new language()
				choices[a_language.name] = language
				qdel(a_language)
			
			var/chosen_language = input(usr, "Choose your character's extra language:", "EXTRA LANGUAGE") as null|anything in choices
			if(chosen_language)
				if(chosen_language == "None")
					extra_language = "None"
				else
					extra_language = choices[chosen_language]
				save_preferences()
			open_language_menu(usr)
			return
		
		// Handle triumph languages
		var/slot = text2num(href_list["slot"])
		
		if(!slot || slot < 1 || slot > 2)
			return
		
		var/slot_var = slot == 1 ? "extra_language_1" : "extra_language_2"
		
		switch(action)
			if("select", "change")
				// Show language selection menu
				var/static/list/selectable_languages = list(
					/datum/language/elvish,
					/datum/language/dwarvish,
					/datum/language/orcish,
					/datum/language/hellspeak,
					/datum/language/draconic,
					/datum/language/celestial,
					/datum/language/canilunzt,
					/datum/language/grenzelhoftian,
					/datum/language/kazengunese,
					/datum/language/etruscan,
					/datum/language/gronnic,
					/datum/language/otavan,
					/datum/language/aavnic,
					/datum/language/merar,
					/datum/language/thievescant/signlanguage
				)
				
				var/list/choices = list("None")
				for(var/language in selectable_languages)
					if(language in pref_species.languages)
						continue
					
					// Check if already selected in other slot
					var/other_slot_var = slot == 1 ? "extra_language_2" : "extra_language_1"
					if(vars[other_slot_var] == language)
						continue
					
					var/datum/language/a_language = new language()
					choices[a_language.name] = language
					qdel(a_language)
				
				var/chosen_language = input(usr, "Choose a language (2 triumphs each):", "Language Selection") as null|anything in choices
				
				if(chosen_language)
					if(chosen_language == "None")
						vars[slot_var] = "None"
					else
						var/language_path = choices[chosen_language]
						
						// Check triumph cost
						var/total_triumphs = 0
						if(usr && usr.client)
							total_triumphs = usr.get_triumphs() || 0
						var/spent_triumphs = 0
						
						// Count current language purchases (excluding this slot)
						var/other_slot_var = slot == 1 ? "extra_language_2" : "extra_language_1"
						if(vars[other_slot_var] && vars[other_slot_var] != "None")
							spent_triumphs += 2
							
						if(spent_triumphs + 2 > total_triumphs)
							to_chat(usr, span_warning("You don't have enough triumphs! Need 2, but only have [total_triumphs - spent_triumphs] remaining."))
							return
							
						vars[slot_var] = language_path
						to_chat(usr, span_notice("Selected [chosen_language] for language slot [slot]."))
					
					save_preferences()
				
				open_language_menu(usr)
			if("clear")
				vars[slot_var] = "None"
				save_preferences()
				open_language_menu(usr)
		
		return
