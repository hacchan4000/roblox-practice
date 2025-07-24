-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Directories
local Reducers = ReplicatedStorage.Rodux.Reducers
local TemplateReducer = require(Reducers.TemplateReducer)

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Store
local StoreReducer = Rodux.combineReducers({
	TemplateReducer = TemplateReducer,
})

local Store = Rodux.Store.new(StoreReducer, nil, {
	-- middleware can go here if needed
})

return Store
