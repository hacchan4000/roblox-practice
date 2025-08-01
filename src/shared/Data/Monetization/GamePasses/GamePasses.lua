local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
return table.freeze({
    [1151387440] = { -- Replace with actual GamePass ID
        Name = "DoubleCoins",
        BeforeCheck = function(self, userId)
            return true
        end,
        Purchased = function(self, userId)
            print("[MONETIZATION] User " .. userId .. " purchased DoubleCoins!")
        end,
        RestrictedRegionCanBuy = true
    }
})