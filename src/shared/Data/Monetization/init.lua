local monetization = {}

for _, categoryFile in pairs(script:GetChildren()) do
    if categoryFile:IsA("ModuleScript") then
        local category = require(categoryFile)
        monetization[categoryFile.Name] = category
    end
end

return monetization
