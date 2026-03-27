--// Fluent Load
local lib = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

--// Game Services & Requires (MUST BE BEFORE UI)
local Conversions = require(game:GetService("ReplicatedStorage").Modules.Utils.Conversions)
local suffixes = require(game:GetService("ReplicatedStorage").Modules.Utils.Conversions.Suffixes)

local suffixLookup = {}
for i, suffix in ipairs(suffixes) do
    suffixLookup[suffix:lower()] = i
end

Conversions.BigNumToNumber = function(value)
    value = tostring(value)
    value = value:gsub("%s+", "")
    value = value:gsub("%$", "")
    value = value:gsub(",", "")
    local isNegative = value:sub(1,1) == "-"
    if isNegative then value = value:sub(2) end
    local numberPart, suffix = value:match("^([%d%.]+)([a-zA-Z]*)$")
    if not numberPart then return tonumber(value) or 0 end
    local number = tonumber(numberPart)
    if not number then return 0 end
    suffix = suffix:lower()
    local index = suffixLookup[suffix]
    if not index then return isNegative and -number or number end
    local multiplier = 10^(3 * (index - 1))
    local result = number * multiplier
    return isNegative and -result or result
end

local TweenService       = game:GetService("TweenService")
local CardRemote         = game:GetService("ReplicatedStorage").Remotes.Card
local CardConfigModule   = require(game:GetService("ReplicatedStorage").Modules.Config.Core.CardConfig)
local CardOpening        = require(game:GetService("ReplicatedStorage").Client.UI.CardHandler.CardOpening)
local TowerHandler       = require(game:GetService("ReplicatedStorage").Client.UI.TowerHandler)
local TowerConfig        = require(game:GetService("ReplicatedStorage").Modules.Config.Core.TowerConfig)
local GradeHandler       = require(game:GetService("ReplicatedStorage").Client.UI.GradeHandler)

local v1  = game:GetService("Players")
local v2  = game:GetService("TweenService")
local v3  = game:GetService("ReplicatedStorage")
require(v3.Modules.GameUtils.Types)
local v7  = {}
local v13 = v1.LocalPlayer
local v14 = v13.PlayerGui
local v15 = v14.Tower.Frame
local v25 = false
local v30 = 0
local v31 = 0
v7.InBattle = false
local v37 = v3.Remotes.Tower

--// Helper Functions (MUST BE BEFORE UI)
function DataModule()
    return debug.getupvalues(GradeHandler.Init)[1]
end

local v8 = DataModule()

function GetPlot()
    return tostring(game.Players.LocalPlayer:GetAttribute("Plot"))
end

function fireproximitypromptfunc(Obj, Amount, Skip, Distance)
    if Obj.ClassName == "ProximityPrompt" then
        Amount   = Amount   or 1
        Distance = Distance or 20
        Obj.MaxActivationDistance = Distance
        local PromptTime = Obj.HoldDuration
        if Skip then Obj.HoldDuration = 0 end
        for i = 1, Amount do
            Obj:InputHoldBegin()
            if not Skip then wait(Obj.HoldDuration) end
            Obj:InputHoldEnd()
        end
        Obj.HoldDuration = PromptTime
        Obj.RequiresLineOfSight = false
    else
        error("userdata<ProximityPrompt> expected")
    end
end

function Cards(Extra)
    local Cards = {}
    if Extra ~= nil then Cards = {Extra} end
    for i,v in pairs(CardConfigModule.Packs) do
        for i,v in pairs(v.List) do
            if not table.find(Cards, i) then
                table.insert(Cards, i)
            end
        end
    end
    return Cards
end

--// Build data lists BEFORE UI uses them
local Traits = {}
for i,v in pairs(TowerConfig.Traits) do
    if not table.find(Traits, i) then
        table.insert(Traits, i)
    end
end

local Packs = {}
for i,v in pairs(game:GetService("ReplicatedStorage").Assets.Packs:GetChildren()) do
    if not table.find(Packs, v.Name) then
        table.insert(Packs, v.Name)
    end
end

local Rarities = {"All", "Normal"}
for i,v in pairs(require(game:GetService("ReplicatedStorage").Modules.Config.Core.PackExchange)) do
    if not table.find(Rarities, i) then
        table.insert(Rarities, i)
    end
end

local Gradings = {}
for i,v in pairs(require(game:GetService("ReplicatedStorage").Modules.Config.Core.Grades).List) do
    if not table.find(Gradings, v) then
        table.insert(Gradings, v)
    end
end

local UpgradeModule = require(game:GetService("ReplicatedStorage").Modules.Config.Core.Upgrades)
local Upgrades = {}
for i,v in pairs(UpgradeModule) do
    if not table.find(Upgrades, i) then
        table.insert(Upgrades, i)
    end
end

--// Save original functions
if not getgenv().OldOpeningAnimation then
    getgenv().OldOpeningAnimation = CardOpening.OpenCard
end
if not getgenv().FastTower then
    getgenv().FastTower = TowerHandler.Attack
    getgenv().UpdateFasterTower = TowerHandler.UpdateFasterTower
end
TowerHandler.UpdateFasterTower = function() return end

--// Helper: convert Fluent multi-select dict {name=true} to array
local function DictToArray(tbl)
    local t = {}
    for k,v in pairs(tbl) do
        if v == true then table.insert(t, k) end
    end
    return t
end

--////////////////////////////////////////////////////////
-- WINDOW
--////////////////////////////////////////////////////////

local w = lib:CreateWindow{
    Title      = "Anime Card Collection",
    SubTitle   = "Fluent UI",
    TabWidth   = 160,
    Size       = UDim2.fromOffset(830, 525),
    Resize     = true,
    MinSize    = Vector2.new(470, 380),
    Acrylic    = true,
    Theme      = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
}

local Tabs = {
    Autofarm = w:CreateTab{ Title = "Autofarm", Icon = "play"     },
    Grading  = w:CreateTab{ Title = "Grading",  Icon = "star"     },
    Upgrades = w:CreateTab{ Title = "Upgrades", Icon = "arrow-up" },
    Tower    = w:CreateTab{ Title = "Tower",    Icon = "shield"   },
    Settings = w:CreateTab{ Title = "Settings", Icon = "settings" },
}

--////////////////////////////////////////////////////////
-- TOWER UI + LOGIC
--////////////////////////////////////////////////////////

local AutoBattleToggle = Tabs.Tower:CreateToggle("AutoBattle", {Title="Auto Battle", Default=false})
AutoBattleToggle:OnChanged(function(v)
    AutoBattle = v
    if AutoBattle then
        TowerHandler.Attack = function(v81, v82)
            local v83 = 0.075
            local v84 = 0.1
            local v85 = 0.125
            local v86 = 0.1
            v15.VS.Visible = false
            local v87 = tonumber(v81)
            local v88 = tonumber(v82)
            local v89 = v87 / v30
            local v90 = math.clamp(v89, 0, 1)
            local v91 = v88 / v31
            local v92 = math.clamp(v91, 0, 1)
            v2:Create(v15.Player, TweenInfo.new(v83, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.fromScale(0.4,0.529)}):Play()
            v2:Create(v15.Enemy,  TweenInfo.new(v83, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.fromScale(0.6,0.529)}):Play()
            task.wait(v83)
            v15.Player.Whiteout.BackgroundTransparency = 0
            v15.Enemy.Whiteout.BackgroundTransparency  = 0
            v15.Player.Whiteout.Visible = true
            v15.Enemy.Whiteout.Visible  = true
            v2:Create(v15.Player.Whiteout, TweenInfo.new(v84, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {BackgroundTransparency=1}):Play()
            v2:Create(v15.Enemy.Whiteout,  TweenInfo.new(v84, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {BackgroundTransparency=1}):Play()
            v2:Create(v15.Player, TweenInfo.new(v84, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.fromScale(0.3,0.529)}):Play()
            v2:Create(v15.Enemy,  TweenInfo.new(v84, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.fromScale(0.7,0.529)}):Play()
            if v25 ~= true then v3.Assets.Sounds.Tower.Clash:Play() end
            task.wait(v84)
            v15.Player.Whiteout.Visible = false
            v15.Enemy.Whiteout.Visible  = false
            v15.Player.Health.Bar.Size  = UDim2.fromScale(v90, 1)
            v15.Enemy.Health.Bar.Size   = UDim2.fromScale(v92, 1)
            local v93 = v8.Conversions.Abbreviate(math.max(v87,0), 2)
            local v94 = v8.Conversions.Abbreviate(math.max(v88,0), 2)
            v15.Player.Health.HealthDisplay.Text = ("%*/%*"):format(v93, v8.Conversions.Abbreviate(v30,2))
            v15.Enemy.Health.HealthDisplay.Text  = ("%*/%*"):format(v94, v8.Conversions.Abbreviate(v31,2))
            task.delay(v85, function()
                v2:Create(v15.Player.Health.Back, TweenInfo.new(v83, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Size=UDim2.fromScale(v90,1)}):Play()
                v2:Create(v15.Enemy.Health.Back,  TweenInfo.new(v83, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Size=UDim2.fromScale(v92,1)}):Play()
                if v92 <= 0 and v25 ~= true then v3.Assets.Sounds.Tower.EnemyDefeated:Play() end
                task.wait(v86)
                v37:FireServer("AttackDone")
            end)
        end
    else
        TowerHandler.Attack = getgenv().FastTower
    end
end)

Tabs.Tower:CreateParagraph("sep1", {Title="", Content=""})

local TraitCardDropdown = Tabs.Tower:CreateDropdown("Trait_Card", {
    Title  = "Select Card",
    Values = Cards(),
    Multi  = true,
})
TraitCardDropdown:OnChanged(function(v)
    TraitCard = DictToArray(v)
end)

local TraitDropdown = Tabs.Tower:CreateDropdown("Traits_Items", {
    Title  = "Select Trait",
    Values = Traits,
    Multi  = true,
})
TraitDropdown:OnChanged(function(v)
    Selected_Traits = DictToArray(v)
end)

local AutoTraitToggle = Tabs.Tower:CreateToggle("AutoTrait", {Title="Auto Trait", Default=false})
AutoTraitToggle:OnChanged(function(v)
    AutoTrait = v
end)

local TraitLabel = Tabs.Tower:CreateParagraph("TraitTokens", {Title="Trait Tokens", Content="Loading..."})
spawn(function()
    while task.wait() do
        pcall(function()
            TraitLabel:SetDesc("Trait Tokens: "..game.Players.LocalPlayer.PlayerGui.Traits.Frame.PlayerTokens.Amount.Text)
        end)
    end
end)

-- Tower loops
spawn(function()
    while task.wait(0.1) do
        if AutoTrait and TraitCard and Selected_Traits then
            pcall(function()
                for i, v in pairs(TraitCard) do
                    local cardData    = DataModule().ReplicatedData.GetData("Cards", v)
                    local currentTrait = cardData and cardData.Trait
                    if not currentTrait or not table.find(Selected_Traits, currentTrait) then
                        game:GetService("ReplicatedStorage").Remotes.Tower:FireServer("Roll", v)
                    end
                end
            end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if AutoBattle then
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.Tower:FireServer("EquipBest")
                task.wait(0.1)
                game:GetService("ReplicatedStorage").Remotes.Tower:FireServer("StartTower")
                repeat task.wait() until not game:GetService("Players").LocalPlayer.PlayerGui.Tower.Frame.Visible or not AutoBattle
            end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if AutoBattle then
            pcall(function()
                v37:FireServer("AttackDone")
            end)
        end
    end
end)

--////////////////////////////////////////////////////////
-- AUTOFARM UI + LOGIC
--////////////////////////////////////////////////////////

local t1 = Tabs.Autofarm:CreateToggle("AutoCollect", {Title="Auto Collect", Default=false})
t1:OnChanged(function(v) AutoCollect = v end)

local t2 = Tabs.Autofarm:CreateToggle("AutoCollect_Tokens", {Title="Auto Collect Tokens", Default=false})
t2:OnChanged(function(v) AutoCollect_Tokens = v end)

local t3 = Tabs.Autofarm:CreateToggle("AutoCollect_Potions", {Title="Auto Collect Potions/Travel Tokens", Default=false})
t3:OnChanged(function(v) AutoCollect_Potions_TravelToken = v end)

Tabs.Autofarm:CreateParagraph("sep2", {Title="", Content=""})

local PackDropdown = Tabs.Autofarm:CreateDropdown("Packs", {
    Title  = "Packs",
    Values = Packs,
    Multi  = true,
})
PackDropdown:OnChanged(function(v) Selected_Pack = DictToArray(v) end)

local RarityDropdown = Tabs.Autofarm:CreateDropdown("Rarities", {
    Title  = "Rarities",
    Values = Rarities,
    Multi  = true,
})
RarityDropdown:OnChanged(function(v) Selected_Rarities = DictToArray(v) end)

local t4 = Tabs.Autofarm:CreateToggle("AutoBuy", {Title="Auto Buy Packs", Default=false})
t4:OnChanged(function(v) AutoBuy = v end)

Tabs.Autofarm:CreateParagraph("sep3", {Title="", Content=""})

local t5 = Tabs.Autofarm:CreateToggle("AutoOpen", {Title="Auto Open Packs", Default=false})
t5:OnChanged(function(v) AutoOpen = v end)

local t6 = Tabs.Autofarm:CreateToggle("RemoveOpeningAnimation", {Title="Remove Opening Animation", Default=false})
t6:OnChanged(function(v)
    RemoveOpeningAnimation = v
    if v then
        CardOpening.OpenCard = function() return end
    else
        CardOpening.OpenCard = getgenv().OldOpeningAnimation
    end
end)

local t7 = Tabs.Autofarm:CreateToggle("PacksTp", {Title="Allow TP", Default=false})
t7:OnChanged(function(v) PacksTp = v end)

local t8 = Tabs.Autofarm:CreateToggle("AutoPlace", {Title="Auto Place Packs (WIP)", Default=false})
t8:OnChanged(function(v) AutoPlace = v end)

-- Autofarm loops
spawn(function()
    while task.wait() do
        if AutoCollect then
            pcall(function()
                for i,v in pairs(workspace.Plots:GetChildren()) do
                    local Plot = v.Name
                    for i,v in pairs(workspace.Plots[Plot].Map.Display:GetChildren()) do
                        if v:IsA("Model") and (v.Name == "Left" or v.Name == "Right") then
                            for i2,v2 in pairs(v:GetChildren()) do
                                CardRemote:FireServer("Collect", workspace.Plots[GetPlot()].Map.Display[v.Name][v2.Name])
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
end)

local Page, Flip = 1, false
spawn(function()
    while task.wait() do
        if AutoCollect then
            pcall(function()
                if Page >= 12 then Page = 0; Flip = not Flip end
                local Event = game:GetService("ReplicatedStorage").Remotes.Card
                if Flip then
                    Event:FireServer("Page", "LeftArrow")
                else
                    Event:FireServer("Page", "RightArrow")
                end
                Page = Page + 1
                task.wait(0.05)
            end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if AutoCollect_Tokens then
            pcall(function()
                for i,v in pairs(workspace.Items.Tokens.Server:GetChildren()) do
                    v.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if AutoCollect_Potions_TravelToken then
            pcall(function()
                for i,v in pairs(workspace.Items.Misc.Collectables:GetChildren()) do
                    v.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if AutoBuy and Selected_Pack and Selected_Rarities then
            pcall(function()
                for i,v in pairs(workspace.Client.Packs:GetChildren()) do
                    if table.find(Selected_Pack, v:FindFirstChildOfClass("MeshPart").Name) then
                        for i2,v2 in pairs(v:GetChildren()) do
                            for i3,v3 in pairs(v2:GetChildren()) do
                                if v2:FindFirstChildOfClass("Part") then
                                    if table.find(Selected_Rarities, v3.Name) or table.find(Selected_Rarities, "All") then
                                        if DataModule().ReplicatedData.GetData("Cash") > Conversions.BigNumToNumber(v:FindFirstChildOfClass("MeshPart").ConveyorDisplay.Price.Text) then
                                            CardRemote:FireServer("BuyPack", v.Name)
                                        end
                                    end
                                else
                                    if table.find(Selected_Rarities, "Normal") or table.find(Selected_Rarities, "All") then
                                        if DataModule().ReplicatedData.GetData("Cash") > Conversions.BigNumToNumber(v:FindFirstChildOfClass("MeshPart").ConveyorDisplay.Price.Text) then
                                            CardRemote:FireServer("BuyPack", v.Name)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.02)
                end
            end)
        end
    end
end)

local OldPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
spawn(function()
    while task.wait() do
        if AutoOpen then
            pcall(function()
                for i,v in pairs(workspace.Plots[GetPlot()].Packs:GetChildren()) do
                    for i,v in pairs(v:GetChildren()) do
                        if v:FindFirstChildOfClass("ProximityPrompt") and v.PackTimer.Timer.Text == "Ready!" then
                            if PacksTp then
                                OldPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame * CFrame.new(0,2,0)
                                fireproximitypromptfunc(v.ProximityPrompt, 1, true, 9e9)
                                task.wait(.1)
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = OldPosition
                            end
                            task.wait()
                            fireproximitypromptfunc(v.ProximityPrompt, 1, true, 9e9)
                        end
                    end
                end
            end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if AutoPlace then
            pcall(function()
                for i,v in pairs(workspace.Plots[GetPlot()].Packs:GetChildren()) do
                    for i,v in pairs(v:GetChildren()) do
                        if v.Name ~= "Bottom" and v.Name ~= "Top" then
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame * CFrame.new(0,3,6)
                            for i,v in pairs(CardConfigModule.List) do
                                CardRemote:FireServer("Place", v)
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--////////////////////////////////////////////////////////
-- GRADING UI + LOGIC
--////////////////////////////////////////////////////////

local GradeDropdown = Tabs.Grading:CreateDropdown("Grade", {
    Title  = "Select Grade",
    Values = Gradings,
    Multi  = true,
})
GradeDropdown:OnChanged(function(v) Selected_Grade = DictToArray(v) end)

local CardDropdown = Tabs.Grading:CreateDropdown("Cards", {
    Title  = "Select Card",
    Values = Cards("All"),
    Multi  = true,
})
CardDropdown:OnChanged(function(v) Selected_Card = DictToArray(v) end)

local t9 = Tabs.Grading:CreateToggle("AutoGrade", {Title="Auto Grade", Default=false})
t9:OnChanged(function(v) AutoGrade = v end)

spawn(function()
    while task.wait() do
        if AutoGrade and Selected_Grade and Selected_Card then
            pcall(function()
                local CardsData = DataModule().ReplicatedData.GetData("Cards")
                if table.find(Selected_Card, "All") then
                    for i,v in pairs(CardsData) do
                        if not table.find(Selected_Grade, v.Grade) then
                            game:GetService("ReplicatedStorage").Remotes.Grade:FireServer("Roll", i)
                            task.wait(0.05)
                        end
                    end
                else
                    for i,v in pairs(Selected_Card) do
                        if v and not table.find(Selected_Grade, DataModule().ReplicatedData.GetData("Cards", v).Grade) then
                            game:GetService("ReplicatedStorage").Remotes.Grade:FireServer("Roll", v)
                            task.wait(0.05)
                        end
                    end
                end
            end)
        end
    end
end)

--////////////////////////////////////////////////////////
-- UPGRADES UI + LOGIC
--////////////////////////////////////////////////////////

local UpgradeDropdown = Tabs.Upgrades:CreateDropdown("Upgrade", {
    Title  = "Select Upgrade",
    Values = Upgrades,
    Multi  = true,
})
UpgradeDropdown:OnChanged(function(v) Selected_Upgrade = DictToArray(v) end)

local t10 = Tabs.Upgrades:CreateToggle("AutoUpgrade", {Title="Auto Upgrade", Default=false})
t10:OnChanged(function(v) AutoUpgrade = v end)

spawn(function()
    while task.wait() do
        if AutoUpgrade and Selected_Upgrade then
            pcall(function()
                for i,v in pairs(UpgradeModule) do
                    if table.find(Selected_Upgrade, i) then
                        CardRemote:FireServer("Upgrade", i)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
end)

--////////////////////////////////////////////////////////
-- SETTINGS
--////////////////////////////////////////////////////////

SaveManager:SetLibrary(lib)
InterfaceManager:SetLibrary(lib)
InterfaceManager:SetFolder("AnimeCardCollection")
SaveManager:SetFolder("AnimeCardCollection/game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

w:SelectTab(1)
SaveManager:LoadAutoloadConfig()
