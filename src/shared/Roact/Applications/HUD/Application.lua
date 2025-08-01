local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Hooks = require(ReplicatedStorage.Packages.Hooks)
local RoactRodux = require(ReplicatedStorage.Packages.RoactRodux)
local RoactSpring = require(ReplicatedStorage.Packages._Index["chriscerie_roact-spring@1.1.6"]["roact-spring"])
local MonetizationController = require(script.Parent.Parent.Controllers.MonetizationController)


-- Hook component
local function HUDView(_, hooks)
	local useState = hooks.useState
	local useEffect = hooks.useEffect
	local useSpring = RoactSpring.useSpring
	local player = Players.LocalPlayer

	local coins, setCoins = useState(0)

	local styles, api = useSpring(hooks, function()
		return {
			nbToDisplay = coins,
			config = { tension = 170, friction = 26 },
		}
	end)

	useEffect(function()
		api.start({ nbToDisplay = coins })
	end, { coins })

	useEffect(function()
		local leaderstats = player:FindFirstChild("leaderstats")
		local coinValue

		local function bindCoinValue(val)
			setCoins(val.Value)
			val:GetPropertyChangedSignal("Value"):Connect(function()
				setCoins(val.Value)
			end)
		end

		if leaderstats then
			coinValue = leaderstats:FindFirstChild("Coins")
			if coinValue then
				bindCoinValue(coinValue)
			end
		else
			local conn
			conn = player.ChildAdded:Connect(function(child)
				if child.Name == "leaderstats" then
					coinValue = child:WaitForChild("Coins", 5)
					if coinValue then
						bindCoinValue(coinValue)
					end
					conn:Disconnect()
				end
			end)
		end

		return function() end
	end, {})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		CoinCounter = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.05, 0.5),
			Size = UDim2.fromScale(0.15, 0.1),
			Text = styles.nbToDisplay:map(function(val)
				return "💰  " .. math.floor(val)
			end),
			TextColor3 = Color3.fromRGB(251, 251, 251),
			TextScaled = true,
			Font = Enum.Font.GothamBold,
			ZIndex = 1,
		}),

		BuyButton = Roact.createElement("ImageButton", {
			Image = "rbxassetid://107730284480326", -- ✅ Replace with actual ID
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(0.95, 0.1),
			Size = UDim2.fromScale(0.08, 0.08),
			BackgroundTransparency = 1,
			[Roact.Event.MouseButton1Click] = function()
				MonetizationController:BuyItem("x2 Coins")
			end,
		}),
	})
end

local HookedHUD = Hooks.new(Roact)(HUDView)

return function()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Name = "HUD",
	}, {
		HUD = Roact.createElement(HookedHUD),
	})
end
