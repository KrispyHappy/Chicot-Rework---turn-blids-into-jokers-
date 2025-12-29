--- STEAMODDED HEADER
--- MOD_NAME: ChicotRework
--- MOD_ID: ChicotRework
--- PREFIX: cr
--- MOD_AUTHOR: [Rose]
--- MOD_DESCRIPTION: Chicot now feels legendary, turn boss blinds into jokers :)
local ChicotRework  = SMODS.current_mod
local config = ChicotRework.config

if SMODS.Atlas then
  SMODS.Atlas({
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34
  })
end

SMODS.Rarity{
	key = "blind",
	badge_colour = HEX("fda200"),
	pools = {["Joker"] = false}
}

SMODS.Atlas {
	key = "BlindJokers",
	path = "BlindJokers.png",
	px = 71,
	py = 95
}

assert(SMODS.load_file('JokerBlinds.lua'))()
assert(SMODS.load_file('JokerShowdowns.lua'))()

SMODS.Joker:take_ownership('matador', {
	name = "Matador (CR)",
	loc_txt = {
        ["name"] = "Matador",
        ["text"] = {
            [1] = "when {C:attention}Boss Blind{} is",
            [2] = "defeated in {C:attention}final hand{},",
            [3] = "{C:legendary,E:1}transform{} it into a {C:attention}joker{}",
            [4] = "and destroy this joker",
            [5] = "{C:inactive}#1#{}"
        },
    },
	rarity = 3,
	loc_vars = function(self, info_queue, card)
		return { vars = {'(Blinds take no room)' } }
	end,
    calculate = function(self, card, context)
	if context.end_of_round and context.game_over == false and context.main_eval and context.beat_boss and G.GAME.current_round.hands_left == 0 then
		SMODS.destroy_cards(card, nil, nil, true)
		G.E_MANAGER:add_event(Event({
			func = function()
				SMODS.add_card {
					set = 'Joker',
					rarity = 'cr_blind',
					key = 'j_cr_'..localize({type = 'name_text', key = G.GAME.blind.config.blind.key, set = 'Blind'})
				}
				return true
			end
			}))
		return {
			message = 'Jokerifed',
			colour = G.C.RED,
		}
	end
end})

SMODS.Joker:take_ownership('chicot', {
	name = "Chicot (CR)",
	loc_txt = {
        ["name"] = "Chicot",
        ["text"] = {
            [1] = "when {C:attention}Boss Blind{} is defeated,",
            [2] = "{C:legendary,E:1}transform{} it into a {C:attention}joker{}",
            [3] = "{C:inactive}#1#{}"
        },
    },
	loc_vars = function(self, info_queue, card)
		return { vars = {'(Blinds take no room)' } }
	end,
    calculate = function(self, card, context)
	if context.end_of_round and context.game_over == false and context.main_eval and context.beat_boss then
		G.E_MANAGER:add_event(Event({
			func = function()
				SMODS.add_card {
					set = 'Joker',
					rarity = 'cr_blind',
					key = 'j_cr_'..localize({type = 'name_text', key = G.GAME.blind.config.blind.key, set = 'Blind'})
				}
				return true
			end
			}))
		return {
			message = 'Jokerifed',
			colour = G.C.RED,
		}
	end
end})


SMODS.Back {
    key = "Beast",
	loc_txt = {
        ["name"] = "Beast Deck",
        ["text"] = {
            [1] = "when {C:attention}Boss Blind{} is",
            [2] = "defeated, {C:legendary,E:1}transform{}",
            [3] = "it into a {C:attention}joker{}. {C:attention}Joker{}",
            [4] = "{C:attention}Blinds{} now take room.",
            [5] = "{C:inactive}(Must have room)"
        },
    },
	atlas = 'BlindJokers',
    pos = { x = 7, y = 0 },
    unlocked = true,
    apply = apply,
	calculate = function(self, back, context)
	if context.end_of_round and context.game_over == false and context.main_eval and context.beat_boss and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
		G.GAME.joker_buffer = G.GAME.joker_buffer + 1
		G.E_MANAGER:add_event(Event({
			func = function()
				SMODS.add_card {
					set = 'Joker',
					rarity = 'cr_blind',
					key = 'j_cr_'..localize({type = 'name_text', key = G.GAME.blind.config.blind.key, set = 'Blind'})
				}
				G.GAME.joker_buffer = 0
				return true
			end
		}))
	end
end}
