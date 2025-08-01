-- src/Client/Controllers/CoinController.lua

-- Knit setup
local Players = game:GetService("Players") 
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local coinTemplate = ReplicatedStorage:WaitForChild("Coin")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local CoinService = Knit.GetService("CoinService")

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
	local touchPart = coin:IsA("Model") and coin.PrimaryPart or coin
	touchPart.Touched:Connect(function(hit)
		local character = hit.Parent
		if character and character:FindFirstChild("Humanoid") then
			local player = Players:GetPlayerFromCharacter(character)
			if player and player:FindFirstChild("leaderstats") then
				print("✅ Coin collected by player:", player.Name)
				local reward = coin:FindFirstChild("Reward")
				
				if reward then
					CoinService:AddCoins(reward.Value)
					playSound(coin)
					print("✅ Collected coin worth", reward.Value)
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
CoinService.CoinsUpdated:Connect(function(amount)
	print("💰 Coins updated! New amount:", amount)
	-- You can update UI or play sound here
end)

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

	local basePart = areaPart:FindFirstChildWhichIsA("BasePart")

	if not basePart then
		return
	end

	local halfX = basePart.Size.X / 2
	local halfZ = basePart.Size.Z / 2

	local randomPos = basePart.Position + Vector3.new(math.random(-halfX, halfX), 2, math.random(-halfZ, halfZ))

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

	CoinService.CoinsUpdated:Connect(function(amount) 
			print(amount)
	end)

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

--[[task.spawn(function()
		for i = 0, 21, 1 do
			task.wait(2)
			for _, areaSpawn in ipairs(spawnAreas) do
				print("🪙 Spawning coin at", areaSpawn.Name)
				spawnCoin(coinTemplate, areaSpawn)
			end
		end
		print("✅ Finished spawning coins")
	end)]]
end

print("📦 CoinController loaded by Knit")

return CoinController
