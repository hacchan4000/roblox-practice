print("✅ init.client running")

local GuiService = game:GetService("GuiService")
GuiService.AutoSelectGuiEnabled = true
GuiService.GuiNavigationEnabled = true

-- Game Services
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Packages
local KnitClient = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)

-- ✅ FIXED: No more .Client in these paths
local Store = require(ReplicatedStorage.Shared.Rodux.Store)

-- Touch device screen orientation
if UserInputService.TouchEnabled then
	task.wait()
	local playerGUI = Players.LocalPlayer:WaitForChild("PlayerGui")
	playerGUI.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
end

-- ✅ Knit startup and UI mounting (Preloader removed)
KnitClient.Start()
	:andThen(function()
		print("✅ Knit Client Successfully Started")

		local Root = require(StarterPlayer.StarterPlayerScripts.Roact.Root.Application)
		local Sync = require(StarterPlayer.StarterPlayerScripts.Modules.Synchronization)

		print("✅ Mounting Roact UI")

		Sync()
		Roact.mount(
			Roact.createElement(RoduxHooks.Provider, {
				store = Store,
			}, {
				GameScreenGui = Roact.createElement(Root.Game),
			}),
			Players.LocalPlayer:WaitForChild("PlayerGui"),
			"UI"
		)
	end)
	:catch(warn)
