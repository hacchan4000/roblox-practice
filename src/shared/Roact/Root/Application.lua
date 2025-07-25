-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Wally Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)

-- Game Modules
local Applications = ReplicatedStorage.Shared.Roact.Applications
local Contexts = ReplicatedStorage.Shared.Roact.Contexts

--local AllowedApplicationsContext = require(Contexts.AllowedApplicationsContext)
--local ContextStack = require(Contexts.ContextStack)
--local HUD = require(Applications.HUD.Application)

return {
	Game = function()
		return Roact.createElement("TextLabel", {
			Text = "UI test successful!",
			Size = UDim2.fromScale(1, 1),
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})
	end
}
