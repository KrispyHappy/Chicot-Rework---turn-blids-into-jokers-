SMODS.Joker {
	key = 'Amber Acorn',
	loc_txt = {
		name = 'Amber Acorn',
		text = {
			"when {C:attention}Blind{} is selected, {C:red}Flip{}",
			"and {C:attention}shuffle{} all {C:attention}Joker{} cards,",
			"then this randomly chooses if",
			"it copies the ability of the",
			"{C:attention}Joker{} to the right or left",
			"{C:inactive}(Copying {C:attention}#1#{C:inactive} Joker){}",
			"{C:inactive}#2#{}"
		}
	},
	config = {randomacornFloat = 42},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 2, y = 3 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if card.ability.randomacornFloat == 42 then
		return { vars = { 'No', '(Showdowns take no room)' } }
		elseif card.ability.randomacornFloat > 0.5 then
		return { vars = { 'Left', '(Showdowns take no room)' } }
		else
		return { vars = { 'Right', '(Showdowns take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.setting_blind then
			card.ability.randomacornFloat = math.random(0, 1)
			G.jokers:unhighlight_all()
			for _, joker in ipairs(G.jokers.cards) do
				joker:flip()
			end
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.2,
				func = function()
					G.E_MANAGER:add_event(Event({
						func = function()
							G.jokers:shuffle('aajk')
							play_sound('cardSlide1', 0.85)
							return true
						end,
					}))
					delay(0.15)
					G.E_MANAGER:add_event(Event({
						func = function()
							G.jokers:shuffle('aajk')
							play_sound('cardSlide1', 1.15)
							return true
						end
					}))
					delay(0.15)
					G.E_MANAGER:add_event(Event({
						func = function()
							G.jokers:shuffle('aajk')
							play_sound('cardSlide1', 1)
							return true
						end
					}))
					delay(0.5)
					return true
				end
			}))
		end
		local other_joker = nil
		if card.ability.randomacornFloat > 0.5 then
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i - 1] end
			end
		else
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i + 1] end
			end
		end
        local ret = SMODS.blueprint_effect(card, other_joker, context)
        if ret then
            ret.colour = G.C.BLUE
        end
        return ret
	end,
	add_to_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
	end
}

SMODS.Joker {
	key = 'Verdant Leaf',
	loc_txt = {
		name = 'Verdant Leaf',
		text = {
			"All cards {C:red}debuffed{} until",
			"{C:attention}#1#{} Joker {C:attention}sold{}. {C:attention}Jokers{}",
			"sold during a blind earn {C:money}#2#${}",
			"{C:inactive}#3#{}"
		}
	},
	config = {extra = {active = 1, sell_bonus = 8}},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 3, y = 3 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.active, card.ability.extra.sell_bonus, '(Showdowns take no room)' } }
	end,
	calculate = function(self, card, context)
		if context.end_of_round and context.game_over == false and context.main_eval then
			card.ability.extra.active = 1
		end
		if card.ability.extra.active == 0 and context.debuff_card and context.debuff_card.area ~= G.jokers then
			return {
				debuff = true
			}
		end
		if G.GAME.blind and context.selling_card and context.card.ability.set == 'Joker' then
			card:juice_up()
			ease_dollars(card.ability.extra.sell_bonus, true)
			card.ability.extra.active = 0
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
	end
}

SMODS.Joker {
	key = 'Violet Vessel',
	loc_txt = {
		name = 'Violet Vesse',
		text = {
			"{C:attention}+#1#{} hand size",
			"Blinds are {X:purple,C:white} X#2# {} {C:purple}Bigger{}",
			"{C:inactive}#3#{}"
		}
	},
	config = {h_size = 3, extra = 3},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 4, y = 3 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.h_size, card.ability.extra, '(Showdowns take no room)' } }
	end,
	calculate = function(self, card, context)
		if context.setting_blind then
			card:juice_up()
			play_sound('tarot2', 0.76, 0.4)
			G.GAME.blind.chips = G.GAME.blind.chips * card.ability.extra
			G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
			return {
				message = 'Blind Boost',
				colour = G.C.PURPLE
			}
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
	end
}

SMODS.Joker {
	key = 'Crimson Heart',
	loc_txt = {
		name = 'Crimson Heart',
		text = {
			"{C:attention}+#1#{} Joker slot",
			"One random {C:attention}Joker{} is",
			"{C:red}disabled{} every hand",
			"{C:inactive}#2#{}"
		}
	},
	config = {extra = 1},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 5, y = 3 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra, '(Showdowns take no room)' } }
	end,
	calculate = function(self, card, context)
		if context.debuff_card and context.debuff_card.area == G.jokers then
			if context.debuff_card.ability.crimson_heart_chosen then
				return {
					debuff = true
				}
			end
		end
		if context.hand_drawn then
			if G.jokers.cards[1] then
				local prev_chosen_set = {}
				local fallback_jokers = {}
				local jokers = {}
				for i = 1, #G.jokers.cards do
					if G.jokers.cards[i].ability.crimson_heart_chosen then
						prev_chosen_set[G.jokers.cards[i]] = true
						G.jokers.cards[i].ability.crimson_heart_chosen = nil
						if G.jokers.cards[i].debuff then SMODS.recalc_debuff(G.jokers.cards[i]) end
					end
				end
				for i = 1, #G.jokers.cards do
					if not G.jokers.cards[i].debuff then
						if not prev_chosen_set[G.jokers.cards[i]] and G.jokers.cards[i] ~= card then
							jokers[#jokers + 1] = G.jokers.cards[i]
						end
						table.insert(fallback_jokers, G.jokers.cards[i])
					end
				end
				if #jokers == 0 then jokers = fallback_jokers end
				local _card = pseudorandom_element(jokers, 'vremade_crimson_heart')
				if _card then
					_card.ability.crimson_heart_chosen = true
					SMODS.recalc_debuff(_card)
					_card:juice_up()
					card:juice_up()
				end
			end
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1 + card.ability.extra
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1 - card.ability.extra
		for _, joker in ipairs(G.jokers.cards) do
            joker.ability.crimson_heart_chosen = nil
        end
	end
}

SMODS.Joker {
	key = 'Cerulean Bell',
	loc_txt = {
		name = 'Cerulean Bell',
		text = {
			"{C:red}Forces{} 1 card to always",
			"be {C:attention}selected{}. {C:attention}Retrigger{}",
			"all cards played",
			"{C:inactive}#1#{}"
		}
	},
	config = {extra = 1},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 6, y = 3 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		return { vars = { '(Showdowns take no room)' } }
	end,
	calculate = function(self, card, context)
		if context.hand_drawn then
			local any_forced = nil
			for _, playing_card in ipairs(G.hand.cards) do
				if playing_card.ability.forced_selection then
					any_forced = true
				end
			end
			if not any_forced then
				G.hand:unhighlight_all()
				local forced_card = pseudorandom_element(G.hand.cards, 'vremade_cerulean_bell')
				forced_card.ability.forced_selection = true
				G.hand:add_to_highlighted(forced_card)
			end
		end
		if context.repetition and context.cardarea == G.play then
			return {
				repetitions = card.ability.extra
			}
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
	end
}

