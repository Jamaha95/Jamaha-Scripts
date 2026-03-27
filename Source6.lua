--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "Source2_Advanced"

--// GLOBAL STATE
getgenv().State = {
    AutoBattle=false, AutoTrait=false,
    AutoCollect=false, AutoTokens=false, AutoPotions=false,
    AutoBuy=false, AutoOpen=false,
    AutoGrade=false, AutoUpgrade=false,
    RemoveAnim=false, AllowTP=false
}

getgenv().Selections = {
    Cards={}, Traits={}, Packs={}, Rarities={}
}

--// MAIN UI
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,650,0,420)
main.Position = UDim2.new(0.5,-325,0.5,-210)
main.BackgroundColor3 = Color3.fromRGB(18,18,22)
Instance.new("UICorner", main)

-- DRAG
local drag=false; local start; local pos
main.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true; start=i.Position; pos=main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-start
        main.Position=UDim2.new(pos.X.Scale,pos.X.Offset+d.X,pos.Y.Scale,pos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)

-- MINIMISE
local min=false
local minBtn=Instance.new("TextButton",main)
minBtn.Size=UDim2.new(0,30,0,30)
minBtn.Position=UDim2.new(1,-35,0,5)
minBtn.Text="-"
minBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
minBtn.TextColor3=Color3.new(1,1,1)

minBtn.MouseButton1Click:Connect(function()
    min=not min
    main.Size=min and UDim2.new(0,650,0,40) or UDim2.new(0,650,0,420)
end)

-- TABS
local tabs={"AutoFarm","Tower","Grading","Upgrades"}
local pages={}
local tabBar=Instance.new("Frame",main)
tabBar.Size=UDim2.new(1,0,0,40)
tabBar.BackgroundColor3=Color3.fromRGB(30,30,35)

local content=Instance.new("Frame",main)
content.Position=UDim2.new(0,0,0,40)
content.Size=UDim2.new(1,0,1,-40)
content.BackgroundTransparency=1

for i,name in ipairs(tabs) do
    local b=Instance.new("TextButton",tabBar)
    b.Size=UDim2.new(0,160,1,0)
    b.Position=UDim2.new(0,(i-1)*160,0,0)
    b.Text=name
    b.TextColor3=Color3.new(1,1,1)
    b.BackgroundColor3=Color3.fromRGB(50,50,60)

    local p=Instance.new("ScrollingFrame",content)
    p.Size=UDim2.new(1,0,1,0)
    p.CanvasSize=UDim2.new(0,0,0,800)
    p.Visible=i==1
    p.BackgroundTransparency=1
    pages[name]=p

    b.MouseButton1Click:Connect(function()
        for _,v in pairs(pages) do v.Visible=false end
        p.Visible=true
    end)
end

-- TOGGLE
local function Toggle(parent,text,key,y)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(0,250,0,32)
    b.Position=UDim2.new(0,10,0,y)
    b.Text=text.." : OFF"
    b.BackgroundColor3=Color3.fromRGB(70,70,85)
    b.TextColor3=Color3.new(1,1,1)

    b.MouseButton1Click:Connect(function()
        getgenv().State[key]=not getgenv().State[key]
        b.Text=text.." : "..(getgenv().State[key] and "ON" or "OFF")
    end)
end

-- CHECKLIST SYSTEM
local function Checklist(parent,title,list,store,y)
    local label=Instance.new("TextLabel",parent)
    label.Text=title
    label.Position=UDim2.new(0,300,0,y)
    label.Size=UDim2.new(0,200,0,25)
    label.TextColor3=Color3.new(1,1,1)
    label.BackgroundTransparency=1

    local box=Instance.new("Frame",parent)
    box.Position=UDim2.new(0,300,0,y+25)
    box.Size=UDim2.new(0,250,0,120)
    box.BackgroundColor3=Color3.fromRGB(40,40,50)

    local layout=Instance.new("UIListLayout",box)

    for _,item in ipairs(list) do
        local btn=Instance.new("TextButton",box)
        btn.Text=item
        btn.Size=UDim2.new(1,0,0,25)
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        btn.TextColor3=Color3.new(1,1,1)

        btn.MouseButton1Click:Connect(function()
            if table.find(getgenv().Selections[store],item) then
                table.remove(getgenv().Selections[store],table.find(getgenv().Selections[store],item))
                btn.BackgroundColor3=Color3.fromRGB(60,60,70)
            else
                table.insert(getgenv().Selections[store],item)
                btn.BackgroundColor3=Color3.fromRGB(0,170,120)
            end
        end)
    end
end

--// SAMPLE DATA (auto-filled from game)
local Packs={}
for _,v in pairs(RS.Assets.Packs:GetChildren()) do table.insert(Packs,v.Name) end

local Rarities={"All","Normal","Rare","Epic","Legendary"}

--// AUTO FARM UI
Toggle(pages.AutoFarm,"Auto Collect","AutoCollect",10)
Toggle(pages.AutoFarm,"Auto Tokens","AutoTokens",50)
Toggle(pages.AutoFarm,"Auto Potions","AutoPotions",90)
Toggle(pages.AutoFarm,"Auto Buy","AutoBuy",130)
Toggle(pages.AutoFarm,"Auto Open","AutoOpen",170)

Checklist(pages.AutoFarm,"Packs",Packs,"Packs",210)
Checklist(pages.AutoFarm,"Rarities",Rarities,"Rarities",350)

--// TOWER
Toggle(pages.Tower,"Auto Battle","AutoBattle",10)
Toggle(pages.Tower,"Auto Trait","AutoTrait",50)

--// GRADING
Toggle(pages.Grading,"Auto Grade","AutoGrade",10)

--// UPGRADES
Toggle(pages.Upgrades,"Auto Upgrade","AutoUpgrade",10)

--// ===== FULL SOURCE2 LOGIC ===== //

local CardRemote=RS.Remotes.Card
local TowerRemote=RS.Remotes.Tower

local function GetPlot()
    return tostring(player:GetAttribute("Plot"))
end

spawn(function()
    while task.wait() do
        if getgenv().State.AutoCollect then
            for _,v in pairs(workspace.Plots:GetChildren()) do
                for _,side in pairs(v.Map.Display:GetChildren()) do
                    for _,card in pairs(side:GetChildren()) do
                        CardRemote:FireServer("Collect",card)
                    end
                end
            end
        end
    end
end)

spawn(function()
    while task.wait() do
        if getgenv().State.AutoTokens then
            for _,v in pairs(workspace.Items.Tokens.Server:GetChildren()) do
                v.CFrame=player.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

spawn(function()
    while task.wait() do
        if getgenv().State.AutoBuy then
            for _,v in pairs(workspace.Client.Packs:GetChildren()) do
                if table.find(getgenv().Selections.Packs,v.Name) then
                    CardRemote:FireServer("BuyPack",v.Name)
                end
            end
        end
    end
end)