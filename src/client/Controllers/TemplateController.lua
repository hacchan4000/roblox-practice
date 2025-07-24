-- Services
local Players = game:GetService("Players") -- jadi ini akses object global game yang merepresentasikan keseluruhan game
-- terus GetService itu nanya ke game, "Eh, ada service apa aja sih?" dan kita minta service Players
-- jadi Players itu service yang merepresentasikan semua pemain yang ada di game ini
-- misalnya, kalau ada 10 pemain yang main, Players itu bakal punya informasi tentang ke-10 pemain itu

local ReplicatedStorage = game:GetService("ReplicatedStorage") -- ReplicatedStorage itu tempat untuk menyimpan objek yang bisa diakses oleh semua pemain di game ini
-- jadi, kalau ada sesuatu yang perlu diakses oleh semua pemain, kita simpan di ReplicatedStorage
-- misalnya, kalau ada model atau script yang perlu diakses oleh semua pemain,
-- kita simpan di ReplicatedStorage supaya semua pemain bisa mengaksesnya

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

-- Player
local player = Players.LocalPlayer
-- LocalPlayer itu akses ke pemain yang lagi main di komputer kita sendiri, jadi kita bisa tahu siapa yang lagi main di komputer kita ini
-- misalnya, kalau kita main game ini, LocalPlayer itu bakal jadi kita sendiri
-- LocalPlayer itu penting karena kita bisa pakai untuk akses informasi tentang pemain yang lagi main di komputer kita sendiri

-- TemplateController
local TemplateController = Knit.CreateController({
	Name = "TemplateController",
})

--|| Local Functions ||--

--|| Functions ||--

function TemplateController:KnitStart() end

return TemplateController
