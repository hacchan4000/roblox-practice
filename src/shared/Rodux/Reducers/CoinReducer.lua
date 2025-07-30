local initialState = {
    coins = 0,
}

local function CoinReducer(state, action)
    state = state or initialState

    if action.type == "SetCoins" then
        return {
            coins = action.payload
        }

    elseif action.type == "AddCoins" then
        return {
            coins = state.coins + action.payload
        }

    elseif action.type == "SubtractCoins" then
        return {
            coins = math.max(0, state.coins - action.payload)
        }
    end

    return state
end

return CoinReducer
