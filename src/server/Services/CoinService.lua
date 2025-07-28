-- Roblox Services
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- Knit Service
local CoinService = Knit.CreateService({
	Name = "CoinService",
	Client = {},
})

-- Local table to store each player's coin count
local playerCoins = {}

-- Client-accessible method to get their coin count
function CoinService.Client:GetCoins(player)
	return playerCoins[player] or 0
end

-- Server method to add coins
function CoinService:AddCoins(player, amount)
	playerCoins[player] = (playerCoins[player] or 0) + amount
	print("💰", player.Name, "now has", playerCoins[player], "coins")
end

-- Server method to get coins (non-client)
function CoinService:GetCoins(player)
	return playerCoins[player] or 0
end

-- KnitStart: Setup player listeners
function CoinService:KnitStart()
	print("🟢 CoinService started")

	Players.PlayerAdded:Connect(function(player)
		playerCoins[player] = 0
	end)

	Players.PlayerRemoving:Connect(function(player)
		playerCoins[player] = nil
	end)
end

return CoinService
