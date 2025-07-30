local CoinActions = {}

-- Action: Set the current coin value
function CoinActions.setCoins(amount)
    return {
        type = "SetCoins",
        payload = amount
    }
end

-- Action: Add a certain number of coins
function CoinActions.addCoins(amount)
    return {
        type = "AddCoins",
        payload = amount
    }
end

-- Action: Subtract coins (optional utility)
function CoinActions.subtractCoins(amount)
    return {
        type = "SubtractCoins",
        payload = amount
    }
end

return CoinActions
