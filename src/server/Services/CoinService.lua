-- Roblox Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit & Services
local Knit = require(ReplicatedStorage.Packages.Knit)
local DataService = require(script.Parent.DataService)

-- CoinService
local CoinService = Knit.CreateService({
	Name = "CoinService",
	Client = {
		CoinsUpdated = Knit.CreateSignal(),
	},
})

-- Internal coin tracking
local playerCoins = {}

-- Client method: get coin count
function CoinService.Client:GetCoins(player)
	return playerCoins[player] or 0
end

-- Server method: add coins, account for gamepass
function CoinService:AddCoins(player, baseAmount)
	local data = DataService:GetData(player)
	local amount = baseAmount

	if data and table.find(data.Gamepasses, "x2 Coins") then
		amount *= 2
	end

	playerCoins[player] = (playerCoins[player] or 0) + amount
	print("💰", player.Name, "now has", playerCoins[player], "coins")

	-- Update leaderstats
	local stats = player:FindFirstChild("leaderstats")
	if stats and stats:FindFirstChild("Coins") then
		stats.Coins.Value += amount
	end

	-- Fire client signal
	self.Client.CoinsUpdated:Fire(player, playerCoins[player])
end

-- Tween spinning animation
local function spinCoin(coin)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
	local goal = { Orientation = coin.Orientation + Vector3.new(0, 360, 0) }
	local tween = TweenService:Create(coin, tweenInfo, goal)
	tween:Play()
end

-- Play collection sound
local function playSound(coin)
	local sound = coin:FindFirstChild("CoinSound")
	if sound then
		local clone = sound:Clone()
		clone.Parent = Workspace
		clone:Play()
		clone.Ended:Connect(function() clone:Destroy() end)
	end
end

-- Collection logic (server-side, touch-based)
function CoinService:_setupTouchCollect(coin)
	local part = coin:IsA("Model") and coin.PrimaryPart or coin
	if not part then warn("Coin has no valid touchable part") return end

	part.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character or hit)

		if not (player and character and character:FindFirstChild("Humanoid")) then return end

		if coin:GetAttribute("Collected") then return end
		coin:SetAttribute("Collected", true)

		local reward = coin:FindFirstChild("Reward")
		if not reward or not reward:IsA("IntValue") then
			warn("🚫 No valid Reward inside coin")
			return
		end

		local value = reward.Value
		self:AddCoins(player, value)
		playSound(coin)

		print("✅", player.Name, "collected", value, "coins!")
		coin:Destroy()
	end)
end

-- Coin spawner in a given area
function CoinService:SpawnCoin(areaPart)
	local coinTemplate = ReplicatedStorage:WaitForChild("Coin")
	local newCoin = coinTemplate:Clone()
	newCoin.Name = "Coin"

	local basePart = areaPart:FindFirstChildWhichIsA("BasePart")
	if not basePart then return end

	local halfX, halfZ = basePart.Size.X / 2, basePart.Size.Z / 2
	local randomPos = basePart.Position + Vector3.new(math.random(-halfX, halfX), 2, math.random(-halfZ, halfZ))

	if newCoin:IsA("Model") then
		if not newCoin.PrimaryPart then warn("No PrimaryPart in coin model") return end
		newCoin:SetPrimaryPartCFrame(CFrame.new(randomPos))
		newCoin.PrimaryPart.Anchored = true
	else
		newCoin.Position = randomPos
		newCoin.Anchored = true
	end

	newCoin.Parent = Workspace:FindFirstChild("Coins") or Workspace
	spinCoin(newCoin)
	self:_setupTouchCollect(newCoin)
end

-- Player setup (leaderstats init)
local function onPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Optional getter
function CoinService:GetCoins(player)
	return playerCoins[player] or 0
end

-- Knit lifecycle start
function CoinService:KnitStart()
	print("🟢 CoinService started")

	-- Ensure Coins folder exists
	local coinFolder = Instance.new("Folder")
	coinFolder.Name = "Coins"
	coinFolder.Parent = Workspace

	-- Start spawn loop
	local spawnFolder = Workspace:FindFirstChild("CoinSpawns")
	if not spawnFolder then warn("⚠️ No CoinSpawns folder") return end

	local spawnAreas = spawnFolder:GetChildren()
	if #spawnAreas == 0 then warn("⚠️ No spawn areas") return end

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
