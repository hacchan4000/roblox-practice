local passes = {}
for _, passesFile in pairs(script:GetDescendants()) do
    local pass = require(passesFile)
    for key, value in pairs(pass) do
        passes[key] = value
    end
end
return passes