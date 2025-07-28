--file ini untuk menampilkan HUD (Heads-Up Display) di game Roblox
--Ini menggunakan Roact untuk membuat antarmuka pengguna yang responsif
-- disini tempat Frame utama dan elemen UI lainnya didefinisikan 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local CoinReducer = require(ReplicatedStorage.Shared.Rodux.Reducers.CoinReducer)

local styles, api = roactSpring.useSpring(hooks, function()
		return {
			nbToDisplay = CoinReducer.Coins,
		}
	end)

hooks.useEffect(function()
		api.start({
			nbToDisplay = CoinReducer.Coins,
		})
	end, { CoinReducer.Coins })
	
local function HUD(_, hooks)
	local useState = hooks.useState

	-- Get local player
	local player = game:GetService("Players").LocalPlayer

	-- Coin state
	local coins, setCoins = useState(0)

	-- Listen for coin updates
	hooks.useEffect(function()
		local leaderstats = player:FindFirstChild("leaderstats")
		local coinValue

		if not leaderstats then
			local connection
			connection = player.ChildAdded:Connect(function(child)
				if child.Name == "leaderstats" then
					leaderstats = child
					connection:Disconnect()
					coinValue = leaderstats:WaitForChild("Coins", 5)
					if coinValue then
						setCoins(coinValue.Value)
						coinValue:GetPropertyChangedSignal("Value"):Connect(function()
							setCoins(coinValue.Value)
						end)
					end
				end
			end)
		else
			coinValue = leaderstats:FindFirstChild("Coins")
			if coinValue then
				setCoins(coinValue.Value)
				coinValue:GetPropertyChangedSignal("Value"):Connect(function()
					setCoins(coinValue.Value)
				end)
			end
		end

		return function() end
	end, {})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		
		-- Top Coin Counter
		CoinCounter = Roact.createElement("TextLabel", {
			
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.05),
			Size = UDim2.fromScale(0.8, 0.1),
			Text = styles.nbToDisplay:map(function(nbToDisplay)
								return math.floor(nbToDisplay)
							end),
			TextColor3 = Color3.fromRGB(255, 255, 0),
			TextScaled = true,
			Font = Enum.Font.GothamBold,
			ZIndex = 1,
		}),

		-- Bottom Button (Optional)
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



HUD = RoactHooks.new(Roact)(HUD)
return HUD
