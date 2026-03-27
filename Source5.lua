--// SERVICES
local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')

local player = Players.LocalPlayer
local playerGui = player:WaitForChild('PlayerGui')

--// GUI
local gui = Instance.new('ScreenGui', playerGui)
gui.Name = 'AnimeHub'
gui.ResetOnSpawn = false

--// MAIN FRAME
local frame = Instance.new('Frame', gui)
frame.Size = UDim2.new(0, 320, 0, 400)
frame.Position = UDim2.new(0.5, -160, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0

Instance.new("UICorner", frame)

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Text = "Anime Card Collection"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

--// BUTTON CREATOR
local function createToggle(text, posY, varName)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1,-20,0,35)
    btn.Position = UDim2.new(0,10,0,posY)
    btn.Text = text.." : OFF"
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn)

    getgenv()[varName] = false

    btn.MouseButton1Click:Connect(function()
        getgenv()[varName] = not getgenv()[varName]
        btn.Text = text.." : "..(getgenv()[varName] and "ON" or "OFF")
    end)
end

--// TOGGLES
createToggle("Auto Collect", 50, "AutoCollect")
createToggle("Auto Tokens", 90, "AutoTokens")
createToggle("Auto Buy Packs", 130, "AutoBuy")
createToggle("Auto Open Packs", 170, "AutoOpen")
createToggle("Auto Battle", 210, "AutoBattle")
createToggle("Auto Trait", 250, "AutoTrait")
createToggle("Auto Grade", 290, "AutoGrade")
createToggle("Auto Upgrade", 330, "AutoUpgrade")

--// MODULES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CardRemote = ReplicatedStorage.Remotes.Card
local TowerRemote = ReplicatedStorage.Remotes.Tower
local GradeRemote = ReplicatedStorage.Remotes.Grade

local CardConfig = require(ReplicatedStorage.Modules.Config.Core.CardConfig)
local TowerConfig = require(ReplicatedStorage.Modules.Config.Core.TowerConfig)
local GradeHandler = require(ReplicatedStorage.Client.UI.GradeHandler)

local function DataModule()
    return debug.getupvalues(GradeHandler.Init)[1]
end

local function GetPlot()
    return tostring(player:GetAttribute("Plot"))
end

--// AUTO COLLECT
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

--// TOKENS
task.spawn(function()
    while task.wait() do
        if getgenv().AutoTokens then
            for _,v in pairs(workspace.Items.Tokens.Server:GetChildren()) do
                v.CFrame = player.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

--// BUY PACKS
task.spawn(function()
    while task.wait() do
        if getgenv().AutoBuy then
            for _,v in pairs(workspace.Client.Packs:GetChildren()) do
                CardRemote:FireServer("BuyPack", v.Name)
            end
        end
    end
end)

--// OPEN PACKS
task.spawn(function()
    while task.wait() do
        if getgenv().AutoOpen then
            for _,v in pairs(workspace.Plots[GetPlot()].Packs:GetChildren()) do
                for _,p in pairs(v:GetChildren()) do
                    if p:FindFirstChildOfClass("ProximityPrompt") then
                        p.ProximityPrompt:InputHoldBegin()
                        p.ProximityPrompt:InputHoldEnd()
                    end
                end
            end
        end
    end
end)

--// BATTLE
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoBattle then
            TowerRemote:FireServer("EquipBest")
            TowerRemote:FireServer("StartTower")
            TowerRemote:FireServer("AttackDone")
        end
    end
end)

--// TRAITS
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().AutoTrait then
            for name,_ in pairs(DataModule().ReplicatedData.GetData("Cards")) do
                TowerRemote:FireServer("Roll", name)
            end
        end
    end
end)

--// GRADING
task.spawn(function()
    while task.wait() do
        if getgenv().AutoGrade then
            for id,data in pairs(DataModule().ReplicatedData.GetData("Cards")) do
                if data.Grade < 10 then
                    GradeRemote:FireServer("Roll", id)
                end
            end
        end
    end
end)

--// UPGRADES
task.spawn(function()
    while task.wait() do
        if getgenv().AutoUpgrade then
            for name,_ in pairs(require(ReplicatedStorage.Modules.Config.Core.Upgrades)) do
                CardRemote:FireServer("Upgrade", name)
            end
        end
    end
end)

print("✅ FULL UI + SCRIPT LOADED")