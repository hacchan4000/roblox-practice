-- Roblox Services
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- Knit Service
local CoinService = Knit.CreateService({
	Name = "CoinService", --nama dari service ini yang akan digunakan di server dan client
	Client = {}, --tabel yang berisi fungsi yang dapat diakses oleh client
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

local TweenService = game:GetService("TweenService")

local function spinCoin(coin)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
	local goal = { Orientation = coin.Orientation + Vector3.new(0, 360, 0) }
	local tween = TweenService:Create(coin, tweenInfo, goal)
	tween:Play()
end

-- Detect coin collection on server
local function detectCollection(coin)
	local touchPart = coin:IsA("Model") and coin.PrimaryPart or coin

	if not touchPart then return end

	touchPart.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = character and Players:GetPlayerFromCharacter(character)

		if player and player:FindFirstChild("Humanoid") then
			local reward = coin:FindFirstChild("Reward")
			if reward then
				local value = reward.Value or 1
				CoinService:AddCoins(player, value)

				-- Sync to leaderstats
				local stats = player:FindFirstChild("leaderstats")
				if stats and stats:FindFirstChild("Coins") then
					stats.Coins.Value += value
				end

				print("✅ Coin collected by", player.Name, "worth", value)
				coin:Destroy()
			end
		end
	end)
end


function CoinService:SpawnCoin(areaPart)
	local coinTemplate = game.ReplicatedStorage:WaitForChild("Coin")

	local newCoin = coinTemplate:Clone()
	newCoin.Name = "Coin"

	local basePart = areaPart:FindFirstChildWhichIsA("BasePart")
	if not basePart then return end

	local halfX, halfZ = basePart.Size.X / 2, basePart.Size.Z / 2
	local randomPos = basePart.Position + Vector3.new(math.random(-halfX, halfX), 2, math.random(-halfZ, halfZ))

	if newCoin:IsA("Model") then
		if not newCoin.PrimaryPart then warn("No PrimaryPart on coin model") return end
		newCoin:SetPrimaryPartCFrame(CFrame.new(randomPos))
	else
		newCoin.Position = randomPos
	end

	newCoin.Parent = workspace:WaitForChild("Coins")

	spinCoin(newCoin)
	detectCollection(newCoin)
	
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

	local coinFolder = Instance.new("Folder")
	coinFolder.Name = "Coins"
	coinFolder.Parent = workspace

	local spawnFolder = workspace:FindFirstChild("CoinSpawns")
	if not spawnFolder then warn("⚠️ No CoinSpawns folder") return end

	local spawnAreas = spawnFolder:GetChildren()
	if #spawnAreas == 0 then warn("⚠️ No spawn areas inside CoinSpawns") return end

	task.spawn(function()
		for i = 1, 21 do
			task.wait(2)
			for _, area in ipairs(spawnAreas) do
				self:SpawnCoin(area)
			end
		end
	end)
end



return CoinService
