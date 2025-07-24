print("✅ init.client running")

local GuiService = game:GetService("GuiService")
GuiService.AutoSelectGuiEnabled = true
GuiService.GuiNavigationEnabled = true

-- Game Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Packages
local KnitClient = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoduxHooks = require(ReplicatedStorage.Packages.Roduxhooks)
local Preloader = require(ReplicatedStorage.Packages.Preloader)

-- ✅ FIXED: No more .Client in these paths
local Store = require(StarterPlayer.StarterPlayerScripts.Rodux.Store)

if UserInputService.TouchEnabled then
	task.wait()
	local playerGUI = Players.LocalPlayer:WaitForChild("PlayerGui")
	playerGUI.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
end

-- ✅ FIXED: Remove ".Client" from paths
Preloader:Configure({
	showLoadingScreen = true,
	loadControllers = true,
	loadImages = false,
	loadUI = false,
	initialDelay = 0.5,
	finalDelay = 1,
	skipEnabled = false,
	batchSize = 10,
	keepLoadingScreen = false,
	paths = {
		controllersPath = StarterPlayer.StarterPlayerScripts.Controllers,
		imagesPath = nil,
		componentsPath = nil,
	},
})

Preloader.ControllersLoadedSignal:Connect(function()
	KnitClient.Start()
		:andThen(function()
			print("✅ Knit Client Successfully Started")
		end)
		:catch(warn)
		:await()

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

Preloader.EndPreloaderSignal:Connect(function(bool)
	print("🔔 EndPreloaderSignal triggered:", bool)
end)

Preloader:PreloadContent()
