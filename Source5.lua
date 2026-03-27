--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "Source2_Rebuilt"

--// GLOBAL STATES
getgenv().AutoBattle = false
getgenv().AutoTrait = false
getgenv().AutoCollect = false
getgenv().AutoCollect_Tokens = false
getgenv().AutoCollect_Potions = false
getgenv().AutoBuy = false
getgenv().AutoOpen = false
getgenv().AutoGrade = false
getgenv().AutoUpgrade = false

--// MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 350)
main.Position = UDim2.new(0.5, -250, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Instance.new("UICorner", main)

--// TABS
local tabs = {"AutoFarm","Tower","Grading","Upgrades"}
local pages = {}

local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.BackgroundTransparency = 1

local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,0,0,40)
content.Size = UDim2.new(1,0,1,-40)
content.BackgroundTransparency = 1

for i,name in ipairs(tabs) do
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.25,0,1,0)
    btn.Position = UDim2.new((i-1)*0.25,0,0,0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)

    local page = Instance.new("Frame", content)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = i == 1
    page.BackgroundTransparency = 1
    pages[name] = page

    btn.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible = false end
        page.Visible = true
    end)
end

--// TOGGLE CREATOR
local function CreateToggle(parent, text, var, y)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,200,0,30)
    btn.Position = UDim2.new(0,10,0,y)
    btn.Text = text.." : OFF"
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)

    btn.MouseButton1Click:Connect(function()
        getgenv()[var] = not getgenv()[var]
        btn.Text = text.." : "..(getgenv()[var] and "ON" or "OFF")
    end)
end

--// AUTO FARM TAB
CreateToggle(pages.AutoFarm,"Auto Collect","AutoCollect",10)
CreateToggle(pages.AutoFarm,"Auto Tokens","AutoCollect_Tokens",50)
CreateToggle(pages.AutoFarm,"Auto Potions","AutoCollect_Potions",90)
CreateToggle(pages.AutoFarm,"Auto Buy Packs","AutoBuy",130)
CreateToggle(pages.AutoFarm,"Auto Open","AutoOpen",170)

--// TOWER TAB
CreateToggle(pages.Tower,"Auto Battle","AutoBattle",10)
CreateToggle(pages.Tower,"Auto Trait","AutoTrait",50)

--// GRADING
CreateToggle(pages.Grading,"Auto Grade","AutoGrade",10)

--// UPGRADES
CreateToggle(pages.Upgrades,"Auto Upgrade","AutoUpgrade",10)

--// ===== SOURCE2 LOGIC (UNCHANGED) ===== --

local CardRemote = RS.Remotes.Card

local function GetPlot()
    return tostring(player:GetAttribute("Plot"))
end

-- AUTO COLLECT
spawn(function()
    while task.wait() do
        if getgenv().AutoCollect then
            pcall(function()
                for _,v in pairs(workspace.Plots:GetChildren()) do
                    for _,side in pairs(v.Map.Display:GetChildren()) do
                        if side.Name == "Left" or side.Name == "Right" then
                            for _,card in pairs(side:GetChildren()) do
                                CardRemote:FireServer("Collect", card)
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
        if getgenv().AutoCollect_Tokens then
            pcall(function()
                for _,v in pairs(workspace.Items.Tokens.Server:GetChildren()) do
                    v.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end)

-- AUTO POTIONS
spawn(function()
    while task.wait() do
        if getgenv().AutoCollect_Potions then
            pcall(function()
                for _,v in pairs(workspace.Items.Misc.Collectables:GetChildren()) do
                    v.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end)

-- AUTO BATTLE
spawn(function()
    while task.wait() do
        if getgenv().AutoBattle then
            pcall(function()
                RS.Remotes.Tower:FireServer("EquipBest")
                task.wait(.2)
                RS.Remotes.Tower:FireServer("StartTower")
            end)
        end
    end
end)

-- AUTO BUY
spawn(function()
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

-- AUTO OPEN
spawn(function()
    while task.wait() do
        if getgenv().AutoOpen then
            pcall(function()
                for _,v in pairs(workspace.Plots[GetPlot()].Packs:GetChildren()) do
                    for _,p in pairs(v:GetChildren()) do
                        if p:FindFirstChildOfClass("ProximityPrompt") then
                            fireproximityprompt(p.ProximityPrompt)
                        end
                    end
                end
            end)
        end
    end
end)

-- AUTO GRADE
spawn(function()
    while task.wait() do
        if getgenv().AutoGrade then
            pcall(function()
                RS.Remotes.Grade:FireServer("Roll","All")
            end)
        end
    end
end)

-- AUTO UPGRADE
spawn(function()
    while task.wait() do
        if getgenv().AutoUpgrade then
            pcall(function()
                RS.Remotes.Card:FireServer("Upgrade","All")
            end)
        end
    end
end)