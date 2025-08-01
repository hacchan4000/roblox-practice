local products = {}
for _, productsFile in pairs(script:GetDescendants()) do
    local pass = require(productsFile)
    for key, value in pairs(pass) do
        products[key] = value
    end
end
return products