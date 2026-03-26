-- // Services // --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // UI (Rayfield) // --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Anime Card Collection | Xeno Edition",
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "Full Version",
   ConfigurationSaving = { Enabled = false }
})

-- // Tabs // --
local MainTab = Window:CreateTab("Autofarm", 4483362458)
local TowerTab = Window:CreateTab("Tower", 4483362458)
local GradeTab = Window:CreateTab("Grading", 4483362458)
local UpgradeTab = Window:CreateTab("Upgrades", 4483362458)

-- // Modules // --
local CardRemote = ReplicatedStorage.Remotes.Card
local TowerRemote = ReplicatedStorage.Remotes.Tower
local GradeRemote = ReplicatedStorage.Remotes.Grade

local CardConfig = require(ReplicatedStorage.Modules.Config.Core.CardConfig)
local TowerConfig = require(ReplicatedStorage.Modules.Config.Core.TowerConfig)
local GradeHandler = require(ReplicatedStorage.Client.UI.GradeHandler)
local TowerHandler = require(ReplicatedStorage.Client.UI.TowerHandler)
local CardOpening = require(ReplicatedStorage.Client.UI.CardHandler.CardOpening)

local function DataModule()
    return debug.getupvalues(GradeHandler.Init)[1]
end

local function GetPlot()
    return tostring(LocalPlayer:GetAttribute("Plot"))
end

-- // GLOBALS // --
getgenv().AutoCollect = false
getgenv().AutoCollect_Tokens = false
getgenv().AutoBattle = false
getgenv().AutoBuy = false
getgenv().AutoOpen = false
getgenv().AutoGrade = false
getgenv().AutoUpgrade = false
getgenv().AutoTrait = false

-- // AUTOFARM UI // --
MainTab:CreateToggle({
   Name = "Auto Collect Cards",
   CurrentValue = false,
   Callback = function(v) getgenv().AutoCollect = v end
})

MainTab:CreateToggle({
   Name = "Auto Collect Tokens",
   CurrentValue = false,
   Callback = function(v) getgenv().AutoCollect_Tokens = v end
})

MainTab:CreateToggle({
   Name = "Auto Buy Packs",
   CurrentValue = false,
   Callback = function(v) getgenv().AutoBuy = v end
})

MainTab:CreateToggle({
   Name = "Auto Open Packs",
   CurrentValue = false,
   Callback = function(v) getgenv().AutoOpen = v end
})

-- // TOWER UI // --
if not getgenv().OldTower then
    getgenv().OldTower = TowerHandler.Attack
end

TowerTab:CreateToggle({
   Name = "Auto Battle",
   CurrentValue = false,
   Callback = function(v)
       getgenv().AutoBattle = v
       if v then
           TowerHandler.Attack = function()
               TowerRemote:FireServer("AttackDone")
           end
       else
           TowerHandler.Attack = getgenv().OldTower
       end
   end
})

-- // GRADING UI // --
GradeTab:CreateToggle({
   Name = "Auto Grade",
   CurrentValue = false,
   Callback = function(v) getgenv().AutoGrade = v end
})

-- // UPGRADES UI // --
UpgradeTab:CreateToggle({
   Name = "Auto Upgrade",
   CurrentValue = false,
   Callback = function(v) getgenv().AutoUpgrade = v end
})

-- // LOOPS // --

-- Auto Collect
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoCollect then
            pcall(function()
                local plot = GetPlot()
                for _,side in pairs({"Left","Right"}) do
                    for _,card in pairs(workspace.Plots[plot].Map.Display[side]:GetChildren()) do
                        CardRemote:FireServer("Collect", card)
                    end
                end
            end)
        end
    end
end)

-- Page Flip
task.spawn(function()
    local flip = false
    while task.wait(0.1) do
        if getgenv().AutoCollect then
            flip = not flip
            CardRemote:FireServer("Page", flip and "LeftArrow" or "RightArrow")
        end
    end
end)

-- Tokens
task.spawn(function()
    while task.wait() do
        if getgenv().AutoCollect_Tokens then
            pcall(function()
                for _,v in pairs(workspace.Items.Tokens.Server:GetChildren()) do
                    v.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end)

-- Auto Buy Packs
task.spawn(function()
    while task.wait() do
        if getgenv().AutoBuy then
            pcall(function()
                for _,v in pairs(workspace.Client.Packs:GetChildren()) do
                    CardRemote:FireServer("BuyPack", v.Name)
                end
            end)
        end
    end
end)

-- Auto Open Packs
task.spawn(function()
    while task.wait() do
        if getgenv().AutoOpen then
            pcall(function()
                for _,v in pairs(workspace.Plots[GetPlot()].Packs:GetChildren()) do
                    if v:FindFirstChildOfClass("ProximityPrompt") then
                        v.ProximityPrompt:InputHoldBegin()
                        v.ProximityPrompt:InputHoldEnd()
                    end
                end
            end)
        end
    end
end)

-- Auto Battle Loop
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoBattle then
            pcall(function()
                if not LocalPlayer.PlayerGui.Tower.Frame.Visible then
                    TowerRemote:FireServer("EquipBest")
                    TowerRemote:FireServer("StartTower")
                end
                TowerRemote:FireServer("AttackDone")
            end)
        end
    end
end)

-- Auto Grade
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoGrade then
            pcall(function()
                for id, data in pairs(DataModule().ReplicatedData.GetData("Cards")) do
                    if data.Grade < 10 then
                        GradeRemote:FireServer("Roll", id)
                    end
                end
            end)
        end
    end
end)

-- Auto Upgrade
task.spawn(function()
    local UpgradeModule = require(ReplicatedStorage.Modules.Config.Core.Upgrades)
    while task.wait() do
        if getgenv().AutoUpgrade then
            for name,_ in pairs(UpgradeModule) do
                CardRemote:FireServer("Upgrade", name)
                task.wait(0.1)
            end
        end
    end
end)

Rayfield:Notify({
   Title = "Loaded",
   Content = "Full script working on Xeno",
   Duration = 5
})