--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// GUI ROOT
local gui = Instance.new("ScreenGui")
gui.Name = "PremiumHub"
gui.Parent = player:WaitForChild("PlayerGui")

--// MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 750, 0, 450)
main.Position = UDim2.new(0.5,-375,0.5,-225)
main.BackgroundColor3 = Color3.fromRGB(18,18,22)
main.ClipsDescendants = true
Instance.new("UICorner", main)

--// DRAG ANYWHERE
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

--// MINIMISE → FLOAT BUTTON
local minimized = false
local restoreBtn = Instance.new("TextButton", gui)
restoreBtn.Size = UDim2.new(0,120,0,40)
restoreBtn.Position = UDim2.new(0,20,0,200)
restoreBtn.Text = "Open Hub"
restoreBtn.Visible = false
restoreBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0,30,0,30)
minBtn.Position = UDim2.new(1,-35,0,5)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)

minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    restoreBtn.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    restoreBtn.Visible = false
end)

--// SIDEBAR
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0,160,1,0)
sidebar.BackgroundColor3 = Color3.fromRGB(25,25,30)

--// CONTENT
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,160,0,0)
content.Size = UDim2.new(1,-160,1,0)
content.BackgroundTransparency = 1

local tabs = {"AutoFarm","Tower","Grading","Upgrades"}
local pages = {}

-- TAB BUTTON BUILDER
local function createTab(name,order)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1,0,0,50)
    btn.Position = UDim2.new(0,0,0,(order-1)*50)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    btn.TextColor3 = Color3.new(1,1,1)

    local page = Instance.new("Frame", content)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = order==1
    page.BackgroundTransparency = 1
    pages[name] = page

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(45,45,55)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(30,30,35)}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible=false end
        page.Visible=true
    end)
end

for i,v in ipairs(tabs) do
    createTab(v,i)
end

--// TOGGLE SWITCH (PREMIUM)
local function Toggle(parent,text,key,y)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0,300,0,40)
    frame.Position = UDim2.new(0,20,0,y)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,45)

    local label = Instance.new("TextLabel", frame)
    label.Text = text
    label.Size = UDim2.new(0.7,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)

    local toggle = Instance.new("Frame", frame)
    toggle.Size = UDim2.new(0,50,0,24)
    toggle.Position = UDim2.new(1,-60,0.5,-12)
    toggle.BackgroundColor3 = Color3.fromRGB(70,70,80)

    local circle = Instance.new("Frame", toggle)
    circle.Size = UDim2.new(0,20,0,20)
    circle.Position = UDim2.new(0,2,0,2)
    circle.BackgroundColor3 = Color3.new(1,1,1)

    getgenv().State = getgenv().State or {}
    getgenv().State[key] = false

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            getgenv().State[key] = not getgenv().State[key]

            TweenService:Create(circle,TweenInfo.new(0.2),{
                Position = getgenv().State[key] and UDim2.new(1,-22,0,2) or UDim2.new(0,2,0,2)
            }):Play()

            toggle.BackgroundColor3 = getgenv().State[key] and Color3.fromRGB(0,170,120) or Color3.fromRGB(70,70,80)
        end
    end)
end

--// DROPDOWN (REAL)
local function Dropdown(parent,title,list,y)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0,300,0,40)
    frame.Position = UDim2.new(0,350,0,y)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,45)

    local label = Instance.new("TextLabel", frame)
    label.Text = title
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)

    local listFrame = Instance.new("Frame", parent)
    listFrame.Position = UDim2.new(0,350,0,y+40)
    listFrame.Size = UDim2.new(0,300,0,0)
    listFrame.ClipsDescendants = true
    listFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)

    local layout = Instance.new("UIListLayout", listFrame)

    local open=false

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            open = not open
            TweenService:Create(listFrame,TweenInfo.new(0.25),{
                Size = open and UDim2.new(0,300,0,#list*30) or UDim2.new(0,300,0,0)
            }):Play()
        end
    end)

    for _,v in ipairs(list) do
        local btn = Instance.new("TextButton", listFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Text = v
        btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
        btn.TextColor3 = Color3.new(1,1,1)
    end
end

--// UI BUILD
Toggle(pages.AutoFarm,"Auto Collect","AutoCollect",20)
Toggle(pages.AutoFarm,"Auto Tokens","AutoTokens",70)
Toggle(pages.AutoFarm,"Auto Buy","AutoBuy",120)

Dropdown(pages.AutoFarm,"Select Packs",{"Pirate","Dragon","Ninja","Soul"},200)

Toggle(pages.Tower,"Auto Battle","AutoBattle",20)
Toggle(pages.Grading,"Auto Grade","AutoGrade",20)
Toggle(pages.Upgrades,"Auto Upgrade","AutoUpgrade",20)

--// ===== SOURCE2 LOGIC ===== //
local CardRemote = RS.Remotes.Card
local TowerRemote = RS.Remotes.Tower

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