------------ // Anime Card Collection \\ ------------

------------------------------------------------------------
--/////////////////////////GUI\\\\\\\\\\\\\\\\\\\\\\\\\\\\--
------------------------------------------------------------ 

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
	if isNegative then
		value = value:sub(2)
	end

    local numberPart, suffix = value:match("^([%d%.]+)([a-zA-Z]*)$")
	if not numberPart then
		return tonumber(value) or 0
	end

	local number = tonumber(numberPart)
	if not number then
		return 0
	end

	suffix = suffix:lower()
	local index = suffixLookup[suffix]

	if not index then
		return isNegative and -number or number
	end

	local multiplier = 10^(3 * (index - 1))
	local result = number * multiplier

	return isNegative and -result or result
end

print(Conversions.BigNumToNumber("$1.1K"))
print(Conversions.BigNumToNumber("-$5M"))
print(Conversions.BigNumToNumber("$1,200K"))
print(Conversions.BigNumToNumber("1k"))

local UtilityModule = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Mana-scripts/Neverlose-UI/refs/heads/main/Utility.lua"))()

UtilityModule:Discord("7wZ7vEgWXR")


local Library = UtilityModule.Library() --loadstring(game:HttpGetAsync("https://rawscripts.net/raw/Universal-Script-woof-gui-16777"))()

local Window = Library:Window(
    UtilityModule.HubName,
    "Anime Card Collection",
    UtilityModule.Loader
)

local AutoFarm = Window:Tab("Autofarm")
AutoFarm:Label(" ")

local GradingTab = Window:Tab("Grading")
GradingTab:Label(" ")

local UpgradeTab = Window:Tab("Upgrades")
UpgradeTab:Label(" ")

local TowerTab = Window:Tab("Tower")
TowerTab:Label(" ")

local TweenService = game:GetService("TweenService")
local CardRemote = game:GetService("ReplicatedStorage").Remotes.Card
local CardConfigModule = require(game:GetService("ReplicatedStorage").Modules.Config.Core.CardConfig)
local CardOpening = require(game:GetService("ReplicatedStorage").Client.UI.CardHandler.CardOpening)
local TowerHandler = require(game:GetService("ReplicatedStorage").Client.UI.TowerHandler)
local TowerConfig = require(game:GetService("ReplicatedStorage").Modules.Config.Core.TowerConfig)
local GradeHandler = require(game:GetService("ReplicatedStorage").Client.UI.GradeHandler)

function DataModule()
    return debug.getupvalues(GradeHandler.Init)[1] -- ReplicatedData.ReplicatedData
end

function GetPlot()
    return tostring(game.Players.LocalPlayer:GetAttribute("Plot"))
end

if not getgenv().OldOpeningAnimation then
    getgenv().OldOpeningAnimation = CardOpening.OpenCard
end

if not getgenv().FastTower then
    getgenv().FastTower = TowerHandler.Attack
    getgenv().UpdateFasterTower = TowerHandler.UpdateFasterTower
end

TowerHandler.UpdateFasterTower = function() return end

TowerTab:Toggle("Auto Battle", false, function(t)
    AutoBattle = t
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
            v2:Create(v15.Player, TweenInfo.new(v83, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                ["Position"] = UDim2.fromScale(0.4, 0.529)
            }):Play()
            v2:Create(v15.Enemy, TweenInfo.new(v83, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                ["Position"] = UDim2.fromScale(0.6, 0.529)
            }):Play()
            task.wait(v83)
            v15.Player.Whiteout.BackgroundTransparency = 0
            v15.Enemy.Whiteout.BackgroundTransparency = 0
            v15.Player.Whiteout.Visible = true
            v15.Enemy.Whiteout.Visible = true
            v2:Create(v15.Player.Whiteout, TweenInfo.new(v84, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                ["BackgroundTransparency"] = 1
            }):Play()
            v2:Create(v15.Enemy.Whiteout, TweenInfo.new(v84, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                ["BackgroundTransparency"] = 1
            }):Play()
            v2:Create(v15.Player, TweenInfo.new(v84, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                ["Position"] = UDim2.fromScale(0.3, 0.529)
            }):Play()
            v2:Create(v15.Enemy, TweenInfo.new(v84, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                ["Position"] = UDim2.fromScale(0.7, 0.529)
            }):Play()
            if v25 ~= true then
                v3.Assets.Sounds.Tower.Clash:Play()
            end
            task.wait(v84)
            v15.Player.Whiteout.Visible = false
            v15.Enemy.Whiteout.Visible = false
            v15.Player.Health.Bar.Size = UDim2.fromScale(v90, 1)
            v15.Enemy.Health.Bar.Size = UDim2.fromScale(v92, 1)
            local v93 = v8.Conversions.Abbreviate(math.max(v87, 0), 2)
            local v94 = v8.Conversions.Abbreviate(math.max(v88, 0), 2)
            v15.Player.Health.HealthDisplay.Text = ("%*/%*"):format(v93, (v8.Conversions.Abbreviate(v30, 2)))
            v15.Enemy.Health.HealthDisplay.Text = ("%*/%*"):format(v94, (v8.Conversions.Abbreviate(v31, 2)))
            task.delay(v85, function()
                v2:Create(v15.Player.Health.Back, TweenInfo.new(v83, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                    ["Size"] = UDim2.fromScale(v90, 1)
                }):Play()
                v2:Create(v15.Enemy.Health.Back, TweenInfo.new(v83, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                    ["Size"] = UDim2.fromScale(v92, 1)
                }):Play()
                if 9e9+9e9 <= 0 and v25 ~= true then
                    v3.Assets.Sounds.Tower.PlayerDefeated:Play()
                end
                if v92 <= 0 and v25 ~= true then
                    v3.Assets.Sounds.Tower.EnemyDefeated:Play()
                end
                task.wait(v86)
                v37:FireServer("AttackDone")
            end)
        end
    else
        TowerHandler.Attack = getgenv().FastTower
    end
end)

local v1 = game:GetService("Players")
local v2 = game:GetService("TweenService")
local v3 = game:GetService("ReplicatedStorage")
require(v3.Modules.GameUtils.Types)
local v4 = require(v3.Modules.Config.Core.CardConfig)
local v5 = require(v3.Modules.Config.Core.TowerConfig)
local v6 = require(v3.Modules.GameUtils.Configuration)
local v7 = {}
local v8 = DataModule()
local v9 = {}
local v13 = v1.LocalPlayer
local v14 = v13.PlayerGui
local v15 = v14.Tower.Frame
local v25 = false
local v26 = false
local v30 = 0
local v31 = 0
v7.InBattle = false
local v37 = v3.Remotes.Tower

TowerTab:line()

local Traits = {}
for i,v in pairs(TowerConfig.Traits) do
	if not table.find(Traits, i) then
        table.insert(Traits, i)
    end
end

function Cards(Extra)
    Extra = Extra or nil
    local Cards = {}
    if Extra ~= nil then
        Cards = {Extra}
    end
    for i,v in pairs(CardConfigModule.Packs) do
        for i,v in pairs(v.List) do
            if not table.find(Cards, i) then
                table.insert(Cards, i)
            end
        end
    end
    return Cards
end

local Trait_Tokens = TowerTab:Label("Trait Tokens: Loading...")

spawn(function()
    while task.wait() do
        pcall(function()
            Trait_Tokens:Refresh("Trait Tokens: "..game:GetService("Players").LocalPlayer.PlayerGui.Traits.Frame.PlayerTokens.Amount.Text)
        end)
    end
end)

TowerTab:Checklist("Select Card", "Trait_Card", Cards(), function(t)
    TraitCard = t
end)

TowerTab:Checklist("Select Trait", "Traits_Items", Traits, function(t)
    Selected_Traits = t
end)

TowerTab:Toggle("Auto Trait", false, function(t)
    AutoTrait = t
end)

spawn(function()
    while task.wait(0.1) do
        if AutoTrait and TraitCard and Selected_Traits then
            pcall(function()
                
                for i, v in pairs(TraitCard) do
                    local cardData = DataModule().ReplicatedData.GetData("Cards", v)
                    local currentTrait = cardData and cardData.Trait

                    if not currentTrait or not table.find(Selected_Traits, currentTrait) then
                        game:GetService("ReplicatedStorage").Remotes.Tower:FireServer("Roll", v)
                        print("Rolling", v, currentTrait)
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
                game:GetService("ReplicatedStorage").Remotes.Tower:FireServer(
                    "EquipBest"
                )
                task.wait(0.1)
                game:GetService("ReplicatedStorage").Remotes.Tower:FireServer(
                    "StartTower"
                )
                repeat task.wait() until not game:GetService("Players").LocalPlayer.PlayerGui.Tower.Frame.Visible or not AutoBattle
            end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if AutoBattle then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.Tower
                Event:FireServer(
                    "AttackDone"
                )
            end)
        end
    end
end)

function fireproximitypromptfunc(Obj, Amount, Skip, Distance)
    if Obj.ClassName == "ProximityPrompt" then 
        Amount = Amount or 1
        Distance = Distance or 20
        Obj.MaxActivationDistance = Distance
        local PromptTime = Obj.HoldDuration
        if Skip then 
            Obj.HoldDuration = 0
        end
        for i = 1, Amount do 
            Obj:InputHoldBegin()
            if not Skip then 
                wait(Obj.HoldDuration)
            end
            Obj:InputHoldEnd()
        end
        Obj.HoldDuration = PromptTime
        Obj.RequiresLineOfSight = false
    else 
        error("userdata<ProximityPrompt> expected")
    end
end

AutoFarm:Toggle("Auto Collect", false, function(t)
    AutoCollect = t
end)

AutoFarm:Toggle("Auto Collect Tokens", false, function(t)
    AutoCollect_Tokens = t
end)

AutoFarm:Toggle("Auto Collect Potions/Travel Tokens", false, function(t)
    AutoCollect_Potions_TravelToken = t
end)


spawn(function()
    while task.wait() do
        if AutoCollect then
            pcall(function()
                local Plot, Index = "1", "1"
                for i,v in pairs(workspace.Plots:GetChildren()) do
                    Plot = v.Name
                    for i,v in pairs(workspace.Plots[Plot].Map.Display:GetChildren()) do
                        if v:IsA("Model") and (v.Name == "Left" or v.Name == "Right") then
                            for i2,v2 in pairs(v:GetChildren()) do
                                Index = v2.Name
                                CardRemote:FireServer(
                                    "Collect",
                                    workspace.Plots[GetPlot()].Map.Display[v.Name][Index]
                                )
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
                local firstNumber = tonumber(workspace.Plots["1"].Map.Display.Page.Gui.Display.Display.Text:match("^%d+"))
                if Page >= 12 then
                    print(Page)
                    Page = 0
                    Flip = not Flip
                end

                if Flip then
                    local Event = game:GetService("ReplicatedStorage").Remotes.Card
                    Event:FireServer(
                        "Page",
                        "LeftArrow"
                    )
                else
                    local Event = game:GetService("ReplicatedStorage").Remotes.Card
                    Event:FireServer(
                        "Page",
                        "RightArrow"
                    )
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

AutoFarm:line()

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

AutoFarm:Checklist("Packs", "Packs", Packs, function(t)
    Selected_Pack = t
end)

AutoFarm:Checklist("Rarities", "Rarities", Rarities, function(t)
    Selected_Rarities = t
end)

AutoFarm:Toggle("Auto Buy Packs", false, function(t)
    AutoBuy = t
end)

AutoFarm:line()

spawn(function()
    while task.wait() do
        if AutoBuy then
            pcall(function()
                for i,v in pairs(workspace.Client.Packs:GetChildren()) do
                    if table.find(Selected_Pack, v:FindFirstChildOfClass("MeshPart").Name) then
                            for i2,v2 in pairs(v:GetChildren()) do
                                for i3,v3 in pairs(v2:GetChildren()) do
                                    if v2:FindFirstChildOfClass("Part") then
                                        if table.find(Selected_Rarities, v3.Name) or table.find(Selected_Rarities, "All") then
                                            if DataModule().ReplicatedData.GetData("Cash") > Conversions.BigNumToNumber(v:FindFirstChildOfClass("MeshPart").ConveyorDisplay.Price.Text) then
                                                CardRemote:FireServer(
                                                    "BuyPack",
                                                    v.Name
                                                )
                                            end
                                        end
                                    else
                                        if table.find(Selected_Rarities, "Normal") or table.find(Selected_Rarities, "All") then
                                            if DataModule().ReplicatedData.GetData("Cash") > Conversions.BigNumToNumber(v:FindFirstChildOfClass("MeshPart").ConveyorDisplay.Price.Text) then
                                                CardRemote:FireServer(
                                                    "BuyPack",
                                                    v.Name
                                                )
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

AutoFarm:Toggle("Auto Open Packs", false, function(t)
    AutoOpen = t
end)

AutoFarm:Toggle("Remove Opening Animation", false, function(t)
    RemoveOpeningAnimation = t
    if RemoveOpeningAnimation then
        CardOpening.OpenCard = function() return end
    else
        CardOpening.OpenCard = getgenv().OldOpeningAnimation
    end
end)

AutoFarm:Toggle("Allow TP", false, function(t)
    PacksTp = t
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
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame * CFrame.new(0, 2, 0)
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

AutoFarm:Toggle("Auto Place Packs (Work in progress)", false, function(t)
    AutoPlace = t
end)

spawn(function()
    while task.wait() do
        if AutoPlace then
            pcall(function()
                for i,v in pairs(workspace.Plots[GetPlot()].Packs:GetChildren()) do
                    -- if v:IsA("Model") then
                        for i,v in pairs(v:GetChildren()) do
                            if v.Name ~= "Bottom" and v.Name ~= "Top" then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame * CFrame.new(0, 3, 6)
                                for i,v in pairs(CardConfigModule.List) do
                                    CardRemote:FireServer(
                                        "Place",
                                        v
                                    )
                                    task.wait(0.1)
                                end
                            end
                        end
                    -- end
                end
            end)
        end
    end
end)

local Gradings = {}
for i,v in pairs(require(game:GetService("ReplicatedStorage").Modules.Config.Core.Grades).List) do
    if not table.find(Gradings, v) then
        table.insert(Gradings, v)
    end
end

GradingTab:Checklist("Select Grade", "Grade", Gradings, function(t)
    Selected_Grade = t
end)

GradingTab:Checklist("Select Card", "Cards", Cards("All"), function(t)
    Selected_Card = t
end)

GradingTab:Toggle("Auto Grade", false, function(t)
    AutoGrade = t
end)

spawn(function()
    while task.wait() do
        if AutoGrade then
            pcall(function()
                local Cards = DataModule().ReplicatedData.GetData("Cards")
                if table.find(Selected_Card, "All") then
                    for i,v in pairs(Cards) do
                        if not table.find(Selected_Grade, v.Grade) then
                            game:GetService("ReplicatedStorage").Remotes.Grade:FireServer(
                                "Roll",
                                i --"Ichigo"
                            )
                            task.wait(0.05)
                        end
                    end
                else
                    for i,v in pairs(Selected_Card) do
                        if v and not table.find(Selected_Grade, DataModule().ReplicatedData.GetData("Cards", v).Grade) then
                            game:GetService("ReplicatedStorage").Remotes.Grade:FireServer(
                                "Roll",
                                v --"Ichigo"
                            )
                            task.wait(0.05)
                        end
                    end
                end
            end)
        end
    end
end)

local UpgradeModule = require(game:GetService("ReplicatedStorage").Modules.Config.Core.Upgrades)
local Upgrades = {}
for i,v in pairs(UpgradeModule) do
	if not table.find(Upgrades, i) then
        table.insert(Upgrades, i)
    end
end

UpgradeTab:Checklist("Select Upgrade", "Upgrade", Upgrades, function(t)
    Selected_Grade = t
end)

UpgradeTab:Toggle("Auto Upgrade", false, function(t)
    AutoUpgrade = t
end)

spawn(function()
    while task.wait() do
        if AutoUpgrade then
            pcall(function()
                for i,v in pairs(UpgradeModule) do
                    if table.find(Selected_Grade, i) then
                        CardRemote:FireServer(
                            "Upgrade",
                            i --"CardChance"
                        )
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
end)