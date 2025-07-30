-- ✅ init.client.luau
print("✅ init.client running")
game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()

local GuiService = game:GetService("GuiService")
GuiService.AutoSelectGuiEnabled = true
GuiService.GuiNavigationEnabled = true

-- Game Services
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local KnitClient = require(Packages.Knit)
local Roact = require(Packages.Roact)
local RoactRodux = require(Packages.RoactRodux)

-- ✅ Load Controllers from the Controllers folder
KnitClient.AddControllers(script.Parent:WaitForChild("Controllers"))

-- ✅ Store setup
local Store = require(ReplicatedStorage.Shared.Rodux.Store)

-- ✅ Touchscreen orientation handling
if UserInputService.TouchEnabled then
	task.wait()
	local playerGUI = Players.LocalPlayer:WaitForChild("PlayerGui")
	playerGUI.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
end

-- ✅ Knit startup and UI mounting
KnitClient.Start()
	:andThen(function()
		print("✅ Knit Client Successfully Started")

		local Root = require(ReplicatedStorage.Shared.Roact.Root.Application)

		-- ✅ Synchronization module
		local Sync = require(StarterPlayer.StarterPlayerScripts.Modules.Synchronization)
		Sync()

		print("✅ Mounting Roact UI")

		-- Wrap HUD with StoreProvider
		local HUD = require(ReplicatedStorage.Shared.Roact.Applications.HUD.Application)

		local app = Roact.createElement(RoactRodux.StoreProvider, {
			store = Store,
		}, {
			HUD = Roact.createElement(HUD),
		})

		Roact.mount(app, Players.LocalPlayer:WaitForChild("PlayerGui"), "HUD")
		print("✅ Roact UI Mounted Successfully")

		-- ✅ Cleanup custom loading screen
		local success, result = pcall(function()
			return require(ReplicatedFirst:WaitForChild("initLoadingScreen"))
		end)

		if success and result and typeof(result) == "table" and typeof(result.Cleanup) == "function" then
			result.Cleanup()
			print("🩹 Custom loading screen removed!")
		else
			warn("⚠️ Could not cleanup loading screen properly")
		end
	end)
	:catch(warn)
