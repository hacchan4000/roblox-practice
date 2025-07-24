-- src/Client/Controllers/CoinController.lua

-- Knit setup
local Players = game:GetService("Players") -- ngambil elemen service player
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages.Knit)

local CoinController = Knit.CreateController({
	Name = "CoinController",
})

-- Play coin sound
local function playSound(coinMesh)
	local sound = coinMesh:FindFirstChild("CoinSound")
	if sound then
		local clone = sound:Clone()
		clone.Parent = workspace
		clone:Play()

		clone.Ended:Connect(function()
			clone:Destroy()
		end)
	end
end

-- When player touches the coin
local function collectCoin(coinMesh)
	coinMesh.Touched:Connect(function(hit)
		if hit.Parent:FindFirstChild("Humanoid") then
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player and player:FindFirstChild("leaderstats") then
				local coins = player.leaderstats:FindFirstChild("Coins")
				local reward = coinMesh:FindFirstChild("Reward")

				if coins and reward then
					coins.Value += reward.Value
					playSound(coinMesh)
					coinMesh:Destroy()
				end
			end
		end
	end)
end

-- Spin animation
local function spinCoin(coin)
	local tweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.InOut,
		-1, -- loop forever
		false,
		0
	)

	local properties = {
		Orientation = Vector3.new(0, 360, 0)
	}

	local spinTween = TweenService:Create(coin, tweenInfo, properties)
	spinTween:Play()
end

-- Spawn coin in defined area
local function spawnCoin(coinTemplate, areaSpawn)
	local newCoin = coinTemplate:Clone()
	newCoin.Parent = workspace:WaitForChild("Coin")

	local spacing = 2.2
	local randomPos = areaSpawn.Position + Vector3.new(
		math.random(-areaSpawn.Size.X / spacing, areaSpawn.Size.X / spacing), 2,
		math.random(-areaSpawn.Size.Z / spacing, areaSpawn.Size.Z / spacing)
	)

	newCoin.Position = randomPos

	spinCoin(newCoin)
	collectCoin(newCoin)
end

-- Called automatically when controller starts
function CoinController:KnitStart()
	local coinTemplate = script:WaitForChild("Coin") -- reference to the coin model/part
	local spawnAreas = workspace:WaitForChild("coinSpawns"):GetChildren()

	for _, areaSpawn in ipairs(spawnAreas) do
		for i = 1, 20 do
			spawnCoin(coinTemplate, areaSpawn)
		end
	end
end

return CoinController
