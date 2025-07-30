local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Roact and dependencies
local Roact = require(ReplicatedStorage.Packages.Roact)
local Hooks = require(ReplicatedStorage.Packages.Hooks)
local RoactSpring = require(ReplicatedStorage.Packages._Index["chriscerie_roact-spring@1.1.6"]["roact-spring"])

-- Hooked HUD component
local function HUD(_, hooks)
	local useState = hooks.useState
	local useEffect = hooks.useEffect
	local useSpring = RoactSpring.useSpring

	local coins, setCoins = useState(0) -- ✅ Use normal variable assignment
	local player = Players.LocalPlayer

	-- Roact Spring animated value
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
					leaderstats = child
					coinValue = leaderstats:WaitForChild("Coins", 5)
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
		BackgroundTransparency = 0,
	}, {
		CoinCounter = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 0,
			Position = UDim2.fromScale(0.5, 0.05),
			Size = UDim2.fromScale(0.8, 0.1),
			Text = styles.nbToDisplay:map(function(val)
				return "💰 Coins: " .. math.floor(val)
			end),
			TextColor3 = Color3.fromRGB(255, 255, 0),
			TextScaled = true,
			Font = Enum.Font.GothamBold,
			ZIndex = 1,
		}),

		BottomFrame = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.965),
			Size = UDim2.fromScale(1, 0.13),
			ZIndex = 1,
			Name = "Bottom",
		}, {
			Button = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = Color3.fromRGB(175, 175, 175),
				BackgroundTransparency = 0.5,
				Size = UDim2.fromScale(0.18, 0.7),
				ZIndex = 1,
				Text = "Click",
				LayoutOrder = 1,
				[Roact.Event.MouseButton1Click] = function()
					print("Button clicked!")
				end,
			}),

			UIListLayout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0.03, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			UIAspectRatio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 4.5,
				AspectType = Enum.AspectType.FitWithinMaxSize,
				DominantAxis = Enum.DominantAxis.Width,
			}),
		}),
	})
end



return Hooks.new(Roact)(HUD)
