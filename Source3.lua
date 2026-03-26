--// SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

--// UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Anime Card Collection | Xeno Full",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "Full Rebuild",
   ConfigurationSaving = {Enabled = false}
})

local AutoFarmTab = Window:CreateTab("Autofarm", 4483362458)
local TowerTab = Window:CreateTab("Tower", 4483362458)
local GradeTab = Window:CreateTab("Grading", 4483362458)
local UpgradeTab = Window:CreateTab("Upgrades", 4483362458)

--// MODULES
local CardRemote = ReplicatedStorage.Remotes.Card
local TowerRemote = ReplicatedStorage.Remotes.Tower
local GradeRemote = ReplicatedStorage.Remotes.Grade

local CardConfig = require(ReplicatedStorage.Modules.Config.Core.CardConfig)
local TowerConfig = require(ReplicatedStorage.Modules.Config.Core.TowerConfig)
local UpgradeModule = require(ReplicatedStorage.Modules.Config.Core.Upgrades)
local GradeHandler = require(ReplicatedStorage.Client.UI.GradeHandler)
local TowerHandler = require(ReplicatedStorage.Client.UI.TowerHandler)
local CardOpening = require(ReplicatedStorage.Client.UI.CardHandler.CardOpening)

--// HELPERS
local function DataModule()
    return debug.getupvalues(GradeHandler.Init)[1]
end

local function GetPlot()
    return tostring(LocalPlayer:GetAttribute("Plot"))
end

--// GLOBALS
getgenv().Settings = {
    AutoCollect = false,
    AutoTokens = false,
    AutoBuy = false,
    AutoOpen = false,
    AutoBattle = false,
    AutoTrait = false,
    AutoGrade = false,
    AutoUpgrade = false,
    RemoveAnim = false,
    TP = false,

    SelectedPacks = {},
    SelectedRarity = {"All"},
    SelectedTraits = {},
    SelectedCards = {},
    SelectedGrades = {},
    SelectedUpgrades = {}
}

--// UI DATA

-- Packs
local Packs = {}
for _,v in pairs(ReplicatedStorage.Assets.Packs:GetChildren()) do
    table.insert(Packs, v.Name)
end

-- Rarities
local Rarities = {"All","Normal"}
for i,_ in pairs(require(ReplicatedStorage.Modules.Config.Core.PackExchange)) do
    table.insert(Rarities, i)
end

-- Traits
local Traits = {}
for i,_ in pairs(TowerConfig.Traits) do
    table.insert(Traits, i)
end

-- Cards
local function GetCards()
    local list = {"All"}
    for _,pack in pairs(CardConfig.Packs) do
        for name,_ in pairs(pack.List) do
            if not table.find(list, name) then
                table.insert(list, name)
            end
        end
    end
    return list
end

-- Grades
local Grades = {}
for _,v in pairs(require(ReplicatedStorage.Modules.Config.Core.Grades).List) do
    table.insert(Grades, v)
end

-- Upgrades
local Upgrades = {}
for i,_ in pairs(UpgradeModule) do
    table.insert(Upgrades, i)
end

--// UI

-- Autofarm
AutoFarmTab:CreateToggle({Name="Auto Collect",Callback=function(v) getgenv().Settings.AutoCollect=v end})
AutoFarmTab:CreateToggle({Name="Auto Tokens",Callback=function(v) getgenv().Settings.AutoTokens=v end})
AutoFarmTab:CreateToggle({Name="Auto Buy Packs",Callback=function(v) getgenv().Settings.AutoBuy=v end})
AutoFarmTab:CreateToggle({Name="Auto Open Packs",Callback=function(v) getgenv().Settings.AutoOpen=v end})
AutoFarmTab:CreateToggle({Name="Remove Animation",Callback=function(v)
    getgenv().Settings.RemoveAnim=v
    if v then
        CardOpening.OpenCard=function()end
    end
end})

AutoFarmTab:CreateDropdown({
    Name="Packs",
    Options=Packs,
    MultiSelection=true,
    Callback=function(v) getgenv().Settings.SelectedPacks=v end
})

AutoFarmTab:CreateDropdown({
    Name="Rarity",
    Options=Rarities,
    MultiSelection=true,
    Callback=function(v) getgenv().Settings.SelectedRarity=v end
})

-- Tower
if not getgenv().OldTower then
    getgenv().OldTower = TowerHandler.Attack
end

TowerTab:CreateToggle({
    Name="Auto Battle",
    Callback=function(v)
        getgenv().Settings.AutoBattle=v
        if v then
            TowerHandler.Attack=function()
                TowerRemote:FireServer("AttackDone")
            end
        else
            TowerHandler.Attack=getgenv().OldTower
        end
    end
})

TowerTab:CreateToggle({Name="Auto Trait",Callback=function(v) getgenv().Settings.AutoTrait=v end})

TowerTab:CreateDropdown({
    Name="Select Traits",
    Options=Traits,
    MultiSelection=true,
    Callback=function(v) getgenv().Settings.SelectedTraits=v end
})

TowerTab:CreateDropdown({
    Name="Select Cards",
    Options=GetCards(),
    MultiSelection=true,
    Callback=function(v) getgenv().Settings.SelectedCards=v end
})

-- Grading
GradeTab:CreateToggle({Name="Auto Grade",Callback=function(v) getgenv().Settings.AutoGrade=v end})

GradeTab:CreateDropdown({
    Name="Cards",
    Options=GetCards(),
    MultiSelection=true,
    Callback=function(v) getgenv().Settings.SelectedCards=v end
})

GradeTab:CreateDropdown({
    Name="Grades",
    Options=Grades,
    MultiSelection=true,
    Callback=function(v) getgenv().Settings.SelectedGrades=v end
})

-- Upgrades
UpgradeTab:CreateToggle({Name="Auto Upgrade",Callback=function(v) getgenv().Settings.AutoUpgrade=v end})

UpgradeTab:CreateDropdown({
    Name="Upgrades",
    Options=Upgrades,
    MultiSelection=true,
    Callback=function(v) getgenv().Settings.SelectedUpgrades=v end
})

--// LOOPS

task.spawn(function()
    while task.wait() do
        if getgenv().Settings.AutoCollect then
            pcall(function()
                local plot=GetPlot()
                for _,side in pairs({"Left","Right"}) do
                    for _,v in pairs(workspace.Plots[plot].Map.Display[side]:GetChildren()) do
                        CardRemote:FireServer("Collect", v)
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if getgenv().Settings.AutoTokens then
            for _,v in pairs(workspace.Items.Tokens.Server:GetChildren()) do
                v.CFrame=LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if getgenv().Settings.AutoBuy then
            for _,v in pairs(workspace.Client.Packs:GetChildren()) do
                CardRemote:FireServer("BuyPack", v.Name)
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if getgenv().Settings.AutoOpen then
            for _,v in pairs(workspace.Plots[GetPlot()].Packs:GetChildren()) do
                if v:FindFirstChildOfClass("ProximityPrompt") then
                    v.ProximityPrompt:InputHoldBegin()
                    v.ProximityPrompt:InputHoldEnd()
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if getgenv().Settings.AutoBattle then
            if not LocalPlayer.PlayerGui.Tower.Frame.Visible then
                TowerRemote:FireServer("EquipBest")
                TowerRemote:FireServer("StartTower")
            end
            TowerRemote:FireServer("AttackDone")
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if getgenv().Settings.AutoTrait then
            for _,card in pairs(getgenv().Settings.SelectedCards) do
                local data=DataModule().ReplicatedData.GetData("Cards",card)
                if data and not table.find(getgenv().Settings.SelectedTraits,data.Trait) then
                    TowerRemote:FireServer("Roll",card)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if getgenv().Settings.AutoGrade then
            for id,data in pairs(DataModule().ReplicatedData.GetData("Cards")) do
                if data.Grade<10 then
                    GradeRemote:FireServer("Roll",id)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if getgenv().Settings.AutoUpgrade then
            for _,name in pairs(getgenv().Settings.SelectedUpgrades) do
                CardRemote:FireServer("Upgrade",name)
            end
        end
    end
end)

Rayfield:Notify({
   Title="Loaded",
   Content="Full Xeno Script Ready",
   Duration=5
})