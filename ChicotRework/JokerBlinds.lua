SMODS.Joker {
	key = 'The Hook',
	loc_txt = {
		name = 'The Hook',
		text = {
			"{C:red}Discards{} {C:attention}#1#{} random",
			"cards after {C:attention}hand played{}",
			"{C:inactive}#2#{}"
		}
	},
	config = {extra = 2},
	blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 1, y = 0 },
    pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.after then
			G.E_MANAGER:add_event(Event({
				func = function()
					local any_selected = nil
					local _cards = {}
					for _, playing_card in ipairs(G.hand.cards) do
						_cards[#_cards + 1] = playing_card
					end
					for i = 1, 2 do
						if G.hand.cards[i] then
							local selected_card, card_index = pseudorandom_element(_cards, 'vremade_hook')
							G.hand:add_to_highlighted(selected_card, true)
							table.remove(_cards, card_index)
							any_selected = true
							play_sound('card1', 1)
						end
					end
					if any_selected then G.FUNCS.discard_cards_from_highlighted(nil, true) end
					return true
				end
			}))
			delay(1)
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Ox',
	loc_txt = {
		name = 'The Ox',
		text = {
			"Playing your most played {C:attention}poker{}",
			"{C:attention}hand{} sets money to {C:red}$0{} and",
			"this gains half that much {C:mult}Mult{}",
			"{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}",
			"{C:inactive}#2#{}"
		}
	},
	config = {mult = 0},
	blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 3, y = 0 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.mult, '(Beast within calls)' } }
		else
		return { vars = { card.ability.mult, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
    if context.before and G.GAME.dollars > 0 then
		local take = true
		local play_more_than = (G.GAME.hands[context.scoring_name].played or 0)
            for handname, values in pairs(G.GAME.hands) do
                if handname ~= context.scoring_name and values.played >= play_more_than and SMODS.is_poker_hand_visible(handname) then
                    take = false
                    break
                end
            end
		if take then
			delay(0.3)
			card.ability.mult = card.ability.mult + math.floor(G.GAME.dollars/2)
			ease_dollars(-G.GAME.dollars, true)
			play_sound('tarot2', 0.76, 0.4)
			delay(0.3)
			return {
				message = localize('k_upgrade_ex'),
				colour = G.C.RED
			}
		end
    end
    if context.joker_main and card.ability.mult > 0 then
		return {
			message = localize{type='variable',key='a_mult',vars={card.ability.mult}},
			mult_mod = card.ability.mult
		}
	end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The House',
	loc_txt = {
		name = 'The House',
		text = {
			"{C:attention}First hand{} is drawn",
			"{C:red}face down{}, gives {X:mult,C:white} X#1# {} Mult",
			"on {C:attention}first hand played",
			"{C:inactive}#2#{}"
		}
	},
	config = {extra = 2},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 4, y = 0 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.stay_flipped and context.to_area == G.hand and G.GAME.current_round.hands_played == 0 and G.GAME.current_round.discards_used == 0 then
			card:juice_up()
			return {
				stay_flipped = true
			}
		end
		if context.joker_main and G.GAME.current_round.hands_played == 0 then
			return {
				message = localize{type='variable',key='a_xmult',vars={card.ability.extra}},
				Xmult_mod = card.ability.extra
			}
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Wall',
	loc_txt = {
		name = 'The Wall',
		text = {
			"{C:blue}+#2#{} hands each round",
			"Blinds are {X:purple,C:white}X#1#{} {C:purple}Bigger{}",
			"{C:inactive}#3#{}"
		}
	},
	config = {extra = 2, h_plays = 2},
	blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 5, y = 0 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra, card.ability.h_plays, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra, card.ability.h_plays, '(Blinds take no room)' } }
		end
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
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
		G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.h_plays
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
		G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.h_plays
	end
}

SMODS.Joker {
	key = 'The Wheel',
	loc_txt = {
		name = 'The Wheel',
		text = {
			"{C:green}1 in #1#{} cards get drawn",
			"{C:red}face down{}, this gains {C:chips}+#3# chips{}",
			"when this happens, resets when",
			"{C:attention}Boss Blind{} is defeated",
			"{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips){}",
			"{C:inactive}#4#{}"
		}
	},
	config = { extra = { odds = 7, chips = 0, chip_mod = 10 }},
	blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 6, y = 0 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra.odds, card.ability.extra.chips, card.ability.extra.chip_mod, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra.odds, card.ability.extra.chips, card.ability.extra.chip_mod, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.stay_flipped and context.to_area == G.hand and SMODS.pseudorandom_probability(blind, 'vremade_wheel', 1, card.ability.extra.odds) then
			card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
			return {
				stay_flipped = true,
				message = localize('k_upgrade_ex'),
				colour = G.C.CHIPS
			}
		end
		if context.joker_main then
			return {
				message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
				chip_mod = card.ability.extra.chips,
				colour = G.C.CHIPS
			}
		end
		if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
			if context.beat_boss then
			card.ability.extra.chips = 0
			return {
				message = localize('k_reset'),
				colour = G.C.CHIPS
			}
			end
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Arm',
	loc_txt = {
		name = 'The Arm',
		text = {
			"{C:red}Decrease{} level of",
			"played poker hand,",
			"playing cards score",
			"{C:mult}Mult{} triple to it's level",
			"{C:inactive}#1#{}"
		}
	},
	config = {extra = 3},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 0, y = 1 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { '(Beast within calls)' } }
		else
		return { vars = { '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
	if context.before then
		if G.GAME.hands[context.scoring_name].level > 1 then
			return {
				level_up = -1
			}
		end
	end
	if context.individual and context.cardarea == G.play then
		return {
			mult = G.GAME.hands[context.scoring_name].level*card.ability.extra
		}
	end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Club',
	loc_txt = {
		name = 'The Club',
		text = {
			"All {C:clubs}Club{} cards are {C:red}debuffed{}.",
			"This gains {C:mult}+#2# Mult{} if a discard",
			"cantains a {C:attention}debuffed{} {C:clubs}club{}, resets",
			"when {C:attention}Boss Blind{} is defeated",
			"{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult){}",
			"{C:inactive}#3#{}"
		}
	},
	config = {extra = {mult = 0, mult_mod = 4}},
	blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 1, y = 1 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.debuff_card and context.debuff_card.area ~= G.jokers and context.debuff_card:is_suit("Clubs") then
			return {
				debuff = true
			}
		end
		if context.pre_discard then
			for k, v in pairs(context.full_hand) do
				if v:is_suit('Clubs', true) and v.debuff then
				card.ability.extra.mult = card.ability.extra.mult+card.ability.extra.mult_mod
				return {
					message = localize('k_upgrade_ex'),
					colour = G.C.RED
				}
				end
			end
		end
		if context.joker_main then
			return {
				message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
				mult_mod = card.ability.extra.mult
			}
		end
		if context.end_of_round and context.game_over == false and context.main_eval then
			if context.beat_boss and card.ability.extra.mult > 0 then
				card.ability.extra.mult = 0
				return {
					message = localize('k_reset'),
					colour = G.C.RED
				}
			end
        end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Fish',
	loc_txt = {
		name = 'The Fish',
		text = {
			"{C:red}+#1#{} discard each round",
			"Cards drawn {C:red}face down{}",
			"after each {C:attention}hand played{}",
			"{C:inactive}#2#{}"
		}
	},
	config = {d_size = 1},
	blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 2, y = 1 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.d_size, '(Beast within calls)' } }
		else
		return { vars = { card.ability.d_size, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.after then
			fishprepped = true
		end
		if context.stay_flipped and context.to_area == G.hand and fishprepped then
			return {
				stay_flipped = true
			}
		end
        if context.hand_drawn then
            fishprepped = nil
        end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
		ease_discard(card.ability.d_size)
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
		ease_discard(-card.ability.d_size)
	end
}

SMODS.Joker {
	key = 'The Psychic',
	loc_txt = {
		name = 'The Psychic',
		text = {
			"This is destroyed if {C:attention}#1#{}",
			"cards isn't played. When",
			"{C:attention}Boss Blind{} is defeated,",
			"create a {C:spectral}Spectral{} card",
			"{C:inactive}(Must have room)",
			"{C:inactive}#2#{}"
		}
	},
	config = {extra = 5},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 3, y = 1 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.before and #context.full_hand ~= card.ability.extra then
			SMODS.destroy_cards(card, nil, nil, true)
			return {
				message = 'Bust'
			}
		end
		if context.end_of_round and context.game_over == false and context.main_eval and context.beat_boss then
			if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
				G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
				G.E_MANAGER:add_event(Event({
				func = (function()
				SMODS.add_card {set = 'Spectral'}
				G.GAME.consumeable_buffer = 0
				return true
				end)
				}))
				return {
					message = localize('k_plus_spectral'),
					colour = G.C.SECONDARY_SET.Spectral
				}
			end
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Goad',
	loc_txt = {
		name = 'The Goad',
		text = {
			"All {C:spades}Spade{} cards are {C:red}debuffed{}.",
			"This gains {C:chips}+#2# chips{} if a discard",
			"cantains a {C:attention}debuffed{} {C:spades}Spade{}, resets",
			"when {C:attention}Boss Blind{} is defeated",
			"{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}",
			"{C:inactive}#3#{}"
		}
	},
	config = {extra = {chips = 0, chip_mod = 20}},
	blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 4, y = 1 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra.chips, card.ability.extra.chip_mod, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra.chips, card.ability.extra.chip_mod, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.debuff_card and context.debuff_card.area ~= G.jokers and context.debuff_card:is_suit("Spades") then
			return {
				debuff = true
			}
		end
		if context.pre_discard then
			for k, v in pairs(context.full_hand) do
				if v:is_suit('Spades', true) and v.debuff then
				card.ability.extra.chips = card.ability.extra.chips+card.ability.extra.chip_mod
				return {
					message = localize('k_upgrade_ex'),
					colour = G.C.BLUE
				}
				end
			end
		end
		if context.joker_main then
			return {
				message = localize{type='variable',key='a_mult',vars={card.ability.extra.chips}},
				chip_mod = card.ability.extra.chips
			}
		end
		if context.end_of_round and context.game_over == false and context.main_eval then
			if context.beat_boss and card.ability.extra.chips > 0 then
				card.ability.extra.chips = 0
				return {
					message = localize('k_reset'),
					colour = G.C.BLUE
				}
			end
        end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Water',
	loc_txt = {
		name = 'The Water',
		text = {
			"When {C:attention}Blind{} is selected,",
			"{C:red}lose all discards{}. Creates",
			"the {C:planet}Planet{} card for first",
			"played {C:attention}poker hand{} of round",
			"{C:inactive}(Must have room)",
			"{C:inactive}#1#{}"
		}
	},
	config = {},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 5, y = 1 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { '(Beast within calls)' } }
		else
		return { vars = { '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.setting_blind then
            G.E_MANAGER:add_event(Event({
                func = function()
                    ease_discard(-G.GAME.current_round.discards_left, nil, true)
                    return true
                end
            }))
			return {
				message = 'Removed',
				colour = G.C.RED
			}
        end
		if context.after and G.GAME.current_round.hands_played == 0 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = function()
                    if G.GAME.last_hand_played then
                        local _planet = nil
                        for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                            if v.config.hand_type == G.GAME.last_hand_played then
                                _planet = v.key
                            end
                        end
                        if _planet then
                            SMODS.add_card({ key = _planet })
                        end
                        G.GAME.consumeable_buffer = 0
                    end
                    return true
                end
            }))
            return { message = localize('k_plus_planet'), colour = G.C.SECONDARY_SET.Planet }
        end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}


SMODS.Joker {
	key = 'The Window',
	loc_txt = {
		name = 'The Window',
		text = {
			"All {C:diamonds}Diamond{} cards are",
			"{C:red}debuffed{}. Earn {C:money}$#1#{} if",
			"a discard cantains",
			"a {C:attention}debuffed{} {C:diamonds}Diamond{}",
			"{C:inactive}#2#{}"
		}
	},
	config = {extra = 1},
	blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 6, y = 1 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.debuff_card and context.debuff_card.area ~= G.jokers and context.debuff_card:is_suit("Diamonds") then
			return {
				debuff = true
			}
		end
		if context.pre_discard then
			for k, v in pairs(context.full_hand) do
				if v:is_suit('Diamonds', true) and v.debuff then
					G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra
					return {
						dollars = card.ability.extra,
						func = function()
						G.E_MANAGER:add_event(Event({
						func = function()
						G.GAME.dollar_buffer = 0
						return true
						end
						}))
					end
					}
				end
			end
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Manacle',
	loc_txt = {
		name = 'The Manacle',
		text = {
			"{C:red}#1#{} hand size",
			"Gives {C:chips}+#2# chips{} multiplied",
			"by the difference between",
			"hand size and {C:attention}8{}",
			"{C:inactive}#3#{}"
		}
	},
	config = {h_size = -1, extra = 100},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 0, y = 0 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.h_size, card.ability.extra, '(Beast within calls)' } }
		else
		return { vars = { card.ability.h_size, card.ability.extra, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
	if context.joker_main then
		if G.hand.config.card_limit < 8 then
			return {
				chip_mod = card.ability.extra*(8-G.hand.config.card_limit),
				message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra*(8-G.hand.config.card_limit) } }
			}
		elseif G.hand.config.card_limit > 8 then
			return {
				chip_mod = card.ability.extra*(G.hand.config.card_limit-8),
				message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra*(G.hand.config.card_limit-8) } }
			}
		end
	  end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Eye',
	loc_txt = {
		name = 'The Eye',
		text = {
			"This is destroyed if a {C:attention}hand type{}",
			"is {C:attention}repeated{} this round. Gives {X:mult,C:white} X#1# {}",
			"Mult after {C:attention}first hand played{}",
			"{C:inactive}#2#{}"
		}
	},
	config = {extra = 2},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 0, y = 2 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
        if context.before and G.GAME.hands[context.scoring_name] and G.GAME.hands[context.scoring_name].played_this_round > 1 then
			SMODS.destroy_cards(card, nil, nil, true)
			return {
				message = 'Bust'
			}
        end
        if context.joker_main and G.GAME.current_round.hands_played > 0 then
			return {
				message = localize{type='variable',key='a_xmult',vars={card.ability.extra}},
				Xmult_mod = card.ability.extra
			}
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Mouth',
	loc_txt = {
		name = 'The Mouth',
		text = {
			"This is destroyed if a {C:attention}hand type{}",
			"isn't {C:attention}repeated{} this round. Gains",
			"{C:money}$#1#{} of {C:attention}sell value{} after repeat hand",
			"{C:inactive}#2#{}"
		}
	},
    config = { extra = { price = 1 } },
    blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 1, y = 2 },
	pixel_size = { h = 71 },
	cost = 0,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra.price, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra.price, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.before and G.GAME.hands[context.scoring_name] and G.GAME.hands[context.scoring_name].played_this_round == 1 and G.GAME.current_round.hands_played > 0 then
			SMODS.destroy_cards(card, nil, nil, true)
			return {
				message = 'Bust'
			}
        end
		if context.after and G.GAME.current_round.hands_played > 0 then
			card.ability.extra_value = card.ability.extra_value + card.ability.extra.price
            card:set_cost()
            return {
                message = localize('k_val_up'),
                colour = G.C.MONEY
            }
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Plant',
	loc_txt = {
		name = 'The Plant',
		text = {
			"All {C:attention}Face{} cards are {C:red}debuffed{}.",
			"{C:attention}+#2#{} hand size this round if a",
			"discard cantains a {C:attention}debuffed{} {C:attention}Face{}",
			"{C:inactive}(Currently {C:attention}+#1#{C:inactive} Hand size){}",
			"{C:inactive}#3#{}"
		}
	},
    config = { extra = { h_size = 0, h_mod = 1 } },
	blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 2, y = 2 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra.h_size, card.ability.extra.h_mod, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra.h_size, card.ability.extra.h_mod, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.debuff_card and context.debuff_card.area ~= G.jokers and context.debuff_card:is_face() then
			return {
				debuff = true
			}
		end
		if context.pre_discard then
			for k, v in pairs(context.full_hand) do
				if v:is_face(true) and v.debuff then
					card.ability.extra.h_size = card.ability.extra.h_size + card.ability.extra.h_mod
					G.hand:change_size(card.ability.extra.h_mod)
					return {
						message = localize('k_upgrade_ex'),
					}
				end
			end
		end
		if context.end_of_round and context.game_over == false and context.main_eval then
			G.hand:change_size(-card.ability.extra.h_size)
			card.ability.extra.h_size = 0
			return {
				message = localize('k_reset'),
			}
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
		G.hand:change_size(-card.ability.extra.h_size)
	end
}

SMODS.Joker {
	key = 'The Serpent',
	loc_txt = {
		name = 'The Serpent',
		text = {
			"{C:blue}#1#{} hand each round",
			"After {C:attention}play{} or {C:attention}discard{},",
			"always {C:attention}draw 3{} cards",
			"{C:inactive}#2#{}"
		}
	},
	config = {h_plays = -1},
	blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 2, y = 0 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.h_plays, '(Beast within calls)' } }
		else
		return { vars = { card.ability.h_plays, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.drawing_cards and (G.GAME.current_round.hands_played ~= 0 or G.GAME.current_round.discards_used ~= 0) then
			card:juice_up()
			return {
				cards_to_draw = 3
			}
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
		G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.h_plays
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
		G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.h_plays
	end
}

SMODS.Joker {
	key = 'The Pillar',
	loc_txt = {
		name = 'The Pillar',
		text = {
			"Cards played previously",
			"this {C:attention}Ante{} are {C:red}debuffed{}.",
			"At the end of round,",
			"create a {C:tarot}Tarot{} card",
			"{C:inactive}(Must have room)",
			"{C:inactive}#1#{}"
		}
	},
	config = {},
	blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 3, y = 2 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { '(Beast within calls)' } }
		else
		return { vars = { '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.debuff_card and context.debuff_card.area ~= G.jokers and context.debuff_card.ability.played_this_ante then
			return {
				debuff = true
			}
		end
		if context.end_of_round and context.game_over == false and context.main_eval then
			if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
				G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
				G.E_MANAGER:add_event(Event({
                func = (function()
					G.E_MANAGER:add_event(Event({
						func = function()
							SMODS.add_card { set = 'Tarot' }
							G.GAME.consumeable_buffer = 0
							return true
						end
					}))
					SMODS.calculate_effect({ message = localize('k_plus_tarot'), colour = G.C.PURPLE },
						context.blueprint_card or card)
					return true
				end)
			}))
			return nil, true
			end
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Needle',
	loc_txt = {
		name = 'The Needle',
		text = {
			"When {C:attention}Blind{} is selected,",
			"gain {C:red}+#2#{} discards set",
			"Hands to {C:blue}#1#{}. Earn {C:money}$#3#{}",
			"per discard remaining",
			"at end of round",
			"{C:inactive}#4#{}"
		}
	},
	config = {extra = {hands = 1, discards = 3, money = 2}},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 4, y = 2 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra.hands, card.ability.extra.discards, card.ability.extra.money, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra.hands, card.ability.extra.discards, card.ability.extra.money, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
        if context.setting_blind then
            ease_discard(card.ability.extra.discards)
            if not context.blueprint and not context.retrigger_joker then ease_hands_played(-1 * (G.GAME.round_resets.hands - card.ability.extra.hands)) end
			return {
				message = '+3 Discards',
				colour = G.C.BLUE
			}
        end
    end,
	calc_dollar_bonus = function(self, card)
		if G.GAME.current_round.discards_left > 0 then
			return G.GAME.current_round.discards_left * card.ability.extra.money
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Head',
	loc_txt = {
		name = 'The Head',
		text = {
			"All {C:hearts}Heart{} cards are {C:red}debuffed{}.",
			"This gains {X:red,C:white} X#2# {} Mult this",
			"round if a discard cantains a",
			"{C:attention}debuffed{} {C:hearts}Heart{}",
			"{C:inactive}(Currently {X:red,C:white}X#1#{}{C:inactive} mult){}",
			"{C:inactive}#3#{}"
		}
	},
    config = { extra = { Xmult = 1, Xmult_mod = 0.15 } },
	blueprint_compat = false,
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 5, y = 2 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_mod, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_mod, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.debuff_card and context.debuff_card.area ~= G.jokers and context.debuff_card:is_suit("Hearts") then
			return {
				debuff = true
			}
		end
		if context.pre_discard then
			for k, v in pairs(context.full_hand) do
				if v:is_suit("Hearts", true) and v.debuff then
					card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
					return {
						message = localize('k_upgrade_ex'),
					}
				end
			end
		end
		if context.joker_main and card.ability.extra.Xmult > 1 then
		    return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}},
                Xmult_mod = card.ability.extra.Xmult
            }
		end
		if context.end_of_round and context.game_over == false and context.main_eval then
			card.ability.extra.Xmult = 1
			return {
				message = localize('k_reset'),
			}
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Tooth',
	loc_txt = {
		name = 'The Tooth',
		text = {
			"{C:red}Lose $#3#{} and this gains",
			"{C:chips}+#2# chips{} per {C:attention}card played{}",
			"{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}",
			"{C:inactive}#4#{}"
		}
	},
    config = { chips = 0, chip_mod = 3, extra = 1 },
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 6, y = 2 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.chips, card.ability.chip_mod, card.ability.extra, '(Beast within calls)' } }
		else
		return { vars = { card.ability.chips, card.ability.chip_mod, card.ability.extra, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
        if context.before and not context.blueprint then
			local tooth = 0
            for i, v in ipairs(context.full_hand) do
				tooth = tooth + 1
				v:juice_up()
            end
			ease_dollars(-card.ability.extra*tooth, true)
			card.ability.chips = card.ability.chips + card.ability.chip_mod*tooth
			return {
				message = localize('k_upgrade_ex'),
				colour = G.C.CHIPS
			}
        end
		if context.joker_main then
			return {
				message = localize{type='variable',key='a_chips',vars={card.ability.chips}},
				chip_mod = card.ability.chips,
				colour = G.C.CHIPS
			}
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Flint',
	loc_txt = {
		name = 'The Flint',
		text = {
			"Base {C:chips}Chips{} and {C:mult}Mult{}",
			"are {C:red}halved{}. Played",
			"cards give {X:mult,C:white} X#1# {}",
			"Mult when scored",
			"{C:inactive}#2#{}"
		}
	},
	config = {extra = {Xmult = 1.1}},
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 0, y = 3 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { card.ability.extra.Xmult, '(Beast within calls)' } }
		else
		return { vars = { card.ability.extra.Xmult, '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.modify_hand then
			card:juice_up()
			mult = mod_mult(math.max(math.floor(mult * 0.5 + 0.5), 1))
			hand_chips = mod_chips(math.max(math.floor(hand_chips * 0.5 + 0.5), 0))
			update_hand_text({ sound = 'chips2', modded = true }, { chips = hand_chips, mult = mult })
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}

SMODS.Joker {
	key = 'The Mark',
	loc_txt = {
		name = 'The Mark',
		text = {
			"All {C:attention}Face{} cards are drawn",
			"{C:red}face down{}. {C:attention}Retrigger{}",
			"played hand if it's a {C:attention}Straight{}",
			"with a scoring {C:attention}face card",
			"{C:inactive}#1#{}"
		}
	},
    config = { extra = { repetitions = 1 } },
	rarity = 'cr_blind',
	atlas = 'BlindJokers',
	pos = { x = 1, y = 3 },
	pixel_size = { h = 71 },
	cost = 10,
    unlocked = true,
    discovered = true,
	loc_vars = function(self, info_queue, card)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		return { vars = { '(Beast within calls)' } }
		else
		return { vars = { '(Blinds take no room)' } }
		end
	end,
	calculate = function(self, card, context)
		if context.stay_flipped and context.to_area == G.hand and context.other_card:is_face(true) then
			return {
				stay_flipped = true
			}
		end
		if context.repetition and context.cardarea == G.play and context.poker_hands ~= nil and next(context.poker_hands['Straight']) then
			local face = false
			for i = 1, #context.scoring_hand do
				if context.scoring_hand[i]:is_face() then
					face = true
				end
			end
			if face then
				return {
					repetitions = card.ability.extra.repetitions
				}
			end
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'b_cr_Beast' then
		else
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
	end
}
