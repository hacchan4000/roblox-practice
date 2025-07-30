-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Directories
local Actions = ReplicatedStorage.Shared.Rodux.Actions
local Reducers = ReplicatedStorage.Shared.Rodux.Reducers

-- Action Modules
local CoinActions = require(Actions.CoinActions)

-- Reducers
local CoinReducer = require(Reducers.CoinReducer)
local TemplateReducer = require(Reducers.TemplateReducer)

-- Combine Reducers
local StoreReducer = Rodux.combineReducers({
	CoinReducer = CoinReducer,
	TemplateReducer = TemplateReducer,
})

-- Create Store
local Store = Rodux.Store.new(StoreReducer)

-- Initial Dispatch
Store:dispatch(CoinActions.setCoins(0))

-- Optional: Sync DataService with Store
local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService
Knit.OnStart():andThen(function()
	DataService = Knit.GetService("DataService")

	DataService:GetData():andThen(function(data)
		Store:dispatch(CoinActions.setCoins(data.Coins))
	end)
end)


return Store
