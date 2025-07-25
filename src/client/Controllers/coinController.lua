-- src/Client/Controllers/CoinController.lua

-- Knit setup
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local coinTemplate = ReplicatedStorage:WaitForChild("Coin")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages.Knit)

local CoinController = Knit.CreateController({
	Name = "CoinController",
})

-- Play coin sound
local function playSound(coin)
	local sound = coin:FindFirstChild("CoinSound")
	if sound then
		local clone = sound:Clone()
		clone.Parent = Workspace
		clone:Play()

		clone.Ended:Connect(function()
			clone:Destroy()
		end)
	end
end

-- Handle coin collection
local function collectCoin(coin)
	coin.Touched:Connect(function(hit)
		local character = hit.Parent
		if character and character:FindFirstChild("Humanoid") then
			local player = Players:GetPlayerFromCharacter(character)
			if player and player:FindFirstChild("leaderstats") then
				local coins = player.leaderstats:FindFirstChild("Coins")
				local reward = coin:FindFirstChild("Reward")

				if coins and reward then
					coins.Value += reward.Value
					playSound(coin)
					coin:Destroy()
				end
			end
		end
	end)
end

-- Rotate coin using TweenService
local function spinCoin(coin)
	local tweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.InOut,
		-1 -- loop forever
	)

	local goal = {
		Orientation = coin.Orientation + Vector3.new(0, 360, 0),
	}

	local tween = TweenService:Create(coin, tweenInfo, goal)
	tween:Play()
end

-- Spawn a coin inside a spawn area
local function spawnCoin(template, areaPart)
	print("✅ Attempting to spawn coin at area:", areaPart.Name)

	if not template then
		warn("🚫 Coin template is nil!")
		return
	end

	local newCoin = template:Clone()

	if not workspace:FindFirstChild("Coins") then
		warn("🚫 Folder 'Coins' not found in Workspace!")
		return
	end

	newCoin.Parent = workspace:FindFirstChild("Coins")

	if not newCoin:IsA("BasePart") and not newCoin:IsA("Model") then
		warn("🚫 Cloned coin is not a valid Part or Model")
		return
	end

	if newCoin:IsA("Model") and not newCoin.PrimaryPart then
		warn("🚫 Cloned coin Model missing PrimaryPart")
		return
	end

	local halfX = areaPart.Size.X / 2
	local halfZ = areaPart.Size.Z / 2

	local randomPos = areaPart.Position + Vector3.new(math.random(-halfX, halfX), 2, math.random(-halfZ, halfZ))

	if newCoin:IsA("Model") then
		newCoin:SetPrimaryPartCFrame(CFrame.new(randomPos))
	else
		newCoin.Position = randomPos
	end

	print("✅ Coin spawned successfully at:", randomPos)

	spinCoin(newCoin)
	collectCoin(newCoin)
end

function CoinController:KnitStart()
	print("🔁 CoinController Starting...")

	local spawnAreaFolder = workspace:FindFirstChild("CoinSpawns")
	if not spawnAreaFolder then
		warn("⚠️ CoinSpawns folder not found in Workspace")
		return
	end
	
	local spawnAreas = spawnAreaFolder:GetChildren()
	if #spawnAreas == 0 then
		warn("⚠️ No spawn areas found inside CoinSpawns")
		return
	end
	
	task.spawn(function()
		while true do
			task.wait(1)
			for _, areaSpawn in ipairs(spawnAreas) do
				print("🪙 Spawning coin at", areaSpawn.Name)
				spawnCoin(coinTemplate, areaSpawn)
			end
		end
	end)
	
end

print("📦 CoinController loaded by Knit")

return CoinController
