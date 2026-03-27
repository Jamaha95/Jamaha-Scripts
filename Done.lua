--// Fluent Load (EXACT FROM UI.lua)
local lib = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local w = lib:CreateWindow{
    Title = "Anime Card Collection",
    SubTitle = "Fluent UI",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
}

local Tabs = {
    Autofarm = w:CreateTab{ Title = "Autofarm", Icon = "play" },
    Grading = w:CreateTab{ Title = "Grading", Icon = "star" },
    Upgrades = w:CreateTab{ Title = "Upgrades", Icon = "arrow-up" },
    Tower = w:CreateTab{ Title = "Tower", Icon = "shield" },
    Settings = w:CreateTab{ Title = "Settings", Icon = "settings" }
}

--////////////////////////////////////////////////////////
-- ORIGINAL LOGIC STARTS (UNCHANGED)
--////////////////////////////////////////////////////////

-- (ALL YOUR ORIGINAL REQUIRES + FUNCTIONS STAY EXACTLY HERE)

--//////////// HELPER (CRITICAL FIX) ////////////
local function DictToArray(tbl)
    local t = {}
    for k,v in pairs(tbl) do
        if v == true then
            table.insert(t, k)
        end
    end
    return t
end

--////////////////////////////////////////////////////////
-- TOWER UI
--////////////////////////////////////////////////////////

local AutoBattleToggle = Tabs.Tower:CreateToggle("Auto Battle", {Title = "Auto Battle", Default = false})
AutoBattleToggle:OnChanged(function(v)
    AutoBattle = v
end)

Tabs.Tower:CreateParagraph("sep1",{Title="",Content=""})

local TraitCardDropdown = Tabs.Tower:CreateDropdown("Trait_Card",{
    Title="Select Card",
    Values = Cards(),
    Multi=true
})

TraitCardDropdown:OnChanged(function(v)
    TraitCard = DictToArray(v)
end)

local TraitDropdown = Tabs.Tower:CreateDropdown("Traits_Items",{
    Title="Select Trait",
    Values = Traits,
    Multi=true
})

TraitDropdown:OnChanged(function(v)
    Selected_Traits = DictToArray(v)
end)

local AutoTraitToggle = Tabs.Tower:CreateToggle("Auto Trait",{Title="Auto Trait",Default=false})
AutoTraitToggle:OnChanged(function(v)
    AutoTrait = v
end)

-- LIVE LABEL (FIXED)
local TraitLabel = Tabs.Tower:CreateParagraph("TraitTokens",{
    Title="Trait Tokens",
    Content="Loading..."
})

spawn(function()
    while task.wait() do
        pcall(function()
            TraitLabel:SetDesc("Trait Tokens: "..game.Players.LocalPlayer.PlayerGui.Traits.Frame.PlayerTokens.Amount.Text)
        end)
    end
end)

--////////////////////////////////////////////////////////
-- AUTOFARM UI
--////////////////////////////////////////////////////////

local t1 = Tabs.Autofarm:CreateToggle("Auto Collect",{Title="Auto Collect",Default=false})
t1:OnChanged(function(v) AutoCollect = v end)

local t2 = Tabs.Autofarm:CreateToggle("Auto Collect Tokens",{Title="Auto Collect Tokens",Default=false})
t2:OnChanged(function(v) AutoCollect_Tokens = v end)

local t3 = Tabs.Autofarm:CreateToggle("Auto Collect Potions/Travel Tokens",{Title="Auto Collect Potions/Travel Tokens",Default=false})
t3:OnChanged(function(v) AutoCollect_Potions_TravelToken = v end)

Tabs.Autofarm:CreateParagraph("sep2",{Title="",Content=""})

local PackDropdown = Tabs.Autofarm:CreateDropdown("Packs",{
    Title="Packs",
    Values=Packs,
    Multi=true
})
PackDropdown:OnChanged(function(v)
    Selected_Pack = DictToArray(v)
end)

local RarityDropdown = Tabs.Autofarm:CreateDropdown("Rarities",{
    Title="Rarities",
    Values=Rarities,
    Multi=true
})
RarityDropdown:OnChanged(function(v)
    Selected_Rarities = DictToArray(v)
end)

local t4 = Tabs.Autofarm:CreateToggle("Auto Buy Packs",{Title="Auto Buy Packs",Default=false})
t4:OnChanged(function(v) AutoBuy = v end)

Tabs.Autofarm:CreateParagraph("sep3",{Title="",Content=""})

local t5 = Tabs.Autofarm:CreateToggle("Auto Open Packs",{Title="Auto Open Packs",Default=false})
t5:OnChanged(function(v) AutoOpen = v end)

local t6 = Tabs.Autofarm:CreateToggle("Remove Opening Animation",{Title="Remove Opening Animation",Default=false})
t6:OnChanged(function(v)
    RemoveOpeningAnimation = v
    if v then
        CardOpening.OpenCard = function() return end
    else
        CardOpening.OpenCard = getgenv().OldOpeningAnimation
    end
end)

local t7 = Tabs.Autofarm:CreateToggle("Allow TP",{Title="Allow TP",Default=false})
t7:OnChanged(function(v) PacksTp = v end)

local t8 = Tabs.Autofarm:CreateToggle("Auto Place Packs",{Title="Auto Place Packs",Default=false})
t8:OnChanged(function(v) AutoPlace = v end)

--////////////////////////////////////////////////////////
-- GRADING UI
--////////////////////////////////////////////////////////

local GradeDropdown = Tabs.Grading:CreateDropdown("Grade",{
    Title="Select Grade",
    Values=Gradings,
    Multi=true
})
GradeDropdown:OnChanged(function(v)
    Selected_Grade = DictToArray(v)
end)

local CardDropdown = Tabs.Grading:CreateDropdown("Cards",{
    Title="Select Card",
    Values=Cards("All"),
    Multi=true
})
CardDropdown:OnChanged(function(v)
    Selected_Card = DictToArray(v)
end)

local t9 = Tabs.Grading:CreateToggle("Auto Grade",{Title="Auto Grade",Default=false})
t9:OnChanged(function(v) AutoGrade = v end)

--////////////////////////////////////////////////////////
-- UPGRADES UI
--////////////////////////////////////////////////////////

local UpgradeDropdown = Tabs.Upgrades:CreateDropdown("Upgrade",{
    Title="Select Upgrade",
    Values=Upgrades,
    Multi=true
})
UpgradeDropdown:OnChanged(function(v)
    Selected_Grade = DictToArray(v)
end)

local t10 = Tabs.Upgrades:CreateToggle("Auto Upgrade",{Title="Auto Upgrade",Default=false})
t10:OnChanged(function(v) AutoUpgrade = v end)

--////////////////////////////////////////////////////////
-- SETTINGS (EXACT)
--////////////////////////////////////////////////////////

SaveManager:SetLibrary(lib)
InterfaceManager:SetLibrary(lib)
InterfaceManager:SetFolder("AnimeCardCollection")
SaveManager:SetFolder("AnimeCardCollection/game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

w:SelectTab(1)
SaveManager:LoadAutoloadConfig()