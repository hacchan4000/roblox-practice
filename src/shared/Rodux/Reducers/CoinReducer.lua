local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rodux = require(ReplicatedStorage.Packages.Rodux)

local coinAction = Rodux.createReducer({
    coins = 0,
}, {
    addCoins = function(state, action)
        local newState = table.clone(state)
        newState.coins = newState.coins + action.amount
        return newState
    end,
    removeCoins = function(state, action)
        local newState = table.clone(state)
        newState.coins = math.max(0, newState.coins - action.amount)
        return newState
    end,
    setCoins = function(state, action)
        local newState = table.clone(state)
        newState.coins = action.amount
        return newState
    end,
    })