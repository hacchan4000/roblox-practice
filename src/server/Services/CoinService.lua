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

-- Server-side, maybe in PlayerAdded or CoinService
local function onPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats
end

game.Players.PlayerAdded:Connect(onPlayerAdded)


-- Server method to get coins (non-client)
function CoinService:GetCoins(player)
	return playerCoins[player] or 0
end

-- Knit Signal to notify clients of coin updates
function CoinService:CoinsUpdated(player)
    
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
