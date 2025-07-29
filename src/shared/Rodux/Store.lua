-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Actions = StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions
local CoinActions = require(Actions.CoinActions)

local DataService = require(ReplicatedStorage.Shared.Services.DataService)

-- Directories
local Reducers = ReplicatedStorage.Shared.Rodux.Reducers

local TemplateReducer = require(Reducers.TemplateReducer)

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Store
local StoreReducer = Rodux.combineReducers({
	TemplateReducer = TemplateReducer,
})

local coinReducer = require(Reducers.CoinReducer)

local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
Store:dispatch(CoinActions.setCoins(0))

local CoinReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.CoinReducer
end)

DataService:GetData():andThen(function(data)
		Store:dispatch(CoinActions.setCoins(data.Coins)) 
end)

return Store
