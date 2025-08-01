--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local PolicyService = game:GetService("PolicyService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataCacheService = nil
local DataService = nil
-- MonetizationService
local MonetizationService = Knit.CreateService({
	Name = "MonetizationService",
	MonetizationList = {},
	Template = {},
	Prices = {},
	Client = {
		PurchaseFinished = Knit.CreateSignal(),
		GamepassesUpdate = Knit.CreateSignal(),
		UpdateData = Knit.CreateSignal(),
	},
})

--|| Client Functions ||--

-- Returns wheter or not the player has a gamepass
function MonetizationService.Client:HasGamepass(player: Player, name: string)
	return self.Server:HasGamepass(player, name)
end

-- Prompt product purchase
function MonetizationService.Client:PromptPurchase(player: Player, passId: number | string, type: string)
	return self.Server:PromptPurchase(player, passId, type)
end

-- Returns the pass ID from the product / gamepass
function MonetizationService.Client:GetID(player: Player, name: string)
	return self.Server:GetID(player, name)
end

--|| Functions ||--

-- Returns wheter or not the player has a gamepass
function MonetizationService:HasGamepass(player: Player, name: string)
	local passId = 0

	for pass, content in pairs(self.MonetizationList.GamePasses) do
		if content.Name == name then
			passId = pass
		end
	end

	if passId ~= 0 then
		local res = MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
		if typeof(res) == "boolean" then
			return res
		end
		return false
	end

	return false
end


-- Prompt product purchase
function MonetizationService:PromptPurchase(player: Player, passId: number | string, type: string)
	if typeof(passId) == "string" then
		passId = self:GetID(player, passId).ID
	end

	if self.MonetizationList[type][passId] ~= nil then
		if type == "Products" or type == "Packs" then
			local success, result = pcall(function()
				return PolicyService:GetPolicyInfoForPlayerAsync(player)
			end)
			if not success then
				return 
			else
				if
					not self.MonetizationList[type][passId].RestrictedRegionCanBuy
					and result.ArePaidRandomItemsRestricted
				then
					return
				end
			end
			local status = self.MonetizationList[type][passId].BeforeCheck(self, player.UserId)
			if status == false then
				return 
			end
			MarketplaceService:PromptProductPurchase(player, passId)
		elseif type == "GamePasses" then
			MarketplaceService:PromptGamePassPurchase(player, passId)
		end
	end
end

function MonetizationService:GetPrice(player, name: string)
	if self.Prices[name] ~= nil then
		return self.Prices[name]
	end

	local data = self:GetID(player, name)
	if data == nil then
		return 0
	end
	--print(data)
	--print(data.Type == "GamePasses" and Enum.InfoType.GamePass or Enum.InfoType.Product)
	local success, Infos = pcall(function()
		return MarketplaceService:GetProductInfo(
			data.ID,
			data.Type == "GamePasses" and Enum.InfoType.GamePass or Enum.InfoType.Product
		)
	end)

	if not success then
		warn("[MONETIZATION] Failed to get price for", name, Infos)
		return 0
	end

	self.Prices[name] = Infos.PriceInRobux
	return Infos.PriceInRobux
end

-- Handle successfull purchase
function MonetizationService:PurchaseFinished(userId: number, passId: number, success: boolean)
	local player = Players:GetPlayerByUserId(userId)
	self.Client.PurchaseFinished:Fire(player, success)

	local passData = self:GetData(passId)
	if success then
		local data = DataService:GetData(Players:GetPlayerByUserId(userId))
		if passData.Type == "GamePasses" then
			table.insert(data.Gamepasses, self.MonetizationList[passData.Type][passId].Name)
			self.Client.GamepassesUpdate:Fire(Players:GetPlayerByUserId(userId), data.Gamepasses)
		end
		self.MonetizationList[passData.Type][passId].Purchased(self, userId)
	end
end

-- Return the pass ID from the product / gamepass
function MonetizationService:GetID(player: Player, name: string)
	for typeName, type in pairs(self.MonetizationList) do
		for id, item in pairs(type) do
			if item.Name == name then
				return { ID = id, Type = typeName }
			end
		end
	end
end

function MonetizationService:GetData(id: number)
	for type, datas in pairs(self.MonetizationList) do
		for i, item in pairs(datas) do
			if i == id then
				return { Type = type, Name = item.Name }
			end
		end
	end
end

--|| Knit Lifecycle ||--
function MonetizationService:KnitInit()
	DataService = Knit.GetService("DataService")
	self.MonetizationList = require(ReplicatedStorage.Shared.Data.Monetization)
	

	Players.PlayerAdded:Connect(function(player)
		local data = DataService:GetData(player)
		task.wait(0.5)
		for id, d in self.MonetizationList.GamePasses do
			print("[MONETIZATION SERVICE] Checking if player has gamepass " .. d.Name)
			if self:HasGamepass(player, d.Name) and not table.find(data.Gamepasses, d.Name) then
				table.insert(data.Gamepasses, d.Name)
				print("[MONETIZATION SERVICE] Player has gamepass " .. d.Name)
				task.wait(0.1)
			end
		end
	end)

	MarketplaceService.PromptProductPurchaseFinished:Connect(
		function(userId: number, productId: number, isPurchased: boolean)
			self:PurchaseFinished(userId, productId, isPurchased)
		end
	)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(player: Player, passId: number, isPurchased: boolean)
			print(passId)
			print(isPurchased)
			self:PurchaseFinished(player.UserId, passId, isPurchased)
		end
	)

	print("[MONETIZATION SERVICE] Service loaded successfully.")
end

return MonetizationService
