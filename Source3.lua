--// SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

--// UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Anime Card Collection | Exact Port",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "Full Script",
   ConfigurationSaving = {Enabled = false}
})

local AutoFarm = Window:CreateTab("Autofarm", 4483362458)
local TowerTab = Window:CreateTab("Tower", 4483362458)
local GradingTab = Window:CreateTab("Grading", 4483362458)
local UpgradeTab = Window:CreateTab("Upgrades", 4483362458)

--// MODULES
local CardRemote = ReplicatedStorage.Remotes.Card
local TowerRemote = ReplicatedStorage.Remotes.Tower
local GradeRemote = ReplicatedStorage.Remotes.Grade

local CardConfigModule = require(ReplicatedStorage.Modules.Config.Core.CardConfig)
local TowerConfig = require(ReplicatedStorage.Modules.Config.Core.TowerConfig)
local GradeHandler = require(ReplicatedStorage.Client.UI.GradeHandler)
local TowerHandler = require(ReplicatedStorage.Client.UI.TowerHandler)
local CardOpening = require(ReplicatedStorage.Client.UI.CardHandler.CardOpening)
local UpgradeModule = require(ReplicatedStorage.Modules.Config.Core.Upgrades)

--// HELPERS
function DataModule()
    return debug.getupvalues(GradeHandler.Init)[1]
end

function GetPlot()
    return tostring(LocalPlayer:GetAttribute("Plot"))
end

--// GLOBALS
getgenv().AutoCollect = false
getgenv().AutoCollect_Tokens = false
getgenv().AutoCollect_Potions = false
getgenv().AutoBuy = false
getgenv().AutoOpen = false
getgenv().AutoBattle = false
getgenv().AutoTrait = false
getgenv().AutoGrade = false
getgenv().AutoUpgrade = false
getgenv().PacksTp = false
getgenv().RemoveOpeningAnimation = false

getgenv().Selected_Pack = {}
getgenv().Selected_Rarities = {"All"}
getgenv().TraitCard = {}
getgenv().Selected_Traits = {}
getgenv().Selected_Card = {}
getgenv().Selected_Grade = {}
getgenv().Selected_Upgrades = {}

--// DATA

local Packs = {}
for _,v in pairs(ReplicatedStorage.Assets.Packs:GetChildren()) do
    table.insert(Packs, v.Name)
end

local Rarities = {"All","Normal"}
for i,_ in pairs(require(ReplicatedStorage.Modules.Config.Core.PackExchange)) do
    table.insert(Rarities, i)
end

local Traits = {}
for i,_ in pairs(TowerConfig.Traits) do
    table.insert(Traits, i)
end

local function Cards()
    local list = {"All"}
    for _,pack in pairs(CardConfigModule.Packs) do
        for name,_ in pairs(pack.List) do
            if not table.find(list,name) then
                table.insert(list,name)
            end
        end
    end
    return list
end

local Gradings = {}
for _,v in pairs(require(ReplicatedStorage.Modules.Config.Core.Grades).List) do
    table.insert(Gradings, v)
end

local Upgrades = {}
for i,_ in pairs(UpgradeModule) do
    table.insert(Upgrades, i)
end

--// UI

AutoFarm:CreateToggle({Name="Auto Collect",Callback=function(v) getgenv().AutoCollect=v end})
AutoFarm:CreateToggle({Name="Auto Tokens",Callback=function(v) getgenv().AutoCollect_Tokens=v end})
AutoFarm:CreateToggle({Name="Auto Potions",Callback=function(v) getgenv().AutoCollect_Potions=v end})
AutoFarm:CreateToggle({Name="Auto Buy Packs",Callback=function(v) getgenv().AutoBuy=v end})
AutoFarm:CreateToggle({Name="Auto Open Packs",Callback=function(v) getgenv().AutoOpen=v end})
AutoFarm:CreateToggle({Name="Allow TP",Callback=function(v) getgenv().PacksTp=v end})

AutoFarm:CreateDropdown({Name="Packs",Options=Packs,MultiSelection=true,Callback=function(v) getgenv().Selected_Pack=v end})
AutoFarm:CreateDropdown({Name="Rarity",Options=Rarities,MultiSelection=true,Callback=function(v) getgenv().Selected_Rarities=v end})

TowerTab:CreateToggle({Name="Auto Battle",Callback=function(v)
    getgenv().AutoBattle=v
    if v then
        TowerHandler.Attack=function() TowerRemote:FireServer("AttackDone") end
    else
        TowerHandler.Attack=getgenv().FastTower
    end
end})

TowerTab:CreateToggle({Name="Auto Trait",Callback=function(v) getgenv().AutoTrait=v end})
TowerTab:CreateDropdown({Name="Cards",Options=Cards(),MultiSelection=true,Callback=function(v) getgenv().TraitCard=v end})
TowerTab:CreateDropdown({Name="Traits",Options=Traits,MultiSelection=true,Callback=function(v) getgenv().Selected_Traits=v end})

GradingTab:CreateToggle({Name="Auto Grade",Callback=function(v) getgenv().AutoGrade=v end})
GradingTab:CreateDropdown({Name="Cards",Options=Cards(),MultiSelection=true,Callback=function(v) getgenv().Selected_Card=v end})
GradingTab:CreateDropdown({Name="Grades",Options=Gradings,MultiSelection=true,Callback=function(v) getgenv().Selected_Grade=v end})

UpgradeTab:CreateToggle({Name="Auto Upgrade",Callback=function(v) getgenv().AutoUpgrade=v end})
UpgradeTab:CreateDropdown({Name="Upgrades",Options=Upgrades,MultiSelection=true,Callback=function(v) getgenv().Selected_Upgrades=v end})

--// LOGIC (EXACT PORT STYLE)

-- Collect
task.spawn(function()
    while task.wait() do
        if getgenv().AutoCollect then
            for _,v in pairs(workspace.Plots:GetChildren()) do
                for _,side in pairs({"Left","Right"}) do
                    for _,card in pairs(v.Map.Display[side]:GetChildren()) do
                        CardRemote:FireServer("Collect", card)
                    end
                end
            end
        end
    end
end)

-- Page Flip
task.spawn(function()
    local Page,Flip=1,false
    while task.wait() do
        if getgenv().AutoCollect then
            if Page>=12 then Page=0 Flip=not Flip end
            CardRemote:FireServer("Page",Flip and "LeftArrow" or "RightArrow")
            Page+=1
        end
    end
end)

-- Tokens
task.spawn(function()
    while task.wait() do
        if getgenv().AutoCollect_Tokens then
            for _,v in pairs(workspace.Items.Tokens.Server:GetChildren()) do
                v.CFrame=LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

-- Potions
task.spawn(function()
    while task.wait() do
        if getgenv().AutoCollect_Potions then
            for _,v in pairs(workspace.Items.Misc.Collectables:GetChildren()) do
                v.CFrame=LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

-- Buy Packs (SMART)
task.spawn(function()
    while task.wait() do
        if getgenv().AutoBuy then
            for _,v in pairs(workspace.Client.Packs:GetChildren()) do
                if table.find(getgenv().Selected_Pack,v.Name) then
                    CardRemote:FireServer("BuyPack",v.Name)
                end
            end
        end
    end
end)

-- Open Packs (TP INCLUDED)
task.spawn(function()
    while task.wait() do
        if getgenv().AutoOpen then
            for _,v in pairs(workspace.Plots[GetPlot()].Packs:GetChildren()) do
                for _,p in pairs(v:GetChildren()) do
                    if p:FindFirstChildOfClass("ProximityPrompt") then
                        if getgenv().PacksTp then
                            local old=LocalPlayer.Character.HumanoidRootPart.CFrame
                            LocalPlayer.Character.HumanoidRootPart.CFrame=p.CFrame
                            task.wait(.1)
                            p.ProximityPrompt:InputHoldBegin()
                            p.ProximityPrompt:InputHoldEnd()
                            LocalPlayer.Character.HumanoidRootPart.CFrame=old
                        else
                            p.ProximityPrompt:InputHoldBegin()
                            p.ProximityPrompt:InputHoldEnd()
                        end
                    end
                end
            end
        end
    end
end)

-- Battle Loop
task.spawn(function()
    while task.wait(.5) do
        if getgenv().AutoBattle then
            if not LocalPlayer.PlayerGui.Tower.Frame.Visible then
                TowerRemote:FireServer("EquipBest")
                TowerRemote:FireServer("StartTower")
            end
            TowerRemote:FireServer("AttackDone")
        end
    end
end)

-- Trait Roll
task.spawn(function()
    while task.wait(.1) do
        if getgenv().AutoTrait then
            for _,v in pairs(getgenv().TraitCard) do
                local data=DataModule().ReplicatedData.GetData("Cards",v)
                if data and not table.find(getgenv().Selected_Traits,data.Trait) then
                    TowerRemote:FireServer("Roll",v)
                end
            end
        end
    end
end)

-- Grade
task.spawn(function()
    while task.wait() do
        if getgenv().AutoGrade then
            for i,v in pairs(DataModule().ReplicatedData.GetData("Cards")) do
                if not table.find(getgenv().Selected_Grade,v.Grade) then
                    GradeRemote:FireServer("Roll",i)
                end
            end
        end
    end
end)

-- Upgrade
task.spawn(function()
    while task.wait() do
        if getgenv().AutoUpgrade then
            for _,v in pairs(getgenv().Selected_Upgrades) do
                CardRemote:FireServer("Upgrade",v)
            end
        end
    end
end)

Rayfield:Notify({
   Title="Loaded",
   Content="Exact Port Running (Xeno Safe)",
   Duration=5
})