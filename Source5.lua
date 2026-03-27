--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AdvancedHub"

--// GLOBALS
getgenv().States = {
    AutoBattle = false,
    AutoTrait = false,
    AutoCollect = false,
    AutoTokens = false,
    AutoPotions = false,
    AutoBuy = false,
    AutoOpen = false,
    AutoGrade = false,
    AutoUpgrade = false,
    RemoveAnim = false,
    AllowTP = false
}

--// MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 600, 0, 400)
main.Position = UDim2.new(0.5,-300,0.5,-200)
main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Instance.new("UICorner", main)

-- DRAG SYSTEM
local dragging, dragStart, startPos

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- MINIMISE
local minimized = false
local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0,30,0,30)
minBtn.Position = UDim2.new(1,-35,0,5)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    main.Size = minimized and UDim2.new(0,600,0,40) or UDim2.new(0,600,0,400)
end)

-- TABS
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.BackgroundColor3 = Color3.fromRGB(30,30,35)

local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,0,0,40)
content.Size = UDim2.new(1,0,1,-40)
content.BackgroundTransparency = 1

local tabs = {"AutoFarm","Tower","Grading","Upgrades"}
local pages = {}

for i,name in ipairs(tabs) do
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0,150,1,0)
    btn.Position = UDim2.new(0,(i-1)*150,0,0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50,50,60)
    btn.TextColor3 = Color3.new(1,1,1)

    local page = Instance.new("Frame", content)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = i==1
    page.BackgroundTransparency = 1
    pages[name] = page

    btn.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible=false end
        page.Visible=true
    end)
end

-- TOGGLE BUILDER
local function Toggle(parent,text,key,y)
    local b = Instance.new("TextButton",parent)
    b.Size = UDim2.new(0,220,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = text.." : OFF"
    b.BackgroundColor3 = Color3.fromRGB(70,70,80)

    b.MouseButton1Click:Connect(function()
        getgenv().States[key] = not getgenv().States[key]
        b.Text = text.." : "..(getgenv().States[key] and "ON" or "OFF")
    end)
end

-- AUTO FARM UI
Toggle(pages.AutoFarm,"Auto Collect","AutoCollect",10)
Toggle(pages.AutoFarm,"Auto Tokens","AutoTokens",50)
Toggle(pages.AutoFarm,"Auto Potions","AutoPotions",90)
Toggle(pages.AutoFarm,"Auto Buy","AutoBuy",130)
Toggle(pages.AutoFarm,"Auto Open","AutoOpen",170)

-- TOWER
Toggle(pages.Tower,"Auto Battle","AutoBattle",10)
Toggle(pages.Tower,"Auto Trait","AutoTrait",50)

-- GRADING
Toggle(pages.Grading,"Auto Grade","AutoGrade",10)

-- UPGRADES
Toggle(pages.Upgrades,"Auto Upgrade","AutoUpgrade",10)

--// ==== FULL ORIGINAL LOGIC RESTORED ==== //

local CardRemote = RS.Remotes.Card
local TowerRemote = RS.Remotes.Tower

local function GetPlot()
    return tostring(player:GetAttribute("Plot"))
end

-- AUTO COLLECT
spawn(function()
    while task.wait() do
        if getgenv().States.AutoCollect then
            pcall(function()
                for _,v in pairs(workspace.Plots:GetChildren()) do
                    for _,side in pairs(v.Map.Display:GetChildren()) do
                        if side.Name=="Left" or side.Name=="Right" then
                            for _,card in pairs(side:GetChildren()) do
                                CardRemote:FireServer("Collect",card)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- AUTO TOKENS
spawn(function()
    while task.wait() do
        if getgenv().States.AutoTokens then
            for _,v in pairs(workspace.Items.Tokens.Server:GetChildren()) do
                v.CFrame = player.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

-- AUTO POTIONS
spawn(function()
    while task.wait() do
        if getgenv().States.AutoPotions then
            for _,v in pairs(workspace.Items.Misc.Collectables:GetChildren()) do
                v.CFrame = player.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

-- AUTO BATTLE
spawn(function()
    while task.wait() do
        if getgenv().States.AutoBattle then
            TowerRemote:FireServer("EquipBest")
            task.wait(.2)
            TowerRemote:FireServer("StartTower")
        end
    end
end)